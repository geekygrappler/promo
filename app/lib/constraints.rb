# List of Constraints and their intended purpose
#
# SinglePromocodeConstraint: Promotion can only have 1 promocode associated with it.
#
# UniqueCustomerGenerationConstraint: A Customer can only have 1 promocode associated to the Promotion
#
# SpecificCustomerConstraint: Can only be used by the Customer who owns it.


module Constraints
  # Abstract class for a constraint
  # Code smell I don't think I should have an abstract class.
  class Constraint

    # This will be called only when pricing a promocode or generating one so promotion and promocode will always be available.
    # def initialize(promotion, promocode)
    #
    # end

    # Check the submitted promocode is valid to be generated
    def validate_generation(promocode)
      nil
    end

    # Check the submitted promocode is valid for pricing
    def validate_pricing(promocode, submitted_promocode = nil, cart = nil)
      nil
    end
  end

  # What is a Specific Customer Constraint?
  # It means any customer is entitled to the promotion, but a promocode must be linked to customer email
  # this means a customer email must be provided at time of generation, and that specific promocode can
  # only be redeemed by that customer.
  class SpecificCustomerConstraint < Constraint
    def validate_generation(promocode)
      # This is the case when we are generating a promocode but not supplying a customer email (dev error)
      if promocode.customer_email.nil?
        return SpecificCustomerConstraintError.new('This promotion requires a customer email, please supply one')
      end
    end

    def validate_pricing(promocode, submitted_promocode = nil, cart = nil)
      # This is the case when we are pricing a promocode but not supplying a customer email (dev error)
      if submitted_promocode && submitted_promocode[:customer_email].nil?
        return SpecificCustomerConstraintError.new('This promotion requires a customer email, please supply one')
      end

      # Is not valid if the submitted promocode customer email does not equal the saved promocode customer email (customer error)
      if promocode.customer_email != submitted_promocode[:customer_email]
        return SpecificCustomerConstraintError.new('This promocode doesn\'t belong to this customer')
      end
    end
  end

  class SinglePromocodeConstraint < Constraint
    def validate_generation(promocode)
      promotion = promocode.promotion
      if !promotion.promocodes.empty?
        return SinglePromocodeError.new('This promotion is limited to one promocode and already has one')
      end
    end
  end

  # What is a One Per Customer Constraint?
  # It means any customer is entitled to the promotion, but a promocode will be linked to a customer email
  # and they can only have one promocode.
  class OnePerCustomerConstraint < Constraint
    def validate_generation(promocode)
      if promocode.promotion.promocodes.include?(Promocode.find_by(code: promocode.code))
        ConstraintError.new('This promotion already has a promocode with this code')
      end
    end

    def validate_pricing(promocode, submitted_promocode, cart = nil)
      # TODO This method can be composed, i.e. this is a constraint that requires an email as does SinglePromocodeConstraint
      # So don't use inheritence. Sandi Metz
      if submitted_promocode && submitted_promocode[:customer_email].nil?
        return SpecificCustomerConstraintError.new('This promotion requires a customer email, please supply one')
      end

      if (cart && Redemption.find_by(user_cart_id: cart.user_cart_id))
        return UniqueCustomerGenerationError.new('You have already redeemed this discount and it\'s limited to one use per person')
      end
    end
  end

  class PromotionPeriodConstraint < Constraint
    def validate_generation(promocode)
      promotion = promocode.promotion
      if promotion.end_date && promotion.end_date < Time.now
        return PromotionPeriodError.new('This promotion has ended')
      end
    end

    def validate_pricing(promocode, submitted_promocode = nil, cart = nil)
      promotion = promocode.promotion
      # binding.pry
      if promotion.end_date && promotion.end_date < Time.now
        return PromotionPeriodError.new('This promotion has ended')
      end
      if promotion.start_date > Time.now
        return PromotionPeriodError.new("This promotion has not started, it starts on #{promotion.start_date.to_s}")
      end
    end
  end

  class MinimumBasketTotalConstraint < Constraint
    attr_reader :total

    def validate_pricing(promocode, submitted_promocode, cart)
      if (cart.total) < promocode.promotion.minimum_basket_total
        return MinimumBasketTotalConstraintError.new("This promotion requires a minimum basket total of #{promocode.promotion.minimum_basket_total}, the current basket is only #{cart.total}")
      end
    end
  end

  class ConstraintError
    attr_reader :message
    def initialize(message)
      @message = message
    end
  end

  class SpecificCustomerConstraintError < ConstraintError
  end

  class UniqueCustomerGenerationError < ConstraintError
  end

  class SinglePromocodeError < ConstraintError
  end

  class PromotionPeriodError < ConstraintError
  end

  class MinimumBasketTotalConstraintError < ConstraintError
  end
end