class Promocode < ApplicationRecord
  include Constraints
  belongs_to :promotion

  # Returns any errors related to the constraints on the promotion.
  #
  # @param [Hash] submitted_promocode the promocode submitted for validation
  # @param [Hash] submitted_cart optionally pass the submitted cart (not needed for generate_promocode for example)
  # @return [Array<ConstraintError>]
  def constraint_errors(submitted_promocode, submitted_cart = nil)
    self.promotion.constraints.map { |constraint|
      constraint.validate(self, submitted_promocode, submitted_cart)
    }.select{ |error| !error.nil? }
  end
  private
end
