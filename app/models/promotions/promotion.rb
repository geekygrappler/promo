class Promotion < ApplicationRecord
  belongs_to :user

  validates :start_date, presence: true

  before_validation :set_blank_start_date

  private

  def set_blank_start_date
    if self.start_date.nil?
      # This will depend on the server Rails is running on, will give that TZ
      # Should set to TZ of the person making the request.
      self.start_date = Time.now.utc
    end
  end

end
