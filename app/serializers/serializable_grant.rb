# TODO: determine and populate the proper attributes and relationships for each of these
class SerializableGrant < JSONAPI::Serializable::Resource
  type 'grants'

  has_one :user
  attributes :amount
end
