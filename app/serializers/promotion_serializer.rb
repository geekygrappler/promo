class PromotionSerializer < ActiveModel::Serializer
  attributes :name, :start_date, :end_date, :modifiers, :constraints, :items_percentage_discount,
             :delivery_percentage_discount, :total_percentage_discount, :items_absolute_discount,
             :delivery_absolute_discount, :total_absolute_discount, :minimum_basket_total
end
