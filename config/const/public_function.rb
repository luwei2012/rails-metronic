#格式化时间
def format_datetime(aDatetime)
  if aDatetime
    aDatetime.strftime('%Y年%m月%d日 %H时%M分')
  else
    ''
  end
end

#格式化日期
def format_date(aDatetime)
  if aDatetime
    aDatetime.strftime('%Y年%m月%d日')
  else
    ''
  end
end

#格式化日期(月.日)
def format_date_yd(aDatetime)
  if aDatetime
    aDatetime.strftime('%m月%d日')
  else
    ''
  end
end

def random_string
  (('a'..'z').to_a+(0..9).to_a+('A'..'Z').to_a).shuffle[0,11].join
end

def random_intCode
  ((0..9).to_a+(0..9).to_a+(0..9).to_a+(0..9).to_a+(0..9).to_a).shuffle[0,6].join
end
