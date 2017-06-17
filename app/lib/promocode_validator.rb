class PromocodeValidator
  attr_reader :errors

  def initialize
    @errors = []
  end

  def validate(promocode_record = nil, submitted_promocode = nil, submitted_cart = nil)
    @errors = promocode_record.promotion.constraints.map { |constraint|
      constraint.validate(promocode_record, submitted_promocode, submitted_cart)
    }.select{ |error| !error.nil? }
  end

  def valid?
    @errors.count === 0
  end
end