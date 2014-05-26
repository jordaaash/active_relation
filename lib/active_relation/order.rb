require 'active_support/core_ext/array/wrap'
require 'arel/attributes/attribute'
require 'arel/nodes/node'
require 'arel/null_order_predications'

module ActiveRelation
  module Order
    def order (fields = nil, direction = :default, null_order = :last, &block)
      fields ||= primary_key unless order?
      if fields
        order!
        nodes = nodes_for_order(fields, direction, null_order, &block)
        query.order(*nodes)
      end
      self
    end

    protected

    def order!
      @order = true
    end

    def order?
      !!@order || query.orders.any?
    end

    def nodes_for_order (fields, direction = :default, null_order = :last, &block)
      Array.wrap(fields).flat_map do |field|
        unless field.is_a?(Hash)
          field = field.is_a?(Array) ? Hash[*field] : Hash[field, direction]
        end
        field.map do |f, d|
          d = direction if d.nil?
          node_for_order(f, d, null_order, &block)
        end
      end
    end

    def node_for_order (field, direction = :default, null_order = :last, &block)
      raise ActiveRelation::FieldNotDefined unless fields.include?(field)
      node = case field
             when Arel::Attributes::Attribute, Arel::Nodes::Node
               field
             else
               node_for_field(field)
             end
      order_for_node(node, field, direction, null_order, &block)
    end

    def order_for_node (node, field = nil, direction = :default, null_order = :last, &block)
      node = order_direction_for_node(node, direction)
      node = null_order_for_node(node, null_order)
      yield_for_node(node, field, direction, null_order, &block)
    end

    def order_direction_for_node (node, direction = :default)
      case direction
      when :default, nil
        node
      when :ascending, :asc, :increasing, :+, true
        node.asc
      when :descending, :desc, :decreasing, :-, false
        node.desc
      else
        raise ActiveRelation::OrderDirectionInvalid
      end
    end

    def null_order_for_node (node, null_order = :last)
      case null_order
      when :last, :-, false
        unless node.respond_to?(:nulls_last)
          raise ActiveRelation::NullOrderInvalid
        end
        node.nulls_last
      when :first, :+, true
        unless node.respond_to?(:nulls_first)
          raise ActiveRelation::NullOrderInvalid
        end
        node.nulls_first
      when nil, :default
        node
      else
        raise ActiveRelation::NullOrderInvalid
      end
    end
  end
end
