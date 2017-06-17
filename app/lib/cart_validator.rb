class CartValidator
  attr_reader :errors

  def initialize
    @errors = []
  end

  def validate(promocode, cart)
    @errors = promocode.promotion.modifiers.map { |modifier|
      modifier.validate(cart)
    }.select{ |error| !error.nil? }
  end

  def valid?
    @errors.empty?
  end
end