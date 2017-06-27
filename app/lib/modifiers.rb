

module Modifiers
  #TODO do these need precedence?
  class Modifier

    # @param [OldCart] cart
    # @return [OldCart] the same cart with the modifier applied to it.
    def apply(cart)
      return cart
    end

    def validate(cart)
      return true
    end
  end

  class PercentageModifier < Modifier
    def initialize(percentage)
      @percentage = percentage.to_d/100.to_d
    end
  end

  class AbsoluteTotalModifier < Modifier
    def apply(cart)
      return cart
    end
  end

  class PercentageItemsModifier < PercentageModifier
    def apply(cart)
      cart.item_total = cart.item_total * (1 - @percentage)
      cart
    end

    def validate(cart)
      if cart.item_total.nil?
        return PercentageItemsModifierError.new('This promocode requires an item total to be passed in the request')
      end
    end
  end

  class PercentageDeliveryModifier < PercentageModifier
    def apply(cart)
      cart.delivery_total = cart.delivery_total * (1 - @percentage)
      cart
    end

    def validate(cart)
      if cart.delivery_total.nil?
        return PercentageDeliveryModiferError.new('This promocode requires a deliver total to be passed in the request')
      end
    end
  end

  class ModifierError
    attr_reader :message
    def initialize(message)
      @message = message
    end
  end

  class PercentageItemsModifierError < ModifierError
  end

  class PercentageDeliveryModiferError < ModifierError
  end
end