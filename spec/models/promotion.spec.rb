require 'rails_helper'

RSpec.describe Promocode, type: :model do
  describe 'creation' do
    it 'sets the start_date to the current time if not present' do
      promotion = Promotion.create(start_date: nil)

      binding.pry
      expect(promotion.start_date).to eq(Time.now)
    end
  end
end
