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

  # @return Promocode
  def generate_promocode(customer_email = nil)
    promocode = Promocode.new(code: ('a'..'z').to_a.shuffle[0,8].join)
    if self.constraints
      if self.constraints.include?('SpecificCustomer') &&
        customer_email.nil?
        return SpecificCustomerConstraintError.new
      end
      if self.constraints.include?('UniqueCustomerGeneration') &&
        Promocode.find_by_customer_email(customer_email)
        return UniqueCustomerGenerationError.new
      end
      if self.constraints.include?('SinglePromocode') &&
        !self.promocodes.empty?
        return SinglePromocodeError.new
      end
    end
    promocode.customer_email = customer_email
    promocode.promotion = self
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
