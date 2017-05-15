class PromotionSerializer < ActiveModel::Serializer
    attributes :name, :start_date, :end_date
end
