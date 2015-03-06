require 'active_support/hash_with_indifferent_access'

module ActiveRelation
  class FieldHash < HashWithIndifferentAccess
    attr_accessor :scope
    attr_accessor :args

    def initialize (scope, *args)
      self.scope = scope
      self.args  = args
    end

    def [] (key)
      value = super
      if value.is_a?(Proc)
        value = evaluate(value)
      end
      value
    end

    private

    def evaluate (proc)
      scope.instance_exec(*args, &proc)
    end
  end
end
