# A Cart object. Not an ActiveRecord Model. To be instantiated on API request
class Cart
  attr_reader :total, :item_total, :delivery_total
  # @param [Hash] cart hash of a customers cart passed by user via the api
  def initialize(cart)
    @delivery_total = cart[:'delivery-total'] ? Monetize.parse(cart[:'delivery-total']) : nil
    @item_total = cart[:'item-total'] ? Monetize.parse(cart[:'item-total']) : nil
    @total = cart[:'total'] ? Monetize.parse(cart[:'total']) : calculate_cart_total
  end

  private

  def calculate_cart_total
    @delivery_total + @item_total
  end
end