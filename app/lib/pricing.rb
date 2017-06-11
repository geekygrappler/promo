module Pricing

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