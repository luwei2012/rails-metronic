class Discount < ActiveRecord::Base
  belongs_to :shop
  has_many :orders, :dependent => :nullify
  has_many :score_records, :through => :orders
  has_many :documents, :dependent => :destroy
  has_many :user_discount_praises, :dependent => :destroy
  has_many :praises, through: :user_discount_praises, :source => :user
  has_many :user_discounts, :dependent => :destroy
  has_many :users, :through => :user_discounts, :source => :user
  has_many :discount_discount_types, :dependent => :destroy
  has_many :discount_types, :through => :discount_discount_types

  validates :title, :content, presence: true
  after_initialize do |discount|
    discount.integral ||=0
  end

end
