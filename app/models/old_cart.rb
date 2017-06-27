# A OldCart object. Not an ActiveRecord Model. To be instantiated on API request.

# I'm allowing people to mess around with cart values through the Public API. It's not immutable. Maybe this
# will cause problems in the future.
class OldCart
  attr_accessor :item_total, :delivery_total
  attr_reader :total


  # @param [Hash] cart hash of a customers cart
  # @return [OldCart]
  def initialize(cart)
    if !(cart[:delivery_total] || cart[:'delivery-total']).nil?
      @delivery_total = (cart[:delivery_total] || cart[:'delivery-total']).to_d
    end
    if !(cart[:item_total] || cart[:'item-total']).nil?
      @item_total = (cart[:item_total] || cart[:'item-total']).to_d
    end
    @total = calculate_cart_total
  end

  # Updates a carts attributes and ensures total also gets updated to reflect new values
  # TODO protect against anything other than delivery_total and item_total being submitted here.
  #
  # @param [String] attr_name name of the attribute to be updated
  # @param [String | BigDecimal | Integer] value new value of the attribute
  # @return [OldCart]
  def update_attr(attr_name, value)
    attr_name = create_instance_variable_symbol(attr_name)
    self.instance_variable_set(attr_name, value.to_d)
    self.instance_variable_set(:@total, calculate_cart_total)
    self
  end
  private

  def create_instance_variable_symbol(sym)
    sym.prepend('@').to_sym
  end

  def calculate_cart_total
    (@delivery_total || 0) + (@item_total || 0)
  end
end