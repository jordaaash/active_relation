module ActiveRelation
  class Relation
    include Query
    include Select
    include Join
    include Order
    include Limit
    include Where
    include Group
    include Execute
    include CreateUpdateDestroy
    include Include

    attr_reader :model

    def initialize (model, &block)
      @model = model
      yield self if block_given?
    end

    def dup
      self.class.new(model) do |r|
        r.query  = query.dup
        r.select! if select?
        r.distinct! if distinct?
        r.not! if not?
      end
    end

    def respond_to_missing? (symbol, *)
      (model.respond_to?(symbol) && model.scopes.include?(symbol)) || super
    end

    def method_missing (symbol, *arguments, &block)
      if model.respond_to?(symbol) && model.scopes.include?(symbol)
        scoped(symbol, *arguments, &block)
      else
        super
      end
    end

    protected

    delegate :active_record, :connection, :table, :table_alias, :module_name,
             :model_name, :primary_key, :foreign_key,
             :[], :fields, :aliases, :attributes, :columns,
             :aliases_for_fields, :alias_for_field, :alias_valid?,
             :node_for_field, :node_valid?, :yield_for_node,
             :cast_types, :cast_type,
             :associations, :through_associations, :joins, :scope, :nest_association,
             :quote, :sql, :star, :function, :cast, to: :model
  end
end
