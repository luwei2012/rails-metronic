class DiscountType < ActiveRecord::Base
  has_many :discount_discount_types, :dependent => :destroy
  has_many :discounts, :through => :discount_discount_types
  validates :name, presence: true
  validates :name, uniqueness: true
  after_initialize do |discount_type|
    discount_type.parent ||=0
  end
end
