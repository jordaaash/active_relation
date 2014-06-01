require 'active_support/core_ext/array/wrap'
require 'arel/nodes/inner_join'
require 'arel/nodes/outer_join'
require 'arel/nodes/string_join'

module ActiveRelation
  module Join
    def join (associations, join_type = :outer, &block)
      deep_join(associations, join_type, &block)
    end

    protected

    def deep_join (associations, join_type = :outer, depth = 1, &block)
      Array.wrap(associations).each do |association|
        unless association.is_a?(Hash)
          association = if association.is_a?(Array)
            Hash[*association]
          else
            Hash[association, join_type]
          end
        end
        association.each do |a, jt|
          jt = join_type if jt.nil?
          deep_join_association(a, jt, depth, &block)
        end
      end
      self
    end

    def deep_join_association (association, join_type = :outer, depth = 1, &block)
      unless (associated = associations[association])
        raise ActiveRelation::AssociationNotDefined
      end
      table_alias = associated.table_alias
      aliases     = source_aliases
      unless aliases.include?(table_alias)
        distinct unless distinct?
        through = through_associations[association]
        shallow_join_association(through, join_type) if through
        relation = scoped_relation(association, nil, nil, depth)
        node     = node_for_join(association, relation, associated, through, &block)
        type     = type_for_join_type(join_type)
        query.join(table_alias, type).on(node)
        merge_join_sources(relation, aliases)
      end
      self
    end

    def shallow_join (associations, join_type = :outer, &block)
      deep_join(associations, join_type, 0, &block)
    end

    def shallow_join_association (association, join_type = :outer, &block)
      deep_join_association(association, join_type, 0, &block)
    end

    def type_for_join_type (join_type)
      case join_type
      when :outer, false, nil
        Arel::Nodes::OuterJoin
      when :inner, true
        Arel::Nodes::InnerJoin
      when :string
        Arel::Nodes::StringJoin
      else
        raise ActiveRelation::JoinTypeInvalid
      end
    end

    def source_aliases
      sources.map(&:left)
    end

    def sources
      [source] + join_sources
    end

    def source
      query.source
    end

    def join_sources
      query.join_sources
    end

    def merge_constraints (relation, node)
      relation.constraints.reduce(node) { |n, c| n.and(c) }
    end

    def merge_join_sources (relation, aliases = nil)
      aliases ||= source_aliases
      relation.join_sources.each do |source|
        query.join_sources << source unless aliases.include?(source.left)
      end
      self
    end

    def scoped_relation (association, fields = nil, operation = nil, depth = 1)
      unless (model = associations[association])
        raise ActiveRelation::AssociationNotDefined
      end
      relation = model.relation
      nested   = nest_association(association)
      scope    = scopes[nested]
      scope ? relation.scoped(scope) : relation.unscoped
      relation.deep_select(fields, operation, depth - 1) if depth > 0
      relation
    end

    def node_for_join (association, relation, associated, through = nil, &block)
      node = joins[association] || EmptyNode.new
      node = merge_constraints(relation, node)
      if block
        on   = relation.instance_exec(node, association, associated, through, &block)
        node = on.is_a?(Array) ? on.reduce(node) { |n, c| n.and(c) } : on
      end
      raise ActiveRelation::JoinTypeInvalid unless node_valid?(node)
      node
    end

    def on (fields, values = :not_null, comparison = :==, negate = false, &block)
      nodes_for_where(fields, values, comparison, negate, &block)
    end

    def compare_on (fields, comparison, values, negate = false, &block)
      nodes_for_where(fields, values, comparison, negate, &block)
    end
  end
end
