# encoding: utf-8
class Validator < ActiveModel::Validator


  REGEXP = Regexp.new(/^[a-zA-Z0-9\u4e00-\u9fa5]+$/)
  FLOAT_NUMERIC_REGEXP = Regexp.new(/^[1-9]\d*\.\d*|0\.\d*[1-9]\d*$/)
  INTEGER_NUMERIC_REGEXP = Regexp.new(/^[1-9]\d*$/)
  EMAIL_REGEXP = Regexp.new(/\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/)
  HTML_REGEXP = Regexp.new(/"<[^>]*>"/)
  NUMERIC_REGEXP = Regexp.new(/^\d{3,4}$/)
  IMAGE_REGEXP = Regexp.new(/[^\s]+(\.(?i)(jpg|png|gif|bmp|jpeg))$/)
  VIDEO_REGEXP = Regexp.new(/[^\s]+(\.(?i)(mkv|avi|AVI|wmv|WMV|flv|FLV|mpg|MPG|mp4|MP4|mov))$/)

  def validate(record)

  end

  ##校验discount
  def job_validate(record)
    #
    if record.name.blank?
      record.errors.add(:error_message, '职位不能为空')
      #else
      #  if not REGEXP.match(record.title)
      #    record.errors.add(:error_message , "推荐标题不能包含+%&\\等特殊符号")
      #  end
    end

  end
  #

end