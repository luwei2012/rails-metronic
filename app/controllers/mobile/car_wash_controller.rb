class Mobile::CarWashController < Mobile::BaseController
  DEFAULT_DISTANCE = 5000

  # 我要洗车页面 店铺服务信息列表
  def discounts
    page_size = params[:page_size] ? params[:page_size].to_i : 15
    longitude = params[:longitude].to_f
    latitude = params[:latitude].to_f
    price_condition = params[:price_condition]
    page = (params[:page].blank?) ? 0 : params[:page].to_i
    bigCar = (params[:bigCar].blank?) ? false : params[:bigCar]=='true'
    time_condition = params[:time_condition]
    if bigCar
      sql = "name LIKE '%7座%' or name LIKE '%SUV%'"
    else
      sql = "name LIKE '%5座%'"
    end
    discount_types = DiscountType.where(sql)
    if discount_types.blank? || discount_types.count<1
      render :json => {:status => -1, :message => "没有找到数据！"}.to_json and return
    end

    #满足条件的店铺列表
    shop_list = []
    Shop.find_each(batch_size: 100) do |shop|
      #距离条件
      distance = shop.get_distance(longitude, latitude)
      if distance <= DEFAULT_DISTANCE && discount_search_helper(shop, Time.now.midnight, sql, price_condition, time_condition)
        shop_list<<shop
      end
    end
    shop_array=[]
    if shop_list.count>0
      discount_list=[]
      discount_praise_list=[]
      if not session[:user_id].blank?
        user = User.find(session[:user_id])
        user.shops.each do |shop|
          discount_list<< shop.id
        end
        user.praise_discounts.each do |discount|
          discount_praise_list<< discount.id
        end

      end
      shop_list.each do |shop|
        if not shop.discounts.blank?
          discount = shop.discounts.joins(:discount_types).where(sql).take!
          if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
            shop_photo = Document.find(shop.shop_photo).screenshot
          else
            shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
          end
          count =(discount.orders.blank?) ? 0 : discount.orders.count
          priority = 5-shop.shop_distance/1000
          followed=false
          praised = false
          priority += shop.extra_priority
          if shop.car_wash_bookable
            meet_needs = shop.meet_needs
            if meet_needs
              priority += 5
            else
              priority += 1
            end
          else
            meet_needs = false
          end
          if discount_praise_list.include? discount.id
            praised=true
          end
          if discount_list.include? shop.id
            followed=true
          end
          image_list = []
          documents = discount.documents
          if not (documents.blank? || documents.count<1)
            documents.each do |document|
              document_hash = {:original => document.original}
              image_list << document_hash
            end
          end
          average_grade = (discount.score_records.blank?) ? 0 : discount.score_records.average(:average_grade)
          shop_hash = {
              :name => shop.name,
              :discount_id => discount.id,
              :shop_id => shop.id,
              :shop_photo => shop_photo,
              :price => discount.price,
              :sale_price => discount.sale_price,
              :address => shop.address,
              :distance => shop.get_distance(longitude, latitude),
              :order_count => count,
              :longitude => shop.longitude,
              :latitude => shop.latitude,
              :discount_photo => image_list,
              :priority => priority,
              :updated_at => discount.updated_at.to_i,
              :meet_needs => meet_needs,
              :average_grade => average_grade,
              :telephone_area_code => shop.telephone_area_code,
              :telephone_number => shop.telephone_number,
              :followed => followed,
              :praised => praised,
              :content => discount.content,
              :title => discount.title

          }
          shop_array<<shop_hash
        end

      end
      #排序
      shop_array.sort_by! { |m| [-m[:priority], -m[:order_count]] }
      shop_array = shop_array[page_size*page, page_size]
      if shop_array.blank?
        render :json => {:status => 1, :message => "没有数据了！", :data => []}.to_json and return
      else
        render :json => {:status => 1, :message => "洗车信息列表！", :data => shop_array}.to_json and return
      end
    else
      render :json => {:status => -1, :message => "没有找到数据！"}.to_json and return
    end

  end

  # 我要洗车页面 店铺服务信息列表
  def map_discounts
    longitude = params[:longitude].to_f
    latitude = params[:latitude].to_f
    price_condition = params[:price_condition]
    bigCar = (params[:bigCar].blank?) ? false : params[:bigCar]=='true'
    time_condition = params[:time_condition]

    if bigCar
      sql = "name LIKE '%7座%' or name LIKE '%SUV%'"
    else
      sql = "name LIKE '%5座%'"
    end
    discount_types = DiscountType.where(sql)
    if discount_types.blank? || discount_types.count<1
      render :json => {:status => -1, :message => "没有找到数据！"}.to_json and return
    end

    #满足条件的店铺列表
    shop_list = []
    Shop.find_each(batch_size: 100) do |shop|
      #距离条件
      distance = shop.get_distance(longitude, latitude)
      if distance <= DEFAULT_DISTANCE && discount_search_helper(shop, Time.now.midnight, sql, price_condition, time_condition)
        shop_list<<shop
      end
    end
    shop_array=[]
    if shop_list.count>0
      discount_list=[]
      discount_praise_list=[]
      if not session[:user_id].blank?
        user = User.find(session[:user_id])
        user.shops.each do |shop|
          discount_list<< shop.id
        end
        user.praise_discounts.each do |discount|
          discount_praise_list<< discount.id
        end

      end
      shop_list.each do |shop|
        if not shop.discounts.blank?
          discount = shop.discounts.joins(:discount_types).where(sql).take!
          if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
            shop_photo = Document.find(shop.shop_photo).screenshot
          else
            shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
          end
          count =(discount.orders.blank?) ? 0 : discount.orders.count
          priority = 5-shop.shop_distance/1000
          followed=false
          praised = false
          priority += shop.extra_priority
          if shop.car_wash_bookable
            meet_needs = shop.meet_needs
            if meet_needs
              priority += 5
            else
              priority += 1
            end
          else
            meet_needs = false
          end
          if discount_praise_list.include? discount.id
            praised=true
          end
          if discount_list.include? shop.id
            followed=true
          end
          image_list = []
          documents = discount.documents
          if not (documents.blank? || documents.count<1)
            documents.each do |document|
              document_hash = {:original => document.original}
              image_list << document_hash
            end
          end
          average_grade = (discount.score_records.blank?) ? 0 : discount.score_records.average(:average_grade)
          shop_hash = {
              :name => shop.name,
              :discount_id => discount.id,
              :shop_id => shop.id,
              :shop_photo => shop_photo,
              :price => discount.price,
              :sale_price => discount.sale_price,
              :address => shop.address,
              :distance => shop.get_distance(longitude, latitude),
              :order_count => count,
              :longitude => shop.longitude,
              :latitude => shop.latitude,
              :discount_photo => image_list,
              :priority => priority,
              :updated_at => discount.updated_at.to_i,
              :car_wash_bookable => shop.car_wash_bookable,
              :meet_needs => meet_needs,
              :average_grade => average_grade,
              :telephone_area_code => shop.telephone_area_code,
              :telephone_number => shop.telephone_number,
              :followed => followed,
              :praised => praised,
              :content => discount.content,
              :title => discount.title

          }
          shop_array<<shop_hash
        end

      end
      #排序
      shop_array.sort_by! { |m| [-m[:priority], -m[:order_count]] }
      if shop_array.blank?
        render :json => {:status => 1, :message => "没有数据了！", :data => []}.to_json and return
      else
        render :json => {:status => 1, :message => "洗车信息列表！", :data => shop_array}.to_json and return
      end
    else
      render :json => {:status => -1, :message => "没有找到数据！"}.to_json and return
    end

  end

  # 查看服务信息详情
  def discount
    longitude = params[:longitude].to_f
    latitude = params[:latitude].to_f
    discount_id = params[:discount_id].to_i
    discount_list=[]
    discount_praise_list=[]
    if not session[:user_id].blank?
      user = User.find(session[:user_id])
      user.shops.each do |shop|
        discount_list<< shop.id
      end
      user.praise_discounts.each do |discount|
        discount_praise_list<< discount.id
      end
    end
    if !discount_id.blank?
      discount = Discount.find(discount_id)
      if !discount.blank?
        shop = discount.shop
        documents = discount.documents
        if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
          shop_photo = Document.find(shop.shop_photo).original
        else
          shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
        end
        order_count = discount.orders.count
        distance = shop.get_distance(longitude, latitude)
        image_list = []
        if not (documents.blank? || documents.count<1)
          documents.each do |document|
            document_hash = {:original => document.original}
            image_list << document_hash
          end
        end
        discount_type_array = []
        discount.discount_types.each do |discount_type|
          discount_type_array<<discount_type.name
        end
        followed=false
        praised = false
        if discount_praise_list.include? discount.id
          praised=true
        end
        if discount_list.include? shop.id
          followed=true
        end
        # 剩余预约量
        today_book_record = check_book_record(shop, Time.now.midnight)
        tomorrow_book_record = check_book_record(shop, Time.now.midnight+1.day)
        schedule_record = check_schedule_record(shop)
        book_left={:today => [], :tomorrow => []}
        TIME_VALUE.each do |tr_key, tr_value|
          book_left[:today]<<(schedule_record[tr_key]-today_book_record[tr_key])
        end

        TIME_RECORD.each do |tr_key, tr_value|
          book_left[:tomorrow]<<(schedule_record[tr_key]-tomorrow_book_record[tr_key])
        end
        average_grade = (discount.score_records.blank?) ? 0 : discount.score_records.average(:average_grade)
        discount_hash = {
            :shop_id => shop.id,
            :name => shop.name,
            :discount_id => discount.id,
            :sale_price => discount.sale_price,
            :shop_photo => shop_photo,
            :address => shop.address,
            :title => discount.title,
            :content => discount.content,
            :price => discount.price,
            :distance => distance,
            :order_count => order_count,
            :longitude => shop.longitude,
            :latitude => shop.latitude,
            :updated_at => discount.updated_at.to_i,
            :car_wash_bookable => shop.car_wash_bookable,
            :meet_needs => shop.car_wash_bookable,
            :discount_photo => image_list,
            :discount_types => discount_type_array,
            :average_grade => average_grade,
            :telephone_area_code => shop.telephone_area_code,
            :telephone_number => shop.telephone_number,
            :followed => followed,
            :integral => discount.integral,
            :follow_count => discount.users.count,
            :praised => praised,
            :praise_count => discount.praises.count,
            :book_left => book_left
        }
        render :json => {:status => 1, :message => "服务信息详情！", :data => discount_hash}.to_json and return
      end
    end
    render :json => {:status => -1, :message => " 没有该服务信息 ！ "}.to_json
  end

  private
  # date表示是哪天的book_record，discount_types表示需要查询的服务类型，time_zone表示查询的时段
  def search_help_time(shop, date, discounts, price_condition, time_zone=nil)
    if time_zone.blank?
      meet_time_condition = true
    elsif (time_zone>17 || time_zone<9)
      return false
    else
      meet_time_condition = false
    end

    schedule_record = check_schedule_record(shop)
    book_record = check_book_record(shop, date)
    if !meet_time_condition
      column = "time_"+ time_zone.to_s
    end

    # 满足时间条件
    if meet_time_condition || schedule_record[column] > book_record[column]
      # 价格条件
      if not price_condition.blank?
        price_condition=price_condition.to_i
        start_price = PRICE_CONDITION[price_condition][:start_price]
        end_price = PRICE_CONDITION[price_condition][:end_price]
        if discounts.blank? || discounts.count<1
          return false
        else
          discounts.each do |discount|
            if discount.sale_price>=start_price.to_i && discount.sale_price<=end_price.to_i
              return true
            end
          end
          return false
        end
      else
        return true
      end
    else
      return false
    end
  end

  def discount_search_helper(shop, date, discount_types, price_condition=nil, params_time=nil)
    discounts = shop.discounts.joins(:discount_types).where(discount_types)
    shop.meet_needs = false
    if params_time.blank? || JSON.parse(params_time).blank?
      # 对时间没有要求，查看其他条件
      shop.meet_needs ||= search_help_time(shop, date, discounts, price_condition)
      return shop.meet_needs
    else
      current_time = Time.now
      params_time = JSON.parse(params_time)
      params_time.keys.each do |key|
        sub_time = params_time[key]
        if !sub_time.blank?
          new_date = Time.at(key.to_i)
          dis_year =new_date.year - current_time.year
          dis_month = new_date.month-current_time.month
          dis_day = new_date.day-current_time.day
          date_key = Time.new(new_date.year, new_date.month, new_date.day)
          if not (dis_year.abs != 0 || dis_day<0 || dis_day>1 || dis_month!=0)
            sub_time.each do |time_zone|
              time_zone = time_zone.to_i
              # 查询的时段已经过了当前可预约时段 直接设为false
              if dis_day==0 && (time_zone-current_time.hour)<0
                shop.meet_needs ||= false
              elsif time_zone>8 && time_zone<18
                shop.meet_needs ||= search_help_time(shop, date_key, discounts, price_condition, time_zone)
              else
                shop.meet_needs ||= false
              end
            end
          end
        end
      end
      return shop.meet_needs
    end
  end

end
