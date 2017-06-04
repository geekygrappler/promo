class Promotion < ApplicationRecord
  include Constraints
  belongs_to :user
  has_many :promocodes

  validates :start_date, presence: true

  before_validation :set_blank_start_date

  # Add a constraint to list of constraints
  def add_constraint(constraint)
    constraints = self.constraints
    if constraints.nil?
      new_constraints = constraint
    else
      new_constraints = constraints + ',' + constraint
    end
    self.constraints = new_constraints
  end

  # @return [Promocode || Array<ConstraintError>] Unsaved promocode record
  def generate_promocode(submitted_promocode)
    promocode = Promocode.new(
      code: ('a'..'z').to_a.shuffle[0,8].join,
      customer_email: submitted_promocode[:'customer-email'],
      promotion_id: self.id
    )
    errors = promocode.constraint_errors(submitted_promocode)
    if errors.any?
      return errors
    end
    return promocode
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
