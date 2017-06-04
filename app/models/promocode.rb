class Promocode < ApplicationRecord
  include Constraints
  belongs_to :promotion

  # Returns any errors related to the constraints on the promotion.
  #
  # @param [Hash] submitted_promocode the promocode submitted for validation
  # @return [Array<ConstraintError>]
  def constraint_errors(submitted_promocode)
    # We always have Promotion Period to account for.
    self.promotion.add_constraint("PromotionPeriod")
    constraints = self.promotion.constraints
    constraints.split(',').map { |constraint_name|
      constraint_class = "Constraints::#{constraint_name}Constraint".constantize
      constraint = constraint_class.new
      constraint.validate(self, submitted_promocode)
    }.select{ |error| !error.nil? }
  end
  private
end
