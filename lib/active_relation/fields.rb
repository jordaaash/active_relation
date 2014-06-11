require 'ruby_utils/lazy_indifferent_hash'
require 'arel/nodes/binary'
require 'arel/attributes/attribute'
require 'arel/nodes/node'
require 'arel/nodes/sql_literal'

module ActiveRelation
  module Fields
    include ActiveRelation::Regexp

    def field (field, options = nil, &block)
      raise ActiveRelation::FieldDefinitionInvalid unless field =~ FIELD_REGEXP
      if options.is_a?(Proc)
        raise ActiveRelation::FieldDefinitionInvalid if block
        block, options = options, {}
      elsif options
        raise ActiveRelation::FieldDefinitionInvalid unless options.is_a?(Hash)
      else
        options = {}
      end

      if (through = options[:through])
        model = associations[through]
        raise ActiveRelation::AssociationNotDefined unless model

        associations[field] = model
        joins[field]        = proc do
          joins[through] or raise ActiveRelation::JoinNotDefined
        end
      else
        model = options[:model]
      end

      unless (as = options[:as]) == false
        self.alias field, as
      end
      unless (column = options[:column]) == false
        self.column field, column, model
      end
      unless (attribute = options[:attribute]) == false
        self.attribute field, attribute || column
      end

      column      ||= field
      self[field] = if block
        proc { model.instance_exec(&block) }
      elsif model
        proc { model[column] }
      else
        proc { table_alias[column] }
      end

      unless options[:define] == false
        define_method(field) { attributes[field] }
        define_method(:"#{field}=") { |value| attributes[field] = value }
      end

      nil # Avoid eager evaluation of the block from using the return value
    end

    def alias (field, as = nil, &block)
      if as.is_a?(Proc)
        raise ActiveRelation::AliasDefinitionInvalid if block
        block, as = as, nil
      end
      as             ||= field
      aliases[field] = block || proc do
        node = self[field]
        raise ActiveRelation::FieldNotDefined unless node
        node = node.dup
        if node.respond_to?(:as)
          node = node.as(as.to_s)
        elsif node.respond_to?(:alias=)
          node.alias = as.to_s
        end
        node
      end
      nil # Avoid eager evaluation of the block from using the return value
    end

    alias_method :as, :alias

    def column (field, column = nil, model = nil)
      column         ||= field
      columns[field] = if model
        proc { model.columns[column] }
      else
        proc { columns_hash[column.to_s] }
      end
      nil # Avoid eager evaluation of the block from using the return value
    end

    def attribute (field, attribute = nil)
      attribute         ||= field
      attributes[field] = attribute.to_s
      nil # For consistency with eager evaluation safety on other methods
    end

    def [] (field)
      fields[field]
    end

    def []= (field, proc)
      fields[field] = proc
    end

    def fields
      @fields ||= LazyIndifferentHash.new
    end

    def aliases
      @aliases ||= LazyIndifferentHash.new
    end

    def columns
      @columns ||= LazyIndifferentHash.new
    end

    def attributes
      @attributes ||= HashWithIndifferentAccess.new
    end

    def attributes_for_fields (fields)
      default   = attributes.keys.to_set
      available = default + associations.keys.to_set
      fields.each_with_object({}) do |(f, v), o|
        f = f.to_s
        raise ActiveRelation::FieldNotDefined unless available.include?(f)
        if (associated = associations[f])
          attribute    = attributes[f] || f
          o[attribute] = if v.is_a?(Array)
            v.map do |a|
              if a.is_a?(Hash)
                associated.new(a)
              else
                a
              end
            end
          elsif v.is_a?(Hash)
            associated.new(v)
          else
            v
          end
        elsif (attribute = attributes[f])
          o[attribute] = v
        else
          raise ActiveRelation::AttributeNotDefined
        end
      end
    end

    def aliases_for_fields (fields = nil, &block)
      fields ||= self.fields.keys
      fields.flat_map { |f| alias_for_field(f, &block) }
    end

    def alias_for_field (field, &block)
      if alias_valid?(field) || node_valid?(field)
        yield_for_node(field, nil, &block)
      else
        as = aliases[field] or raise ActiveRelation::AliasNotDefined
        if as.is_a?(Array)
          as.map do |a|
            raise ActiveRelation::AliasTypeInvalid unless alias_valid?(a)
            yield_for_node(a, field, &block)
          end
        else
          raise ActiveRelation::AliasTypeInvalid unless alias_valid?(as)
          yield_for_node(as, field, &block)
        end
      end
    end

    def alias_valid? (as)
      as.is_a?(Arel::Nodes::As) || as.respond_to?(:alias)
    end

    def node_for_field (field, &block)
      node = if node_valid?(field)
        field
      else
        self[field] or raise ActiveRelation::FieldNotDefined
      end
      yield_for_node(node, field, &block)
    end

    def yield_for_node (node, field, *arguments, &block)
      node = yield node, field, *arguments if block_given?
      raise ActiveRelation::FieldTypeInvalid unless node_valid?(node)
      node
    end

    def node_valid? (node)
      case node
      when Arel::Attributes::Attribute, Arel::Nodes::Node, Arel::Nodes::SqlLiteral
        true
      else
        false
      end
    end

    def cast_types (rows)
      rows.map do |r|
        r.each_with_object(new) do |(f, v), o|
          if (matches = ASSOCIATION_REGEXP.match(f))
            association = matches[1]
            field       = matches[2]
            unless (associated = associations[association])
              raise ActiveRelation::AssociationNotDefined
            end
            a     = o[association] ||= associated.new
            value = associated.cast_type(field, v)
            a.public_send(:"#{field}=", value)
          else
            value = cast_type(f, v)
            o.public_send(:"#{f}=", value)
          end
        end
      end
    end

    def cast_type (field, value)
      (column = columns[field]) ? column.type_cast(value) : value
    end
  end
end
