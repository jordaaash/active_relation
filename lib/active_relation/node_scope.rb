require 'arel'
require 'arel/nodes'
require 'arel/nodes/node'
require 'arel/nodes/named_function'

module ActiveRelation
  class NodeScope
    Nodes = Arel::Nodes
    Node  = Nodes::Node

    attr_reader :model

    delegate :table, :table_alias, :primary_key, :foreign_key, :quote,
             :[], :aliases, :fields, :columns, :attributes, to: :model

    alias_method :t, :table
    alias_method :a, :table_alias
    alias_method :q, :quote
    alias_method :pk, :primary_key
    alias_method :fk, :foreign_key

    def initialize (model)
      @model = model
    end

    def sql (sql)
      Arel.sql(sql)
    end

    def star
      Arel.star
    end

    def function (name, expression)
      Nodes::NamedFunction.new(name, expression)
    end

    alias_method :fn, :function

    def cast (node, as)
      function('CAST', [node.as(as.to_s)])
    end

    def respond_to_missing? (symbol, include_all = false)
      model.respond_to?(symbol, include_all) || super
    end

    def method_missing (symbol, *arguments, &block)
      if model.respond_to?(symbol)
        model.public_send(symbol, *arguments, &block)
      else
        super
      end
    end
  end
end
