class Brand < ActiveRecord::Base
  has_many :user_brands, :dependent => :destroy
  has_many :users, :through => :user_brands
  has_many :shops,:dependent => :nullify
  has_many :discounts, :through => :shops
  validates :name, presence: true
  validates :name, uniqueness: true
end
