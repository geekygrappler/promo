class CartValidator
  attr_reader :errors

  def initialize
    @errors = []
  end

  # Modifiers need certain things to be present in a cart, this validates that they are before you can
  # price a cart.
  #
  # @param [Promocode] promocode
  # @cart [OldCart] cart
  # @return [Array] Array of Error objects
  def validate(promocode, cart)
    @errors = promocode.promotion.modifiers.map { |modifier|
      modifier.validate(cart)
    }.select{ |error| !error.nil? }
  end

  def valid?
    @errors.empty?
  end
end