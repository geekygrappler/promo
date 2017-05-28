class Multiple < Promotion
  # This should be the only way a promocode is generated.
  def generate_promocode customer_email
    promocode = Promocode.new(code: ('a'..'z').to_a.shuffle[0,8].join)
    if self.constraints.include?('SpecificCustomer') && customer_email.nil?
      return "Promotion requires an customer email address for the promotion"
    end
    promocode.customer_email = customer_email
    promocode.promotion = self
    return promocode
  end
end