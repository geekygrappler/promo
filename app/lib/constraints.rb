module Constraints
  # Abstract class for a constraint
  class Constraint
    def validate
      return true
    end
  end

  class SpecificCustomerConstraint
    # Don't know how this will work yet.
    # Should be called where we have access to @promocode.
    # and can pass in a customer email from the request.

    def initialize(customer_email)
      @customer_email = customer_email
    end

    def validate customer_email
      @promocode.customer_email === customer_email
    end
  end

  class ConstraintError
    attr_reader :message
  end

  class SpecificCustomerConstraintError < ConstraintError
    def initialize
      @message = 'This promotion requires a customer email address'
    end
  end

  class UniqueCustomerGenerationError < ConstraintError
    def initialize
      @message = 'This customer already has a promocode for this promotion, and it\'s limited to one per customer'
    end
  end

  class SinglePromocodeError < ConstraintError
    def initialize
      @message = 'This promotion is limited to one promocode and already has one'
    end
  end
end