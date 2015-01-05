class PreScheduleRecord < ActiveRecord::Base
  belongs_to :shop
  validates :time_9, numericality: { only_integer: true }
  validates :time_10, numericality: { only_integer: true }
  validates :time_11, numericality: { only_integer: true }
  validates :time_12, numericality: { only_integer: true }
  validates :time_13, numericality: { only_integer: true }
  validates :time_14, numericality: { only_integer: true }
  validates :time_15, numericality: { only_integer: true }
  validates :time_16, numericality: { only_integer: true }
  validates :time_17, numericality: { only_integer: true }

  after_initialize do |preScheduleRecord|
    preScheduleRecord.time_9  ||= 0
    preScheduleRecord.time_10 ||= 0
    preScheduleRecord.time_11 ||= 0
    preScheduleRecord.time_12 ||= 0
    preScheduleRecord.time_13 ||= 0
    preScheduleRecord.time_14 ||= 0
    preScheduleRecord.time_15 ||= 0
    preScheduleRecord.time_16 ||= 0
    preScheduleRecord.time_17 ||= 0
  end
end
