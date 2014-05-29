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
  end
end
