require 'active_support/hash_with_indifferent_access'

module ActiveRelation
  module Include
    def including (associations, arguments = nil, &block)
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
          args        = arguments if args.nil?
          through     = through_associations[association]

          # Lambda hacks are because of this "feature":
          # http://www.ruby-doc.org/core-2.1.1/Proc.html#method-i-lambda-3F
          # https://stackoverflow.com/questions/23945533/why-do-ruby-procs-blocks-with-splat-arguments-behave-differently-than-methods-an
          # http://makandracards.com/makandra/20641-careful-when-calling-a-ruby-block-with-an-array
          included[a] = lambda do |ids|
            ids = [ids] unless include.lambda?
            instance_exec(ids, *args, &include)
            shallow_join_association(through, :inner) if through
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
