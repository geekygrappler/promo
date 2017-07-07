# It is the responsiblity of the Promocode to find out the constraint errors and apply price modifiers,
# but both Constraints and Modifiers live on the Promocode's parent Promotion
class Promocode < ApplicationRecord
  include Constraints
  belongs_to :promotion

  def generate_code
    ('a'..'z').to_a.shuffle[0,8].join
  end
end
