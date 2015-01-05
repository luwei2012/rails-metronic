class DiscountDiscountType < ActiveRecord::Base
  belongs_to :discount
  belongs_to :discount_type
end
