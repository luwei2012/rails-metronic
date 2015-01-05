class ScoreNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :score_record
end
