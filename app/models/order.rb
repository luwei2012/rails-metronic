class Order < ActiveRecord::Base
  belongs_to :discount
  has_one :score_record, :dependent => :destroy
  has_many :score_notifications, :through => :score_record
  belongs_to :user
  has_many :order_notifications, :dependent => :destroy
  validates :order_number, presence: true
  validates :order_number, uniqueness: true

  NOT_READ = 0
  READED = 1

  ORDER = 0
  CANCLE_ORDER = 1
  CHECK_ORDER = 2

  def generate_token(column)
    begin
      self[column]=random_intCode
    end while Order.exists?(column => self[column])
  end

end
