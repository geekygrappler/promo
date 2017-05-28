class PromotionSerializer < ActiveModel::Serializer
  attributes :name, :start_date, :end_date, :promotion_type

  def promotion_type
    @object.type
  end
end
