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
          included.each do |association, include|
            unless (associated = associations[association])
              raise ActiveRelation::IncludeInvalid
            end
            pk  = primary_key
            if through = through_associations[association] && included[through]
              fk = associated.foreign_key
              nested_ids = results.each_with_object({}) do |r, o|
                id = r[pk]
                if a = r[through]
                  o[id] = a.map(&fk) - [nil]
                end
              end
              ids = nested_ids.flatten
              relation = associated.relation
              relation.instance_exec(ids, &include)
              associated_results = relation.results
              fk = associated.primary_key
              associated_results = associated_results.each_with_object({}) do |r, o|
                id = r[fk]
                a  = o[id] ||= []
                a << r
              end
              results.each do |result|
                id  = result[pk]
                ids = nested_ids[id] || []
                result[association] = ids.flat_map do |i|
                  associated_results[i]
                end
              end
            else
              fk  = foreign_key
              ids = results.map(&pk)
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
