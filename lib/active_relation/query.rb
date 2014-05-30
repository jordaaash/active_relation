module ActiveRelation
  module Query
    attr_writer :query

    def query
      @query ||= table.from(table_alias)
    end

    def all (options = {})
      reset if results?
      scoped unless scoped?
      select(options[:fields])
      order(options[:order])
      paginate(options[:limit] || 0, options[:offset] || 0)
    end

    def find (ids, options = {})
      reset if results?
      select(options[:fields]) unless select?
      where(primary_key, ids)
      if ids.is_a?(Enumerable)
        # FIXME: Add found rows calculation so that this doesn't error on edge case of IDs with limit
        # https://stackoverflow.com/questions/3984643/equivalent-of-found-rows-function-in-postgresql
        raise ActiveRelation::RelationNotFound unless results.size == ids.size
        results
      else
        first!
      end
    end

    def find_by (fields, options = {})
      reset if results?
      select(options[:fields]) unless select?
      where(fields)
      first
    end

    def find_by! (fields, options = {})
      find_by(fields, options) or raise ActiveRelation::RelationNotFound
    end

    def count
      selected.clear if select?
      select!
      select(table[star].count)
      raise ActiveRelation::RelationNotFound unless (row = rows.first)
      row.values.first.to_i
    end

    def first (count = 1)
      reset if results?
      limit(count)
      count == 1 ? results.first : results
    end

    def first! (count = 1)
      results = first(count)
      if count == 1
        results or raise ActiveRelation::RelationNotFound
      elsif result.size == count
        results
      else
        raise ActiveRelation::RelationNotFound
      end
    end

    def scoped (scope = :default, *arguments, &block)
      reset if results?
      if block
        raise ActiveRelation::ScopeInvalid if scope.is_a?(Proc)
      else
        block = scope.is_a?(Proc) ? scope : scopes[scope]
      end
      instance_exec(*arguments, &block) if block
      scoped unless scoped? || scope == :default
      scoped!
      self
    end

    def unscoped
      reset if results?
      scoped!
      self
    end

    protected

    def scoped!
      @scoped = true
    end

    def scoped?
      !!@scoped
    end
  end
end
