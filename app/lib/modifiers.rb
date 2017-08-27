module Modifiers
  #TODO do these need precedence?
  class Modifier

    # All modifiers need a promocode and promotion
    # as they'll need to look up properties on one of these.
    # @param [Promocode]
    # @param [Promotion]
    def initialize(promocode, promotion)
      @promocode = promocode
      @promotion = promotion
    end

    # @param [Cart] cart
    # @return [Cart] the same cart with the modifier applied to it.
    def apply(cart)
      return cart
    end

    def validate(cart)
      return true
    end
  end

  class PercentageModifier < Modifier

  end

  # TODO this needs to be implemented
  class TotalAbsoluteModifier < Modifier
    def apply(cart)
      return cart
    end
  end

  class ItemsPercentageModifier < PercentageModifier
    def apply(cart)
      cart.item_total = cart.item_total * (1 - @promotion.items_percentage_discount/100)
      cart
    end

    def validate(cart)
      if cart.item_total.nil?
        return ItemsPercentageModifierError.new('This promocode requires an item total to be passed in the request')
      end
    end
  end

  class DeliveryPercentageModifier < PercentageModifier
    def apply(cart)
      cart.delivery_total = cart.delivery_total * (1 - @promotion.delivery_percentage_discount/100)
      cart
    end

    def validate(cart)
      if cart.delivery_total.nil?
        return DeliveryPercentageModiferError.new('This promocode requires a deliver total to be passed in the request')
      end
    end
  end

  class ModifierError
    attr_reader :message
    def initialize(message)
      @message = message
    end
  end

  class ItemsPercentageModifierError < ModifierError
  end

  class DeliveryPercentageModiferError < ModifierError
  end
end