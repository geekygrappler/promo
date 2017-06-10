class Promotion < ApplicationRecord
  include Constraints
  include Modifiers

  belongs_to :user
  has_many :promocodes
  serialize :constraints, Array
  serialize :modifiers, Array

  validates :start_date, presence: true

  before_validation :set_blank_start_date
  before_save :add_promotion_period_constraint

  # Add a constraint to the promotion. It will update the constraint if it already exists.
  # @param [Constraint] constraint class
  # @return void
  def add_constraint(constraint)
    # if constraint < Constraints::Constraint
    #   raise(NameError)
    # end
    self.constraints.delete_if { |saved_constraint| saved_constraint.class == constraint.class }
    self.constraints.push(constraint)
  end

  # Add a modifier to the promotion. It will update the modifier if it already exists.
  # @param [Modifier] modifier class
  def add_modifier(modifier)
    self.modifiers.delete_if { |saved_modifier| saved_modifier.class == modifier.class}
    self.modifiers.push(modifier)
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

  # All promotions have period constraint.
  def add_promotion_period_constraint
    self.constraints.push(PromotionPeriodConstraint.new)
  end
end
