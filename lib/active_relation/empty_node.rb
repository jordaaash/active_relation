module ActiveRelation
  class EmptyNode < Arel::Nodes::Node
    def or right
      right
    end

    def and right
      right
    end
  end
end
