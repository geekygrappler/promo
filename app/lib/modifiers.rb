

module Modifiers
  #TODO do these need precedence?
  class Modifier
    # Take cart return a new cart or give an error
    def apply(cart)
      return cart
    end
  end

  class PercentageModifier < Modifier
    def initialize(percentage)
      # TODO do floats work? Check. Make sure we don't get decimal BUGS
      @percentage = percentage.to_f/100.to_f
    end
  end

  class AbsoluteTotalModifier < Modifier
    def apply(cart)
      return cart
    end
  end

  class PercentageItemsModifier < PercentageModifier

    def apply(cart)
      cart.update_attr('item_total', cart.item_total * (1 - @percentage))
      cart
    end
  end

  class PercentageDeliveryModifier < PercentageModifier
    def apply(cart)
      cart.update_attr('delivery_total', cart.delivery_total * (1 - @percentage))
      cart
    end
  end
end