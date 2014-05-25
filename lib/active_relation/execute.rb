module ActiveRelation
  module Execute
    def raw
      @raw ||= connection.execute(to_sql)
    end

    def rows
      @rows ||= raw.to_a
    end

    def results
      @results ||= cast_types(rows)
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
