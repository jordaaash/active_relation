module ActiveRelation
  module Group
    def group (*fields, &block)
      nodes = fields.map { |f| node_for_field(f, &block) }
      query.group(*nodes)
      self
    end

    def having (fields, comparison, values = nil, &block)
      negate = not?
      @not   = nil
      nodes  = nodes_for_where(fields, values, comparison, negate, &block)
      query.having(nodes)
      self
    end
  end
end
