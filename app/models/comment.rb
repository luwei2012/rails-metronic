class Comment < ActiveRecord::Base
  belongs_to :user
  has_many :comment_notifications, :dependent => :destroy

  after_initialize do |comment|
    comment.status ||= COMMENT_STATUS[:not_checked]
    comment.bonus_integral ||= 0
  end

  # :not_checked => '未审核'
  # :checked => '已审核'
  # :bonus => '已奖励'

  NOT_READ = 0
  READED = 1
end
