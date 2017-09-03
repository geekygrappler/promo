class PromocodeValidator
  include Constraints
  attr_reader :errors

  def initialize
    @errors = []
  end

  def validate_generation(promocode_record = nil)
    @errors = promocode_record.promotion.constraints.map { |constraint|
      constraint = Constraints.const_get(constraint).new
      constraint.validate_generation(promocode_record)
    }.select{ |error| !error.nil? }
  end

  def validate_pricing(promocode_record = nil, submitted_promocode = nil, submitted_cart = nil)
    return @errors.push(ConstraintError.new('Request must include a cart')) if submitted_cart.nil?
    return @errors.push(ConstraintError.new('Submitted cart must include an ID')) if submitted_cart.user_cart_id.nil?

    @errors = promocode_record.promotion.constraints.map { |constraint|
      constraint = Constraints.const_get(constraint).new
      constraint.validate_pricing(promocode_record, submitted_promocode, submitted_cart)
    }.select{ |error| !error.nil? }
  end

  def valid?
    @errors.count === 0
  end
end