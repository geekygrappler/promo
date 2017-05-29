class PromocodeSerializer < ActiveModel::Serializer
  attributes :code, :customer_email
end