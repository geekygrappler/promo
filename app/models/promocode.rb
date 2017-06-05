class Promocode < ApplicationRecord
  include Constraints
  belongs_to :promotion

  # Returns any errors related to the constraints on the promotion.
  #
  # @param [Hash] submitted_promocode the promocode submitted for validation
  # @return [Array<ConstraintError>]
  def constraint_errors(submitted_promocode)
    self.promotion.constraints.map { |constraint|
      constraint.validate(self, submitted_promocode)
    }.select{ |error| !error.nil? }
  end
  private
end
