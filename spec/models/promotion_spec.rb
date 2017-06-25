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
      expect(promotion.constraints.first.class.to_s).to eq('Constraints::PromotionPeriodConstraint')
    end
  end

  describe 'adding a constraint' do
    let(:constraint) { instance_double('SpecificCustomerConstraint') }
    before(:each) do
      allow(constraint).to receive(:<).and_return(true)
    end
    it 'should add a constraint' do
      promotion.add_constraint(constraint)

      expect(promotion.constraints.count).to equal(2)
      expect(promotion.constraints.last).to equal(constraint)
    end

    # TODO figure out how to do this in ruby. Raise is the key word here. Getting closer.
    # it 'should raise an error if not passed a constraint' do
    #   allow(constraint).to receive(:<).and_return(true)
    #   expect{ promotion.add_constraint('foo') }.to raise_error(NameError)
    # end

    it 'should replace an existing constraint with the new constraint' do
      promotion.add_constraint(constraint)
      new_constraint = instance_double('SpecificCustomerConstraint')
      promotion.add_constraint(new_constraint)

      expect(promotion.constraints.count).to equal(2)
      expect(promotion.constraints.last).to equal(new_constraint)
    end
  end

  describe 'adding a modifier' do
    let(:modifier) { instance_double('AbsoluteTotalModifier')}
    it 'should add a modifier' do
      promotion.add_modifier(modifier)

      expect(promotion.modifiers.count).to eq(1)
      expect(promotion.modifiers.first).to eq(modifier)
    end

    it 'should replace an exisiting modifier with the new modifier' do
      promotion.add_modifier(modifier)
      new_modifier = instance_double('AbsoluteTotalModifier')
      promotion.add_modifier(new_modifier)

      expect(promotion.modifiers.count).to eq(1)
      expect(promotion.modifiers.first).to eq(new_modifier)
    end
  end
end
