# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

include Constraints
include Modifiers

user = User.create(email: 'andy@prom.io')
ApiKey.create(user: user)

promotion_1 = Promotion.create(name: '10% off item total test', user: user)

promotion_1.add_constraint(SpecificCustomerConstraint.new)
promotion_1.add_modifier(PercentageItemsModifier.new(10))
promotion_1.save

Promocode.create(code: 'WeLoveJohn10', customer_email: 'john@prom.io', promotion: promotion_1)
