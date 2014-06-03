module ActiveRelation
  module Execute
    def raw
      @raw ||= connection.execute(to_sql)
    end

    def rows
      @rows ||= raw.to_a
    end

    def results
      @results ||= begin
        results = cast_types(rows)
        if results.size > 0 && included.size > 0
          pk = primary_key
          fk = foreign_key
          included.each do |association, include|
            unless (associated = associations[association])
              raise ActiveRelation::IncludeInvalid
            end
            ids      = results.map(&pk)
            relation = associated.relation
            relation.instance_exec(ids, &include)
            associated_results = relation.results
            associated_results = associated_results.each_with_object({}) do |r, o|
              id = r[fk]
              a  = o[id] ||= []
              a << r
            end
            results.each do |result|
              id                  = result[pk]
              r                   = associated_results[id]
              result[association] = r || []
            end
          end
        end
        results
      end
    end

    def results?
      !!@results
    end

    def reset
      @results = @rows = @raw = @sql = @included = nil
      @query   = @select = @distinct = @scoped = @not = nil
      self
    end

    def reload
      @results = @rows = @raw = nil
      results
      self
    end

    def to_sql
      @sql ||= begin
        select unless select?
        scoped unless scoped?
        query.to_sql
      end
    end

    def to_a
      results
    end

    def inspect
      to_a.inspect
    end
  end
end
