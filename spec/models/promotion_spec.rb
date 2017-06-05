require 'rails_helper'

describe Promocode, type: :model do
  let(:promotion) { Promotion.create(
    name: 'test',
    start_date: Time.now
  )}
  describe 'creation' do
    it 'sets the start_date to the current time if not present' do
      promotion = Promotion.create(start_date: nil)

      expect(promotion.start_date.to_s).to eq(Time.now.utc.to_s)
    end
  end

  describe 'adding a constraint' do
    let(:constraint) { instance_double('SpecificCustomerConstraint') }
    it 'should add a constraint' do
      promotion.add_constraint(constraint)

      expect(promotion.constraints.count).to equal(1)
      expect(promotion.constraints.first).to equal(constraint)
    end

    # TODO figure out how to do this in ruby.
    # it 'should raise an error if not passed a constraint' do
    #   allow(constraint).to receive(:<).and_return(true)
    #   expect{ promotion.add_constraint('foo') }.to raise_error(NameError)
    # end

    it 'should replace an existing constraint with the new constraint' do
      promotion.add_constraint(constraint)
      new_constraint = instance_double('SpecificCustomerConstraint')
      promotion.add_constraint(new_constraint)

      expect(promotion.constraints.count).to equal(1)
      expect(promotion.constraints.first).to equal(new_constraint)
      expect(promotion.constraints.first).not_to equal(constraint)

    end
  end
end
