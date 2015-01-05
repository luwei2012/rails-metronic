class User < ActiveRecord::Base
  has_secure_password
  has_many :user_shops, :dependent => :destroy
  has_many :shops, :through => :user_shops
  has_many :user_brands, :dependent => :destroy
  has_many :brands, :through => :user_brands
  has_many :user_discounts, :dependent => :destroy
  has_many :discounts, :through => :user_discounts, :source => :discount
  has_many :user_discount_praises, :dependent => :destroy
  has_many :praise_discounts, :through => :user_discount_praises, :source => :discount
  has_many :orders, :dependent => :nullify
  has_many :comments, :dependent => :destroy
  validates :account, uniqueness: true
  validates :account, :phone, presence: true


  after_initialize do |user|
    user.balance ||= 0
    user.integral ||= 0
    user.sex ||=1
  end

  def generate_token(column)
    begin
      self[column] = random_intCode
    end while User.exists?(column => self[column])
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.user_password_reset(self).deliver
  end

end
