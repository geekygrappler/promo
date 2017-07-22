# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170718191453) do

  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'api_keys', force: :cascade do |t|
    t.string 'access_token'
    t.bigint 'user_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_api_keys_on_user_id'
  end

  create_table 'carts', force: :cascade do |t|
    t.decimal 'item_total'
    t.decimal 'delivery_total'
    t.string 'user_cart_id'
    t.text 'items'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'discounts', force: :cascade do |t|
    t.bigint 'promocode_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'original_cart_id'
    t.bigint 'discounted_cart_id'
    t.string 'user_cart_id'
    t.bigint 'redemption_id'
    t.index ['discounted_cart_id'], name: 'index_discounts_on_discounted_cart_id'
    t.index ['original_cart_id'], name: 'index_discounts_on_original_cart_id'
    t.index ['promocode_id'], name: 'index_discounts_on_promocode_id'
    t.index ['redemption_id'], name: 'index_discounts_on_redemption_id'
  end

  create_table 'promocodes', force: :cascade do |t|
    t.string 'code'
    t.string 'customer_email'
    t.bigint 'promotion_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['promotion_id'], name: 'index_promocodes_on_promotion_id'
  end

  create_table 'promotions', force: :cascade do |t|
    t.string 'name'
    t.datetime 'start_date'
    t.datetime 'end_date'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'user_id'
    t.string 'constraints'
    t.string 'modifiers'
    t.decimal 'items_percentage_discount', precision: 100, scale: 2
    t.decimal 'delivery_percentage_discount', precision: 100, scale: 2
    t.decimal 'total_percentage_discount', precision: 100, scale: 2
    t.decimal 'items_absolute_discount', precision: 100, scale: 2
    t.decimal 'delivery_absolute_discount', precision: 100, scale: 2
    t.decimal 'total_absolute_discount', precision: 100, scale: 2
    t.index ['user_id'], name: 'index_promotions_on_user_id'
  end

  create_table 'redemptions', force: :cascade do |t|
    t.string 'user_cart_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_foreign_key 'api_keys', 'users'
  add_foreign_key 'discounts', 'promocodes'
  add_foreign_key 'promotions', 'users'
end
