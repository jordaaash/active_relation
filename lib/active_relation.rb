require 'active_relation/errors'
require 'active_relation/version'

module ActiveRelation
  autoload :Model,               'active_relation/model'
  autoload :Relation,            'active_relation/relation'

  autoload :Fields,              'active_relation/fields'
  autoload :Associations,        'active_relation/associations'

  autoload :Query,               'active_relation/query'
  autoload :Select,              'active_relation/select'
  autoload :Join,                'active_relation/join'
  autoload :Order,               'active_relation/order'
  autoload :Limit,               'active_relation/limit'
  autoload :Where,               'active_relation/where'
  autoload :Group,               'active_relation/group'
  autoload :Execute,             'active_relation/execute'
  autoload :CreateUpdateDestroy, 'active_relation/create_update_destroy'

  autoload :EmptyNode,           'active_relation/empty_node'
  autoload :NodeScope,           'active_relation/node_scope'
  autoload :Regexp,              'active_relation/regexp'
end
