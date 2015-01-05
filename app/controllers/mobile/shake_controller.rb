class Mobile::ShakeController < Mobile::BaseController
  DEFAULT_DISTANCE = 5000

  def check_schedule_record(shop)
    schedule_record = shop.schedule_record
    if schedule_record.blank?
      schedule_record = ScheduleRecord.new()
      schedule_record.shop = shop
      schedule_record.save!
    end
    return schedule_record
  end

  def check_book_record(shop, date)
    book_records = shop.book_records.where(created_at: date)
    if book_records.blank?
      book_record = BookRecord.new
      book_record.shop = shop
      book_record.created_at = date
      BookRecord.transaction do
        book_record.save!
      end
    else
      book_record = book_records.take!
    end
    return book_record
  end

  # 摇一摇
  def shake
    page_size = params[:page_size] ? params[:page_size].to_i : 1
    longitude = params[:longitude].to_f
    latitude = params[:latitude].to_f
    page = (params[:page].blank?) ? 0 : params[:page].to_i
    #满足条件的店铺列表
    shop_list = []
    Shop.find_each(batch_size: 100) do |shop|
      #距离条件
      distance = shop.get_distance(longitude, latitude)
      if distance <= DEFAULT_DISTANCE
        shop_list<<shop
      end
    end

    type_sql = "name LIKE '%7座%' or name LIKE '%SUV%' or name LIKE '%5座%' or name LIKE '%洗车%'"
    discount_types = DiscountType.where(type_sql)
    if discount_types.blank? || discount_types.count<1
      render :json => {:status => -1, :message => "没有找到数据！"}.to_json and return
    end

    if shop_list.count <= 0
      render :json => {:status => -1, :message => "没有找到数据！"}.to_json and return
    end
    shop_array=[]
    if shop_list.count>0
      s_sql= "name LIKE '%5座%'"
      b_sql= "name LIKE '%7座%' or name LIKE '%SUV%'"
      # 用户收藏
      shop_discount_list=[]
      if not session[:user_id].blank?
        user = User.find(session[:user_id])
        user.shops.each do |shop|
          shop_discount_list<< shop.id
        end
      end
      shop_list.each do |shop|
        priority = 5-shop.shop_distance/1000
        b_discounts = shop.discounts.joins(:discount_types).where(b_sql).order('updated_at desc')
        s_discounts = shop.discounts.joins(:discount_types).where(s_sql).order('updated_at desc')
        if not b_discounts.blank?
          b_discount = b_discounts[0]
        end
        if not s_discounts.blank?
          s_discount = s_discounts[0]
        end

        if not b_discount.blank?
          b_discount_hash = {
              :price => b_discount.price,
              :integral => b_discount.integral,
              :content => b_discount.content,
              :sale_price => b_discount.sale_price
          }
        else
          b_discount_hash={}
        end

        if not s_discount.blank?
          s_discount_hash = {
              :price => s_discount.price,
              :integral => s_discount.integral,
              :content => s_discount.content,
              :sale_price => s_discount.sale_price
          }
        else
          s_discount_hash={}
        end
        if shop_discount_list.include? shop.id
          followed = true
        else
          followed = false
        end

        if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
          shop_photo = Document.find(shop.shop_photo).screenshot
        else
          shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
        end
        b_count =(b_discount.blank?||b_discount.orders.blank?) ? 0 : b_discount.orders.count
        s_count =(s_discount.blank?||s_discount.orders.blank?) ? 0 : s_discount.orders.count
        priority += shop.extra_priority

        average_grade = (shop.score_records.blank?) ? 0 : shop.score_records.average(:average_grade)
        if !(b_discount.blank? && s_discount.blank?)
          shop_hash = {
              :name => shop.name,
              :shop_photo => shop_photo,
              :address => shop.address,
              :distance => shop.get_distance(longitude, latitude),
              :order_count => (b_count+s_count),
              :shop_id => shop.id,
              :priority => priority,
              :big_car => b_discount_hash,
              :small_car => s_discount_hash,
              :average_grade => average_grade,
              :longitude => shop.longitude,
              :latitude => shop.latitude,
              :updated_at => ((s_discount.blank?) ? nil : s_discount.updated_at.to_i)||((b_discount.blank?) ? nil : b_discount.updated_at.to_i),
              :car_wash_bookable => shop.car_wash_bookable,
              :meet_needs => shop.car_wash_bookable,
              :telephone_area_code => shop.telephone_area_code,
              :telephone_number => shop.telephone_number,
              :followed => followed
          }
          shop_array<<shop_hash
        end
      end
      #排序
      shop_array.sort_by! { |m| [-m[:priority], -m[:order_count], -m[:average_grade]] }
      # 最大页数
      max_page = shop_array.count/page_size+((shop_array.count%page_size)>0 ? 1 : 0)
      current_page = page % max_page
      shop_array = shop_array[page_size*current_page, page_size]
      if shop_array.blank?
        render :json => {:status => 1, :message => "附件没有店铺了！", :data => []}.to_json and return
      else
        render :json => {:status => 1, :message => "搜索成功！", :data => shop_array}.to_json and return
      end
    else
      render :json => {:status => -1, :message => "附件没有找到店铺！"}.to_json and return
    end

  end

  # 摇一摇详情
  def shake_discount
    longitude = params[:longitude].to_f
    latitude = params[:latitude].to_f
    shop_id = params[:shop_id]
    shop = Shop.find(shop_id)
    s_sql= "name LIKE '%5座%'"
    b_sql= "name LIKE '%7座%' or name LIKE '%SUV%'"
    b_discounts = shop.discounts.joins(:discount_types).where(b_sql).order('updated_at desc')
    s_discounts = shop.discounts.joins(:discount_types).where(s_sql).order('updated_at desc')
    type_sql = "name LIKE '%7座%' or name LIKE '%SUV%' or name LIKE '%5座%' or name LIKE '%洗车%'"
    meet_needs = shake_search_helper(shop, Time.now.midnight, type_sql)
    # 用户收藏
    shop_discount_list=[]
    if not session[:user_id].blank?
      user = User.find(session[:user_id])
      user.shops.each do |shop|
        shop_discount_list<< shop.id
      end
    end
    if not b_discounts.blank?
      b_discount = b_discounts[0]
    end
    if not s_discounts.blank?
      s_discount = s_discounts[0]
    end
    if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
      shop_photo = Document.find(shop.shop_photo).original
    else
      shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
    end
    if shop_discount_list.include? shop.id
      followed = true
    else
      followed = false
    end

    b_count =(b_discount.blank?||b_discount.orders.blank?) ? 0 : b_discount.orders.count
    s_count =(s_discount.blank?||s_discount.orders.blank?) ? 0 : s_discount.orders.count
    images=[]

    if !b_discount.blank?&&!b_discount.documents.blank?
      b_discount.documents.each do |document|
        images<<{:original => document.original}
      end
    end

    if not b_discount.blank?
      b_discount_hash = {
          :title => b_discount.title,
          :discount_id => b_discount.id,
          :content => b_discount.content,
          :price => b_discount.price,
          :discount_photo => images,
          :integral => b_discount.integral,
          :sale_price => b_discount.sale_price
      }
      p b_discount_hash
    else
      b_discount_hash={}
    end
    images=[]
    if !s_discount.blank?&&!s_discount.documents.blank?
      s_discount.documents.each do |document|
        images<<{:original => document.original||document.screenshot}
      end
    end

    if not s_discount.blank?
      s_discount_hash = {
          :title => s_discount.title,
          :discount_id => s_discount.id,
          :content => s_discount.content,
          :price => s_discount.price,
          :integral => s_discount.integral,
          :discount_photo => images,
          :sale_price => s_discount.sale_price
      }
    else
      s_discount_hash={}
    end
    average_grade = (shop.score_records.blank?) ? 0 : shop.score_records.average(:average_grade)
    shop_hash = {
        :shop_id => shop.id,
        :name => shop.name,
        :shop_photo => shop_photo,
        :address => shop.address,
        :big_car => b_discount_hash,
        :small_car => s_discount_hash,
        :distance => shop.get_distance(longitude, latitude),
        :order_count => (b_count+s_count),
        :longitude => shop.longitude,
        :latitude => shop.latitude,
        :average_grade => average_grade,
        :car_wash_bookable => shop.car_wash_bookable,
        :meet_needs => meet_needs,
        :telephone_area_code => shop.telephone_area_code,
        :telephone_number => shop.telephone_number,
        :followed => followed
    }
    render :json => {:status => 1, :message => '洗车服务详情！', :data => shop_hash}.to_json
  end

  private

  def shake_search_helper(shop, date, discount_types)
    if !shop.car_wash_bookable
      return false
    end
    time = Time.now.hour
    if time>17 || time<9
      return false
    end
    schedule_record = check_schedule_record(shop)
    book_record = check_book_record(shop, date)
    column = "time_"+ time.to_s
    # 满足时间条件
    if schedule_record[column] > book_record[column]
      return true
    else
      return false
    end
  end


end
