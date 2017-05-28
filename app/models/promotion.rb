class Promotion < ApplicationRecord
  belongs_to :user

  # validates :end_date, presence: true
  before_validation :set_blank_start_date

  private

  def set_blank_start_date
    binding.pry
    if self.start_date.nil?
      # This will depend on the server Rails is runnign on, will give that TZ
      # Should set to TZ of the person making the request.
      self.start_date = Time.now
    end
  end

end
