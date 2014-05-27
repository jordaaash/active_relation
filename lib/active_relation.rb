require 'active_relation/errors'
require 'active_relation/version'

module ActiveRelation
  autoload :Model,               'active_relation/model'
  autoload :Fields,              'active_relation/fields'
  autoload :Associations,        'active_relation/associations'

  autoload :Relation,            'active_relation/relation'
  autoload :Query,               'active_relation/query'
  autoload :Select,              'active_relation/select'
  autoload :Join,                'active_relation/join'
  autoload :Order,               'active_relation/order'
  autoload :Limit,               'active_relation/limit'
  autoload :Where,               'active_relation/where'
  autoload :Group,               'active_relation/group'
  autoload :Execute,             'active_relation/execute'
  autoload :CreateUpdateDestroy, 'active_relation/create_update_destroy'
  autoload :Include,             'active_relation/include'

  autoload :EmptyNode,           'active_relation/empty_node'
  autoload :Regexp,              'active_relation/regexp'
end
