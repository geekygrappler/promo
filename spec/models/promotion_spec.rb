require 'rails_helper'

describe Promotion, type: :model do
  let(:promotion) { Promotion.create(
    name: 'test',
    start_date: Time.now
  )}
  describe 'creation' do
    it 'sets the start_date to the current time if not present' do
      promotion = Promotion.create(start_date: nil)

      expect(promotion.start_date.to_s).to eq(Time.now.utc.to_s)
    end

    it 'will always have a PromotionPeriodConstraint' do
      expect(promotion.constraints.count).to eq(1)
      expect(promotion.constraints.first).to eq('PromotionPeriodConstraint')
    end
  end

  describe 'adding a constraint' do
    it 'should add a constraint' do
      constraint = 'SpecificCustomerConstraint'
      promotion.add_constraint(constraint)

      expect(promotion.constraints.count).to eq(2)
      expect(promotion.constraints.last).to eq(constraint)
    end

    it 'should replace an existing constraint with the new constraint' do
      constraint = 'MinimumBasketTotalConstraint'
      promotion.add_constraint(constraint, { minimum_basket_total: 100 })
      promotion.add_constraint(constraint, { minimum_basket_total: 100.50 })

      expect(promotion.constraints.count).to eq(2)
      expect(promotion.constraints.last).to eq(constraint)
      expect(promotion.minimum_basket_total).to eq(100.50)
    end
  end

  describe 'adding a modifier' do
    let(:modifier) {'TotalAbsoluteModifier'}
    it 'should add a modifier' do
      promotion.add_modifier(modifier, { total_absolute_discount: 20 })

      expect(promotion.modifiers.count).to eq(1)
      expect(promotion.modifiers.first).to eq(modifier)
      expect(promotion.total_absolute_discount).to eq(20)
    end

    it 'should replace an exisiting modifier with the new modifier' do
      promotion.add_modifier(modifier, { total_absolute_discount: 20 })
      promotion.add_modifier(modifier, { total_absolute_discount: 30 })

      expect(promotion.modifiers.count).to eq(1)
      expect(promotion.modifiers.first).to eq(modifier)
      expect(promotion.total_absolute_discount).to eq(30)
    end
  end
end
