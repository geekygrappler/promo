class Promocode < ApplicationRecord
  include Constraints
  belongs_to :promotion

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
