class Promocode < ApplicationRecord
  belongs_to :promotion

  # TODO throw errors if we try and call Promocode.new or Promocode.create
  private
end
