class Promocode < ApplicationRecord
  include Constraints
  belongs_to :promotion

  # Returns any errors related to the constraints on the promotion.
  #
  # @param [Hash] submitted_promocode the promocode submitted for validation
  # @return [Array<ConstraintError>]
  def constraint_errors(submitted_promocode)
    constraints = self.promotion.constraints || ""
    constraints.split(',').map { |constraint_name|
      constraint_class = "Constraints::#{constraint_name}Constraint".constantize
      constraint = constraint_class.new
      constraint.validate(self, submitted_promocode)
    }.select{ |error| !error.nil? }
  end

  # Runs through Promocodes constraints and returns error objects or true.
  def satisfies_constraints?(submitted_promocode)
    constraints = self.promotion.constraints
    if constraints.nil?
      return true
    end
    constraints.split(',').each do |constraint_name|
      constraint_class = "Constraints::#{constraint_name}Constraint".constantize
      constraint = constraint_class.new
      error = constraint.validate(self, submitted_promocode)
      if error
        return error
      end
    end
    return true
  end
  private
end
