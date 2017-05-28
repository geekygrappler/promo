module Constraints
  # Abstract class for a constraint
  class Constraint
    def validate
      return true
    end
  end

  class SpecificCustomer
    # Don't know how this will work yet.
    # Should be called where we have access to @promocode.
    # and can pass in a customer email from the request.
    def validate customer_email
      @promocode.customer_email === customer_email
    end
  end
end