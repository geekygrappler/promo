class Multiple < Promotion
  include Constraints
  # This should be the only way a promocode is generated for a multiple promotion.
  def generate_promocode customer_email
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
    end
    promocode.customer_email = customer_email
    promocode.promotion = self
    return promocode
  end
end