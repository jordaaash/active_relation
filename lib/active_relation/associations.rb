require 'active_support/core_ext/string/inflections'
require 'active_support/hash_with_indifferent_access'
require 'ruby_utils/lazy_indifferent_hash'

module ActiveRelation
  module Associations
    include ActiveRelation::Regexp

    def belongs_to (association, options = {}, &block)
      model = associate association, options, &block

      primary_key = options[:primary_key] || model.primary_key
      foreign_key = options[:foreign_key] || model.foreign_key

      field foreign_key, options.slice(:column, :attribute, :as, :define)

      unless (join = options[:join]) == false
        join_on association, foreign_key, primary_key, self, &join
      end

      model
    end

    def has_one (association, options = {}, &block)
      model = associate association, options, &block

      if (through = options[:through])
        through_associations[association] = through

        join_model = associations[through]
        raise ActiveRelation::AssociationNotDefined unless join_model

        join_column      = model.foreign_key
        join_primary_key = options[:primary_key] || join_model.primary_key
        join_foreign_key = options[:foreign_key] || join_model.foreign_key

        association_model = join_model
        association_left  = join_column
        association_right = model.primary_key

        foreign_key_left  = join_foreign_key
        foreign_key_right = join_primary_key
      else
        join_model = model

        join_column      = model.primary_key
        join_primary_key = options[:primary_key] || primary_key
        join_foreign_key = options[:foreign_key] || foreign_key

        association_model = self
        association_left  = join_primary_key
        association_right = join_foreign_key

        foreign_key_left  = join_primary_key
        foreign_key_right = join_foreign_key
      end

      unless (join = options[:join]) == false
        join_on association, association_left, association_right, association_model, &join
      end

      unless (foreign_key = options[:foreign_key]) == false
        foreign_key ||= model.foreign_key
        field foreign_key, model: join_model, column: join_column
        join_on foreign_key, foreign_key_left, foreign_key_right, self
        associations[foreign_key] = join_model

        unless (scope = options[:scope]) == false
          scope_association(foreign_key, scope)
        end
      end

      join_model
    end

    def has_many (association, options = {}, &block)
      primary_key = options[:primary_key]
      foreign_key = options[:foreign_key]

      options[:model] ||= \
        "#{module_name}::#{association.to_s.singularize.camelize}"

      model = associate association, options, &block
      if (through = options[:through])
        through_associations[association] = through

        join_model = associations[through]
        raise ActiveRelation::AssociationNotDefined unless join_model
        # works for has_many through has_many
        # fails for has_many through has_one
        primary_key ||= model.foreign_key
        foreign_key ||= model.primary_key
      else
        join_model = self
      end
      left_field  = primary_key || join_model.primary_key
      right_field = foreign_key || join_model.foreign_key

      unless (join = options[:join]) == false
        join_on association, left_field, right_field, join_model, &join
      end

      unless (scope = options[:scope]) == false
        include_association association, right_field, scope
      end

      join_model
    end

    def has_and_belongs_to_many (association, options = {}, &block)
      # TODO: Implement has_and_belongs_to_many relationships
      raise NotImplementedError
    end

    def scope (name = :default, scope = nil, define = true, &block)
      raise ActiveRelation::ScopeDefinitionInvalid unless name
      if block
        raise ActiveRelation::ScopeDefinitionInvalid if scope
        scope = block
      else
        raise ActiveRelation::ScopeDefinitionInvalid unless scope
      end
      if define
        define_singleton_method(name) do |*arguments, &block|
          relation = scoped(name, *arguments)
          # FIXME: This hack for #all is causing scopes to get applied twice
          if relation.respond_to?(name)
            relation.public_send(name, *arguments, &block)
          else
            relation
          end
        end
      end
      scopes[name] = scope
    end

    def associate (association, options = {}, &block)
      unless association =~ FIELD_REGEXP
        raise ActiveRelation::AssociationDefinitionInvalid
      end
      model = options[:model] || "#{module_name}::#{association.to_s.camelize}"
      model = model.constantize if model.respond_to?(:constantize)
      block ||= proc do
        model.aliases_for_fields.map do |a|
          node   = a.left
          node   = node.dup
          nested = nest_association(association, a.right)
          if node.respond_to?(:as)
            node = node.as(nested)
          elsif node.respond_to?(:alias=)
            node.alias = nested
          else
            raise ActiveRelation::AssociationDefinitionInvalid
          end
          node
        end
      end

      self.alias association, &block
      self.attribute association, options[:association]
      associations[association] = model

      unless (scope = options[:scope]) == false
        scope_association(association, scope)
      end

      unless options[:define] == false
        define_method(association) { attributes[association] }
        define_method(:"#{association}=") do |value|
          attributes[association] = value
        end
      end

      model
    end

    def join_on (association, left_field, right_field, model = self, &block)
      joins[association] = proc do
        associated = associations[association]
        left_node  = model[left_field]
        right_node = associated[right_field]

        if left_node.nil? || right_node.nil?
          left_field  = associated.foreign_key
          right_field = associated.primary_key
          left_node   = model[left_field]
          right_node  = associated[right_field]
        end

        if block
          instance_exec(associated, model, left_node, right_node, &block)
        else
          raise JoinDefinitionInvalid if left_node.nil?
          raise JoinDefinitionInvalid if right_node.nil?
          left_node.eq(right_node)
        end
      end
      nil # Avoid eager evaluation of the block from using the return value
    end

    def scope_association (association, scope = nil, &block)
      if block
        raise ActiveRelation::ScopeDefinitionInvalid if scope
        scope = block
      else
        unless scope.is_a?(Proc)
          name  = scope || :default
          scope = proc do |*arguments|
            scoped(name, *arguments)
          end
        end
      end
      nested = nest_association(association)
      self.scope nested, scope, false
    end

    def include_association (association, foreign_key, scope = nil, &block)
      if block
        raise ActiveRelation::IncludeDefinitionInvalid if scope
        scope = block
      end
      includes[association] = proc do |ids, *arguments|
        right_node = self[foreign_key]
        raise ActiveRelation::IncludeDefinitionInvalid unless right_node
        unless scope.is_a?(Proc)
          name  = scope || :default
          scope = proc do |ids, *arguments|
            scoped(name, ids, *arguments)
            where(right_node, ids)
          end
        end
        ids = [ids] unless scope.lambda? || arguments.size > 0
        instance_exec(ids, *arguments, &scope)
      end
      nil # Avoid eager evaluation of the block from using the return value
    end

    def associations
      @associations ||= HashWithIndifferentAccess.new
    end

    def through_associations
      @through_associations ||= HashWithIndifferentAccess.new
    end

    def joins
      @joins ||= LazyIndifferentHash.new
    end

    def includes
      @includes ||= HashWithIndifferentAccess.new
    end

    def scopes
      @scopes ||= HashWithIndifferentAccess.new
    end

    def nest_association (association, field = nil)
      "#{SEPARATOR_PRIMITIVE}#{association}#{SEPARATOR_PRIMITIVE}#{field}"
    end
  end
end
