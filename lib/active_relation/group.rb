module ActiveRelation
  module Group
    def group (*fields, &block)
      nodes = fields.map { |f| node_for_field(f, &block) }
      query.group(*nodes)
      self
    end

    def having (fields, values = :not_null, comparison = :==, &block)
      negate = not?
      @not   = nil
      nodes  = nodes_for_where(fields, values, comparison, negate, &block)
      query.having(nodes)
      self
    end

    def comparing (fields, comparison, values, &block)
      having(fields, values, comparison, &block)
    end
  end
end
