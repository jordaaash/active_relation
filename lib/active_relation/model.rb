require 'arel'
require 'arel/nodes/named_function'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/string/inflections'

module ActiveRelation
  class Model
    extend Fields
    extend Associations

    delegate :cast_type, :sql, :star, :function, :cast, to: :class

    class << self
      delegate :columns_hash, to: :active_record

      delegate :all, :find, :count, :first, :first!, :scoped, :unscoped,
               :select, :distinct, :join,
               :where, :compare, :like, :not,
               :order, :paginate, :offset, :limit,
               :group, :having, :to_sql, :create!, :update!, :destroy!, to: :relation

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

      def quote (sql)
        connection.quote(sql)
      end

      def table (table = nil)
        if table
          @table = table
        else
          @table ||= active_record.arel_table
        end
      end

      def table_alias (table_alias = nil)
        if table_alias
          @table_alias = table.alias(table_alias.to_s)
        else
          @table_alias ||= begin
            table_alias = model_name
            table_alias = table_alias.pluralize unless singular?
            table.alias(table_alias)
          end
        end
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

      def sql (sql)
        Arel.sql(sql)
      end

      def star
        Arel.star
      end

      def function (name, *expression)
        Arel::Nodes::NamedFunction.new(name, expression)
      end

      def cast (field, as, &block)
        node = node_for_field(field, &block)
        if node.respond_to?(:as)
          node = node.as(as.to_s)
        elsif node.respond_to?(:alias=)
          node.alias = as.to_s
        end
        function('CAST', node)
      end
    end

    def initialize (attributes = nil)
      assign_attributes(attributes) unless attributes.nil?
    end

    def attributes
      @attributes ||= HashWithIndifferentAccess.new
    end

    def raw
      @raw ||= HashWithIndifferentAccess.new
    end

    def assign_attributes (attributes)
      attributes.each { |a, v| self[a] = v }
    end

    def has_attribute? (attribute)
      respond_to?(attribute) || attributes.include?(attribute)
    end

    def [] (attribute)
      attributes[attribute]
    end

    def []= (attribute, value)
      getter = attribute
      unless respond_to?(getter)
        define_singleton_method(getter) { attributes[attribute] }
      end

      setter = :"#{attribute}="
      unless respond_to?(setter)
        define_singleton_method(setter) do |v|
          raw[attribute]        = v
          attributes[attribute] = cast_type(attribute, v)
        end
      end

      raw[attribute]        = value
      attributes[attribute] = cast_type(attribute, value)
    end

    def inspect
      attributes.inspect
    end

    def as_json (options = nil)
      attributes.as_json(options)
    end

    def respond_to_missing? (symbol, *)
      attributes.include?(symbol) || !symbol.to_s.chomp!('=').nil? || super
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