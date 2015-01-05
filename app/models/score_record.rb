class ScoreRecord < ActiveRecord::Base
  belongs_to :order
  belongs_to :user
  has_many :score_notifications, :dependent => :destroy

  NOT_READ = 0
  READED = 1
end
