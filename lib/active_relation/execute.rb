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
        if results.size
          pk = primary_key
          fk = foreign_key
          includes.each do |i, block|
            associated         = associations[i]
            ids                = results.map(&pk)
            block              ||= proc { |ids| all.distinct.where(fk, ids) }
            relation           = associated.instance_exec(ids, results, &block)
            associated_results = relation.results.reduce({}) do |h, r|
              id = r[fk]
              a  = h[id] ||= []
              a << r
              h
            end
            results.each do |result|
              id        = result[pk]
              r         = associated_results[id]
              result[i] = r || []
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
      @results = @rows = @raw = @sql = nil
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
