require 'arel/null_order_predications'
require 'active_relation/errors'
require 'active_relation/version'

module ActiveRelation
  autoload :Model,               'active_relation/model'
  autoload :Relation,            'active_relation/model'

  autoload :Fields,              'active_relation/model'
  autoload :Associations,        'active_relation/model'

  autoload :Query,               'active_relation/model'
  autoload :Select,              'active_relation/model'
  autoload :Join,                'active_relation/model'
  autoload :Order,               'active_relation/model'
  autoload :Limit,               'active_relation/model'
  autoload :Where,               'active_relation/model'
  autoload :Group,               'active_relation/model'
  autoload :Execute,             'active_relation/model'
  autoload :CreateUpdateDestroy, 'active_relation/model'

  autoload :EmptyNode,           'active_relation/model'
  autoload :NodeScope,           'active_relation/model'
  autoload :Regexp,              'active_relation/model'
end
