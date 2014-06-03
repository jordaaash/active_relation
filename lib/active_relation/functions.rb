require 'arel'
require 'arel/nodes/named_function'

module ActiveRelation
  module Functions
    def quote (sql)
      connection.quote(sql)
    end

    def sql (sql)
      Arel.sql(sql)
    end

    def star
      Arel.star
    end

    def function (name, *expression)
      Arel::Nodes::NamedFunction.new(name, expression)
    end

    def cast (field, as)
      node = node_for_field(field)
      node = node.dup
      if node.respond_to?(:as)
        node = node.as(as.to_s)
      elsif node.respond_to?(:alias=)
        node.alias = as.to_s
      end
      function('CAST', node)
    end

    def upper (field)
      node = node_for_field(field)
      function('UPPER', node)
    end

    def lower (field)
      node = node_for_field(field)
      function('LOWER', node)
    end

    def count (field, distinct = false)
      node = node_for_field(field)
      Arel::Nodes::Count.new [node], distinct
    end

    def sum (field)
      node = node_for_field(field)
      Arel::Nodes::Sum.new [node]
    end

    def maximum (field)
      node = node_for_field(field)
      Arel::Nodes::Max.new [node]
    end

    def minimum (field)
      node = node_for_field(field)
      Arel::Nodes::Min.new [node]
    end

    def average (field)
      node = node_for_field(field)
      Arel::Nodes::Avg.new [node]
    end

    def extract (field, extract)
      node = node_for_field(field)
      Arel::Nodes::Extract.new [node], extract
    end
  end
end
