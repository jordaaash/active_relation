require 'active_support/hash_with_indifferent_access'

module ActiveRelation
  module Include
    def including (associations, *arguments, &block)
      reset if results?
      Array.wrap(associations).each do |association|
        unless association.is_a?(Hash)
          association = if association.is_a?(Array)
            Hash[*association]
          else
            Hash[association, arguments]
          end
        end
        association.each do |a, args|
          unless (include = block || includes[a])
            raise ActiveRelation::IncludeInvalid
          end
          args = arguments if args.nil?
          if through = through_associations[a]
            shallow_join_association(through, :inner)
          end

          # Lambda hacks are because of this "feature":
          # http://makandracards.com/makandra/20641-careful-when-calling-a-ruby-block-with-an-array
          # http://www.ruby-doc.org/core-2.1.1/Proc.html#method-i-lambda-3F
          # https://stackoverflow.com/questions/23945533/why-do-ruby-procs-blocks-with-splat-arguments-behave-differently-than-methods-an
          included[a] = lambda do |ids|
            ids = [ids] unless include.lambda? || args.size > 0
            instance_exec(ids, *args, &include)
          end
        end
      end
      self
    end

    protected

    def included
      @included ||= HashWithIndifferentAccess.new
    end
  end
end
