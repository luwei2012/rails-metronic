class UserDiscount < ActiveRecord::Base
  belongs_to :discount
  belongs_to :user
end
