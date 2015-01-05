# -*- encoding : utf-8 -*-
ZONE_8_OFFSET = -ActiveSupport::TimeZone[8.0].utc_offset
IMAGE_REGEXP = Regexp.new(/[^\s]+(\.(?i)(jpg|png|gif|bmp|jpeg))$/)
VIDEO_REGEXP = Regexp.new(/[^\s]+(\.(?i)(mkv|avi|AVI|wmv|WMV|flv|FLV|mpg|MPG|mp4|MP4|mov))$/)

ERROR =
    {
        :shopping_error => 901,
        :normal => 900,
        :new_version => 902,
        :server_maintain => 903,
        :download_latest_version => 999,
        :over_3_account => 998,
        :session_error => 997,
    }


MY_KEY = '3da541559918a808c2402bba5012f6c60b27661c' # 用于用户密码加密


CLIENT_TYPE = {
    :iOS => 0,
    :Android => 1,
    :PC => 2,
}

#authority
#权限key-values
ROLE = {
    :admin => 0, #系统管理员
    :wash => 1, #洗车店
    :brand => 2, #品牌/加盟店
}

ORDER_STATUS = {
    0 => '未消费',
    1 => '等待确认',
    2 => '已消费',
    3 => '已取消',
    4 => '已关闭',
}

TIME_RECORD = {
    :time_9 => '9:00 ~ 10:00',
    :time_10 => '10:00 ~ 11:00',
    :time_11 => '11:00 ~ 12:00',
    :time_12 => '12:00 ~ 13:00',
    :time_13 => '13:00 ~ 14:00',
    :time_14 => '14:00 ~ 15:00',
    :time_15 => '15:00 ~ 16:00',
    :time_16 => '16:00 ~ 17:00',
    :time_17 => '17:00 ~ 18:00',
}

TIME_TABLE = {
    :tr_0 => {:time_9 => '9:00 ~ 10:00', :time_10 => '10:00 ~ 11:00', },
    :tr_1 => {:time_11 => '11:00 ~ 12:00', :time_12 => '12:00 ~ 13:00', },
    :tr_2 => {:time_13 => '13:00 ~ 14:00', :time_14 => '14:00 ~ 15:00', },
    :tr_3 => {:time_15 => '15:00 ~ 16:00', :time_16 => '16:00 ~ 17:00', },
    :tr_4 => {:time_17 => '17:00 ~ 18:00', },
}

TIME_TABLE_LIST = {
    :tr_0 => {:time_9 => '9:00 ~ 10:00'},
    :tr_1 => {:time_10 => '10:00 ~ 11:00'},
    :tr_2 => {:time_11 => '11:00 ~ 12:00'},
    :tr_3 => {:time_12 => '12:00 ~ 13:00'},
    :tr_4 => {:time_13 => '13:00 ~ 14:00'},
    :tr_5 => {:time_14 => '14:00 ~ 15:00'},
    :tr_6 => {:time_15 => '15:00 ~ 16:00'},
    :tr_7 => {:time_16 => '16:00 ~ 17:00'},
    :tr_8 => {:time_17 => '17:00 ~ 18:00'},
}

TIME_VALUE = {
    :time_9 => 9,
    :time_10 => 10,
    :time_11 => 11,
    :time_12 => 12,
    :time_13 => 13,
    :time_14 => 14,
    :time_15 => 15,
    :time_16 => 16,
    :time_17 => 17,
}


DOCUMENT_VALUE_KEY = {
    :all => 0,
    :image => 1,
    :video => 2,
    :file => 3,
}

SHOP_STATUS = {
    :car_wash_bookable => "支持在线预约",
}

SHOP_STATUS_NOT = {
    :car_wash_bookable => "不支持在线预约",
}

COMMENT_STATUS ={
    :not_checked => 0,
    :checked => 1,
    :bonus => 2,
}

COMMENT_STATUS_REVERSE ={
    0 => '未审批',
    1 => '已审批',
    2 => '已奖励',
}

COMMENT_STATUS_KEY ={
    0 => '未审核',
    1 => '已审核',
    2 => '已奖励',
}

PRICE_CONDITION ={
    0 => {:start_price => 0, :end_price => 1000000},
    1 => {:start_price => -1, :end_price => 1},
    2 => {:start_price => 0, :end_price => 20},
    3 => {:start_price => 20, :end_price => 50},
    4 => {:start_price => 50, :end_price => 80},
    5 => {:start_price => 80, :end_price => 1000000},
}

MESSAGE_TYPE={
    :new_order => 0,
    :wait_for_check => 1,
    :order_cancel => 2,
    :user_comment => 3,
    :user_score => 4,
}


#缩略图尺寸
class THUMBNAIL_SIZE
  def self.middle_width
    return 413
  end

  def self.middle_height
    return 620
  end

  def self.large_width
    return 600
  end

  def self.large_height
    return 800
  end

  def self.small_width
    return 400
  end

  def self.small_height
    return 300
  end
end


#访问的客户端类型
ANDROID = 1
IPHONE = 2

