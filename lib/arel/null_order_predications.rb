# Modified from https://gist.github.com/jswanner/3717188

require 'arel'
require 'arel/nodes'
require 'arel/nodes/unary'
require 'arel/visitors/depth_first'
require 'arel/visitors/postgresql'
require 'arel/attributes/attribute'
require 'arel/nodes/ordering'

module Arel
  module NullOrderPredications
    def nulls_first
      Arel::Nodes::NullsFirst.new self
    end

    def nulls_last
      Arel::Nodes::NullsLast.new self
    end
  end

  module Nodes
    class NullsFirst < Unary
      def gsub (*args)
        expr.to_sql.gsub(*args)
      end
    end

    class NullsLast < Unary
      def gsub (*args)
        expr.to_sql.gsub(*args)
      end
    end
  end

  module Visitors
    class DepthFirst
      private

      alias :visit_Arel_Nodes_NullsFirst :unary
      alias :visit_Arel_Nodes_NullsLast :unary
    end

    class PostgreSQL
      private

      def visit_Arel_Nodes_NullsFirst (o)
        "#{visit(o.expr)} NULLS FIRST"
      end

      def visit_Arel_Nodes_NullsLast (o)
        "#{visit(o.expr)} NULLS LAST"
      end
    end
  end
end

Arel::Attributes::Attribute.send(:include, Arel::NullOrderPredications)
Arel::Nodes::Ordering.send(:include, Arel::NullOrderPredications)
