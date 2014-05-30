module ActiveRelation
  class ActiveRelationError < StandardError
  end

  class ArgumentError < ActiveRelationError
  end

  class DefinitionError < ActiveRelationError
  end

  class TypeError < ActiveRelationError
  end

  class RelationNotFound < ActiveRelationError
  end

  class ScopeInvalid < ArgumentError
  end

  class ComparisonInvalid < ArgumentError
  end

  class SelectFieldOperationInvalid < ArgumentError
  end

  class OrderDirectionInvalid < ArgumentError
  end

  class NullOrderInvalid < ArgumentError
  end

  class FieldDefinitionInvalid < DefinitionError
  end

  class FieldNotDefined < DefinitionError
  end

  class FieldTypeInvalid < TypeError
  end

  class AliasDefinitionInvalid < ArgumentError
  end

  class AliasNotDefined < DefinitionError
  end

  class AliasTypeInvalid < TypeError
  end

  class AttributeNotDefined < DefinitionError
  end

  class JoinNotDefined < DefinitionError
  end

  class JoinDefinitionInvalid < DefinitionError
  end

  class JoinTypeInvalid < ArgumentError
  end

  class AssociationDefinitionInvalid < DefinitionError
  end

  class AssociationNotDefined < DefinitionError
  end

  class IncludeInvalid < ArgumentError
  end

  class IncludeDefinitionInvalid < DefinitionError
  end

  class ScopeDefinitionInvalid < DefinitionError
  end
end
