# A Cart object. Not an ActiveRecord Model. To be instantiated on API request
class Cart
  attr_reader :delivery_total, :item_total, :total

  # @param [Hash] cart hash of a customers cart passed by user via the api
  def initialize(cart)
    @delivery_total = cart[:'delivery-total'] ? BigDecimal(cart[:'delivery-total']) : nil
    @item_total = cart[:'item-total'] ? BigDecimal(cart[:'item-total']) : nil
    @total = cart[:'total'] ? BigDecimal(cart[:'total']) : calculate_cart_total
  end

  private

  def calculate_cart_total
    @delivery_total + @item_total
  end
end