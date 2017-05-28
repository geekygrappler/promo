require 'rails_helper'

RSpec.describe Promocode, type: :model do
  describe 'creation' do
    it 'sets the start_date to the current time if not present' do
      promotion = Promotion.create(start_date: nil)

      expect(promotion.start_date.to_s).to eq(Time.now.utc.to_s)
    end
  end
end
