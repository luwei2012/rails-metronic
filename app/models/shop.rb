class Shop < ActiveRecord::Base
  belongs_to :brand
  attr_accessor :shop_distance, :meet_needs
  has_one :employee, :dependent => :destroy
  has_many :user_shops, :dependent => :destroy
  has_many :users, :through => :user_shops
  has_many :discounts, :dependent => :destroy
  has_one :schedule_record, :dependent => :destroy
  has_one :pre_schedule_record, :dependent => :destroy
  has_many :book_records, :dependent => :destroy
  has_many :orders, :through => :discounts
  has_many :order_notifications, :through => :orders
  has_many :score_notifications, :through => :score_records
  has_many :score_records, :through => :orders
  validates :name, uniqueness: true
  validates :name, :address, :longitude, :latitude, presence: true
  after_initialize do |shop|
    shop.car_wash_online_pay_support ||= false
    shop.car_wash_bookable ||=false
    shop.cooperation ||=false
    shop.extra_priority ||= 0
  end

  attr_accessor :file_upload, :time_1, :time_2, :time_3, :time_4, :time_5, :time_6, :time_7, :time_8, :time_9, :time_10, :time_11, :time_12, :time_13, :time_14, :time_15, :time_16, :time_17, :time_18, :time_19, :time_20, :time_21, :time_22, :time_23, :time_24

  EARTH_RADIUS = 6371

  #坐标按照经纬度顺序传值
  def distance(lng1, lat1, lng2, lat2)
    dLat = (lat2-lat1) * Math::PI / 180.0
    dLon = (lng2-lng1) * Math::PI / 180.0
    a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(lat1 * Math::PI / 180.0) * Math.cos(lat2 * Math::PI / 180.0) *
            Math.sin(dLon/2) * Math.sin(dLon/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    distance = EARTH_RADIUS * c *1000
    distance = distance.round #
    return distance
  end

  def get_distance(lng1, lat1)
    self.shop_distance = distance(lng1, lat1, self.longitude, self.latitude)
    return self.shop_distance
  end

end
