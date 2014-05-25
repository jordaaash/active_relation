require 'active_support/dependencies/autoload'
require 'arel/null_order_predications'
require 'active_relation/errors'

module ActiveRelation
  extend ActiveSupport::Autoload

  autoload :Model
  autoload :Relation

  autoload :Fields
  autoload :Associations

  autoload :Query
  autoload :Select
  autoload :Join
  autoload :Order
  autoload :Limit
  autoload :Where
  autoload :Group
  autoload :Execute
  autoload :CreateUpdateDestroy

  autoload :EmptyNode
  autoload :NodeScope
  autoload :Regexp
end
