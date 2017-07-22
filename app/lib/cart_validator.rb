class CartValidator
  attr_reader :errors

  def initialize
    @errors = []
  end

  # Modifiers need certain things to be present in a cart, this validates that they are before you can
  # price a cart.
  #
  # @param [Promocode] promocode
  # @cart [Cart] cart
  # @return [Array] Array of Error objects
  def validate(promocode, cart)
    @errors = promocode.promotion.modifiers.map { |modifier|
      modifier = Modifiers.const_get(modifier).new(promocode, promocode.promotion)
      modifier.validate(cart)
    }.select{ |error| !error.nil? }
  end

  def valid?
    @errors.empty?
  end
end