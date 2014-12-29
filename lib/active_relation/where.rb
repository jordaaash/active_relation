require 'active_support/core_ext/array/wrap'

module ActiveRelation
  module Where
    def where (fields = nil, values = :not_null, comparison = :==, condition = :and, &block)
      if fields
        negate = not?
        @not   = nil
        nodes  = nodes_for_where(fields, values, comparison, negate, condition, &block)
        query.where(nodes)
      end
      self
    end

    def not (fields = nil, values = :not_null, comparison = :==, &block)
      not!
      fields ? where(fields, values, comparison, &block) : self
    end

    def compare (fields, comparison, values = nil, &block)
      where(fields, values, comparison, &block)
    end

    def like (fields, values = nil, &block)
      compare(fields, :%, values, &block)
    end

    protected

    def not!
      @not = !@not
    end

    def not?
      !!@not
    end

    def constraints
      query.constraints
    end

    def nodes_for_where (fields, values = :not_null, comparison = :==, negate = false, condition = :and, &block)
      unless fields.is_a?(Hash)
        fields = if fields.is_a?(Array)
          unless values == :not_null
            values = Array.wrap(values)
            fields = fields.zip(values)
          end
          Hash[fields]
        else
          Hash[fields, values]
        end
      end
      nodes = fields.map { |f, v| node_for_where(f, v, comparison, negate, &block) }
      first = nodes.shift
      nodes.reduce(first) { |f, n| f.public_send(condition, n) }
    end

    def node_for_where (field, values = :not_null, comparison = :==, negate = false, &block)
      values, negate = nil, !negate if values == :not_null && comparison == :==
      node           = node_for_field(field)
      if values.is_a?(Set) || values.is_a?(Range)
        values = values.to_a
      elsif values.is_a?(Symbol)
        values = node_for_field(values)
      end
      node = comparison_for_node(node, comparison, values, negate)
      yield_for_node(node, field, values, comparison, negate, &block)
    end

    def comparison_for_node (node, comparison, values, negate = false)
      methods = methods_for_comparison(comparison, negate)
      method  = values.is_a?(Array) ? methods.last : methods.first
      raise ActiveRelation::ComparisonInvalid unless node.respond_to?(method)
      node.public_send(method, values)
    end

    def methods_for_comparison (comparison, negate = false)
      case comparison
      when :==, :eq, :equal, :equals, :in, :any
        negate ? [:not_eq, :not_in] : [:eq, :in]
      when :!=, :not, :none
        negate ? [:eq, :in] : [:not_eq, :not_in]
      when :%, :like, :match, :matches, :matching
        negate ? [:does_not_match, :does_not_match_any] : [:matches, :matches_any]
      when :>, :gt, :greater, :greater_than
        negate ? [:lteq, :lteq_all] : [:gt, :gt_all]
      when :<, :lt, :less, :less_than
        negate ? [:gteq, :gteq_all] : [:lt, :lt_all]
      when :>=, :gte, :gteq, :greater_than_equal
        negate ? [:lt, :lt_all] : [:gteq, :gteq_all]
      when :<=, :lte, :lteq, :less_than_equal
        negate ? [:gt, :gt_all] : [:lteq, :lteq_all]
      else
        Array.wrap(comparison)
      end
    end
  end
end
