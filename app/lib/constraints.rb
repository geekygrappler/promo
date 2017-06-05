# List of Constraints and their intended purpose
#
# SinglePromocodeConstraint: Promotion can only have 1 promocode associated with it.
#
# UniqueCustomerGenerationConstraint: A Customer can only have 1 promocode associated to the Promotion
#
# SpecificCustomerConstraint: Can only be used by the Customer who owns it.


module Constraints
  # Abstract class for a constraint
  class Constraint
    def validate(promocode, submitted_promocode = nil, submitted_cart = nil)
      return true
    end
  end

  class SpecificCustomerConstraint < Constraint
    # Don't know how this will work yet.
    # Should be called where we have access to @promocode.
    # and can pass in a customer email from the request.

    def validate(promocode, submitted_promocode, submitted_cart = nil)
      # This check must appear before the check against submitted vs saved email
      if submitted_promocode['customer-email'].nil?
        return SpecificCustomerConstraintError.new('This promotion requires a customer email address')
      end
      
      if promocode.customer_email != submitted_promocode['customer-email']
        return SpecificCustomerConstraintError.new('This promocode doens\'t belong to this customer')
      end
    end
  end

  class SinglePromocodeConstraint < Constraint
    def validate(promocode, submitted_promocode, submitted_cart = nil)
      promotion = promocode.promotion
      if !promotion.promocodes.empty?
        return SinglePromocodeError.new('This promotion is limited to one promocode and already has one')
      end
    end
  end

  class UniqueCustomerGenerationConstraint < Constraint
    def validate(promocode, submitted_promocode, submitted_cart = nil)
      if Promocode.find_by_customer_email(submitted_promocode['customer-email'])
        return UniqueCustomerGenerationError.new('This customer already has a promocode for this promotion, and it\'s limited to one per customer')
      end
    end
  end

  class PromotionPeriodConstraint < Constraint
    def validate(promocode, submitted_promocode = nil, submitted_cart = nil)
      promotion = promocode.promotion
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
    def initialize(total)
      @total = total
    end

    def validate(promocode, submitted_promocode, submitted_cart)
      total = submitted_cart['item-total'].to_i + submitted_cart['delivery-total'].to_i
      if (total) < @total
        return MinimumBasketTotalConstraintError.new("This promotion requires a minimum basket total of £#{@total}, the current basket is only £#{total}")
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