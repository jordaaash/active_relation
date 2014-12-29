module ActiveRelation
  module Group
    def group (*fields, &block)
      nodes = fields.map { |f| node_for_field(f, &block) }
      query.group(*nodes)
      self
    end

    def having (fields, values = :not_null, comparison = :==, condition = :and, &block)
      negate = not?
      @not   = nil
      nodes  = nodes_for_where(fields, values, comparison, negate, condition, &block)
      query.having(nodes)
      self
    end

    def comparing (fields, comparison, values, condition = :and, &block)
      having(fields, values, comparison, condition, &block)
    end
  end
end
