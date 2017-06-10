# A Cart object. Not an ActiveRecord Model. To be instantiated on API request.

# I'm allowing people to mess around with cart values through the Public API. It's not immutable. Maybe this
# will cause problems in the future.
class Cart
  attr_accessor :item_total, :delivery_total
  attr_reader :total
  # @param [Hash] cart hash of a customers cart passed by user via the api
  def initialize(cart)
    @delivery_total = cart[:'delivery-total'] ? Monetize.parse(cart[:'delivery-total']) : nil
    @item_total = cart[:'item-total'] ? Monetize.parse(cart[:'item-total']) : nil
    @total = cart[:'total'] ? Monetize.parse(cart[:'total']) : calculate_cart_total
  end

  # Updates a carts attributes and ensures total also gets updated to reflect new values
  # TODO protect against anything other than delivery_total and item_total being submitted here.
  #
  # @param [String] attr_name name of the attribute to be updated
  # @param [Integer] value new value of the attribute
  # @return [Cart]
  def update_attr(attr_name, value)
    attr_name = create_instance_variable_symbol(attr_name)
    self.instance_variable_set(attr_name, Monetize.parse(value))
    self.instance_variable_set(:@total, calculate_cart_total)
    self
  end
  private

  def create_instance_variable_symbol(sym)
    sym.prepend('@').to_sym
  end

  def calculate_cart_total
    @delivery_total + @item_total
  end
end