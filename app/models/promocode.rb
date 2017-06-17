# It is the responsiblity of the Promocode to find out the constraint errors and apply price modifiers,
# but both Constraints and Modifiers live on the Promocode's parent Promotion
class Promocode < ApplicationRecord
  include Constraints
  belongs_to :promotion

  # Returns any errors related to the constraints on the promotion.
  #
  # @param [Hash] submitted_promocode the promocode submitted for validation
  # @param [Cart] cart optionally pass the submitted cart (not needed for generate_promocode or some constraints)
  # @return [Array<ConstraintError>]
  def constraint_errors(submitted_promocode, cart = nil)
    self.promotion.constraints.map { |constraint|
      constraint.validate(self, submitted_promocode, cart)
    }.select{ |error| !error.nil? } # This is code smell shouldn't have to filter for nil (Null Object Pattern)
  end

  def generate_code
    ('a'..'z').to_a.shuffle[0,8].join
  end

  # Returns a *new* cart that has been modified, we must not mess with passed in cart.
  #
  # @param [Cart] cart the submitted cart
  # @raise [Array<ModifierException>] Reason a cart can't be modified
  # @return [Cart] A new cart that has had it's prices modified according to the promotions modifiers
  def price_cart(cart)
    # errors = self.promotion.modifiers.map { |modifier|
    #   modifier.apply(cart)
    # }
    new_cart = cart.dup
    self.promotion.modifiers.reduce(new_cart) { |cart, modifier|
      modifier.apply(cart)
    }

  end
  private
end
