

module Modifiers
  #TODO do these need precedence?
  class Modifier
    # Take cart, copy it and return a new cart or give an error
    def modify(cart)
      return cart
    end
  end

  class AbsoluteTotalModifier < Modifier
    def modify(cart)
      return cart
    end
  end
end