require 'active_support/hash_with_indifferent_access'

module ActiveRelation
  module Include
    def include (*associations, &block)
      reset if results?
      associations.each do |association|
        unless association.is_a?(Hash)
          association = if association.is_a?(Array)
                          Hash[*association]
                        else
                          Hash[association, nil]
                        end
        end
        association.each do |a, b|
          includes[a] = b || block
        end
      end
      self
    end

    protected

    def includes
      @includes ||= HashWithIndifferentAccess.new
    end
  end
end
