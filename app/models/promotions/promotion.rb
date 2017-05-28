class Promotion < ApplicationRecord
  belongs_to :user

  validates :start_date, presence: true

  before_validation :set_blank_start_date

  # Add a constraint to list of constraints
  def add_constraint constraint
    constraints = self.constraints
    if constraints.nil?
      new_constraints = constraint
    else
      new_constraints = constraints + ',' + constraint
    end
    self.constraints = new_constraints
  end

  def can_generate_promocode
    if self.constraints.include?('SpecificUser')
      return
    end
    binding.pry
    return true
  end

  private

  def set_blank_start_date
    if self.start_date.nil?
      # This will depend on the server Rails is running on, will give that TZ
      # Should set to TZ of the person making the request.
      self.start_date = Time.now.utc
    end
  end
end
