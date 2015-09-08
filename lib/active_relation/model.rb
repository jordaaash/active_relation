require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/string/inflections'

module ActiveRelation
  class Model
    extend Fields
    extend Associations
    extend Functions
    extend CreateUpdateDestroy

    delegate :cast_type, :active_record, to: :class

    class << self
      delegate :columns_hash, to: :active_record

      delegate :all, :count, :find, :find_by, :find_by!, :first, :first!,
               :scoped, :unscoped,
               :select, :distinct, :join, :including,
               :where, :compare, :like, :not,
               :order, :paginate, :offset, :limit,
               :group, :having, :to_sql, to: :relation

      def relation
        ActiveRelation::Relation.new(self)
      end

      def active_record (active_record = nil)
        if active_record
          @active_record = active_record
        else
          @active_record ||= name.demodulize.constantize
        end
      end

      def connection
        active_record.connection
      end

      def table (table = nil)
        if table
          @table = table
        else
          @table ||= active_record.arel_table
        end
      end

      def table_name (table_name = nil)
        if table_name
          @table_name = table_name
        else
          @table_name ||= singular? ? model_name : model_name.pluralize
        end
      end

      def table_alias (table_alias = nil)
        if table_alias
          @table_alias = table.alias(table_alias.to_s)
        else
          @table_alias ||= table.alias(table_name)
        end
      end

      def alias_table (table_alias)
        table = clone
        table.table_alias(table_alias)
        %i(fields aliases columns joins).each do |field|
          field_hash = public_send(field).clone
          field_hash.scope = table
          table.instance_variable_set(:"@#{field}", field_hash)
        end
        table
      end

      def singular (singular = true)
        @singular = singular
      end

      def singular?
        !!@singular
      end

      def module_name
        @module_name ||= name.deconstantize
      end

      def model_name
        @model_name ||= name.demodulize.underscore
      end

      def primary_key (primary_key = nil)
        if primary_key
          @primary_key = primary_key.to_sym
        else
          @primary_key ||= active_record.primary_key.to_sym
        end
      end

      def foreign_key (foreign_key = nil)
        if foreign_key
          @foreign_key = foreign_key.to_sym
        else
          @foreign_key ||= :"#{model_name}_#{primary_key}"
        end
      end
    end

    def initialize (attributes = nil)
      assign_attributes(attributes) unless attributes.nil?
    end

    def attributes
      @attributes ||= HashWithIndifferentAccess.new
    end

    def assign_attributes (attributes)
      attributes.each do |a, v|
        value = cast_type(a, v)
        public_send(:"#{a}=", value)
      end
    end

    def has_attribute? (attribute)
      attributes.include?(attribute)
    end

    def [] (attribute)
      attributes[attribute]
    end

    def []= (attribute, value)
      attributes[attribute] = cast_type(attribute, value)
    end

    def serializable_hash
      attributes.each_with_object({}) do |(a, v), o|
        o[a] = respond_to?(a) ? public_send(a) : v
      end
    end

    def inspect
      serializable_hash.inspect
    end

    def as_json (options = nil)
      serializable_hash.as_json(options)
    end

    def respond_to_missing? (symbol, *)
      attributes.include?(symbol) || symbol.to_s.chomp!('=') || super
    end

    def method_missing (symbol, *arguments, &block)
      name  = symbol.to_s
      arity = arguments.size
      if name.chomp!('=')
        raise ArgumentError unless arity == 1
        self[name] = arguments[0]
      elsif arity == 0
        self[name]
      else
        super
      end
    end
  end
end
