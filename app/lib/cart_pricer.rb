class CartPricer
  include Modifiers
  attr_reader :priced_cart

  def initialize
    @priced_cart = nil
  end

  # Returns a *new* cart that has been modified, we must not mess with passed in cart.
  #
  # Only call this on a valid promocode (PromocodeValidator) and a valid cart (CartValidator) OR ELSE!!
  #
  # @param [Cart] cart the submitted cart
  # @param [Promocode] promocode the saved promocode
  # @return [Cart] A new cart that has had it's prices modified according to the promotion linked to the promcode's modifiers
  def price(cart, promocode)
    new_cart = cart.dup
    promotion = promocode.promotion
    @priced_cart = promotion.modifiers.reduce(new_cart) { |new_cart, modifier|
      modifier = Modifiers.const_get(modifier).new(promocode, promotion)
      modifier.apply(new_cart)
    }
    # @priced_cart = promocode.promotion.modifiers.reduce(new_cart) { |new_cart, modifier|
    #   modifier.apply(new_cart)
    # }
  end

  # Returns a Hash with the differences in prices for two carts
  #
  # @param [Cart] original_cart the original cart passed by a user
  # @param [Cart] discounted_cart the cart after all modifiers have been applied
  # @return [Hash]
  def price_difference(original_cart, discounted_cart)
    {
      original_item_total: original_cart.item_total,
      discounted_item_total: discounted_cart.item_total,
      item_discount: (original_cart.item_total - discounted_cart.item_total),
      original_delivery_total: original_cart.delivery_total,
      discounted_delivery_total: discounted_cart.delivery_total,
      delivery_discount: (original_cart.delivery_total - discounted_cart.delivery_total),
      original_total: original_cart.total,
      discounted_total: discounted_cart.total,
      total_discount: (original_cart.total - discounted_cart.total)
    }
  end
end