class Promotion < ApplicationRecord
  include Constraints
  include Modifiers

  belongs_to :user
  has_many :promocodes
  serialize :constraints, Array
  serialize :modifiers, Array

  validates :start_date, presence: true
  validates :name, presence: true
  validate :promotion_must_contain_promotion_period_constraint


  before_validation :set_blank_start_date, :add_promotion_period_constraint

  # Add a constraint to the promotion. It will update the constraint if it already exists.
  # @param [Constraint] constraint class
  # @return void
  def add_constraint(constraint)
    self.constraints.delete_if { |saved_constraint| saved_constraint.class == constraint.class }
    self.constraints.push(constraint)
    self.save
  end

  # Add a modifier to the promotion. It will update the modifier if it already exists.
  # @param [Modifier] modifier class
  def add_modifier(modifier)
    self.modifiers.delete_if { |saved_modifier| saved_modifier.class == modifier.class}
    self.modifiers.push(modifier)
    self.save
  end


  def promotion_must_contain_promotion_period_constraint
    unless promotion_contains_promotion_period_constraint
      errors.add(:constraints, 'must contain a promotion period constraint')
    end
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
  def promotion_contains_promotion_period_constraint
    self.constraints.select{ |constraint| constraint.kind_of?(PromotionPeriodConstraint) }.count > 0 ? true : false
  end

  def add_promotion_period_constraint
    unless promotion_contains_promotion_period_constraint
      self.constraints << PromotionPeriodConstraint.new
    end
  end
end
