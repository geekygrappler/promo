class Single < Promotion
  # This promotion should only have one promocode ever.
  # self.promocodes.first
  def magic
    puts "hello world"
  end
end