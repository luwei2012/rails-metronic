class Mobile::BrandController < Mobile::BaseController

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

  # 品牌服务页面
  def brand
    # 广告牌
    discounts = Discount.where('hot=?', true)
    brand_discount_array = []
    discount_list=[]
    if not session[:user_id].blank?
      user = User.find(session[:user_id])
      user.discounts.each do |discount|
        discount_list<< discount.id
      end
    end

    if not discounts.blank?
      discounts.each do |discount|
        shop = discount.shop
        order_count = discount.orders.count
        documents = discount.documents
        discount_photo = []
        if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
          shop_photo = Document.find(shop.shop_photo).original
        else
          shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
        end
        if !(documents.blank? || documents.count<1)
          discount_photo << {:original => documents[0].screenshot}
        end
        followed=false
        if discount_list.include? discount.id
          followed=true
        end
        discount_hash = {
            :shop_id => shop.id,
            :name => shop.name,
            :sale_price => discount.sale_price,
            :address => shop.address,
            :discount_id => discount.id,
            :discount_photo => discount_photo,
            :shop_photo => shop_photo,
            :price => discount.price,
            :order_count => order_count,
            :car_wash_bookable => shop.car_wash_bookable,
            :meet_needs => shop.car_wash_bookable,
            :integral => discount.integral,
            :telephone_area_code => shop.telephone_area_code,
            :telephone_number => shop.telephone_number,
            :followed => followed,
            :updated_at => discount.updated_at.to_i
        }
        brand_discount_array<<discount_hash
      end
      # 排序
      brand_discount_array.sort_by! { |m| [-m[:updated_at]] }
    end
    # 为您推荐
    discount_types_sql = "name not LIKE '%7座%' and name not LIKE '%SUV%' and name not LIKE '%5座%' and name not LIKE '%洗车%'"
    discounts = Discount.joins(:discount_types).where(discount_types_sql).order('updated_at desc')
    discount_array = []
    if not discounts.blank?
      discounts.each do |discount|
        shop = discount.shop
        order_count = discount.orders.count
        documents = discount.documents
        discount_photo = []
        if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
          shop_photo = Document.find(shop.shop_photo).original
        else
          shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
        end
        if !(documents.blank? || documents.count<1)
          discount_photo << {:original => documents[0].screenshot}
        end
        priority = shop.extra_priority
        followed=false
        if discount_list.include? discount.id
          priority+=5
          followed=true
        end
        average_grade = (discount.score_records.blank?) ? 0 : discount.score_records.average(:average_grade)
        priority += average_grade
        discount_hash = {
            :shop_id => shop.id,
            :name => shop.name,
            :sale_price => discount.sale_price,
            :address => shop.address,
            :discount_id => discount.id,
            :discount_photo => discount_photo,
            :shop_photo => shop_photo,
            :price => discount.price,
            :order_count => order_count,
            :car_wash_bookable => shop.car_wash_bookable,
            :meet_needs => shop.car_wash_bookable,
            :integral => discount.integral,
            :telephone_area_code => shop.telephone_area_code,
            :telephone_number => shop.telephone_number,
            :followed => followed,
            :follow_count => discount.users.count,
            :praise_count => discount.praises.count,
            :priority => priority,
            :updated_at => discount.updated_at.to_i
        }
        discount_array<<discount_hash
      end
      # 排序
      discount_array.sort_by! { |m| [-m[:priority], -m[:order_count]] }
    end
    discount_array = discount_array[0, 4]
    #   品牌
    brand_priority_array=[]
    shop_brand_priority_array=[]
    if not session[:user_id].blank?
      user = User.find(session[:user_id])
      if not user.brands.blank?
        user.brands.each do |brand|
          brand_priority_array<<brand.id
        end
      end
      if not user.shops.blank?
        user.shops.each do |shop|
          if not shop.brand.blank?
            shop_brand_priority_array<<shop.brand.id
          end
        end
      end
    end
    brands = Brand.all
    brand_array = []
    if not brands.blank?
      brands.each do |brand|
        if !brand.brand_photo.blank? && Document.exists?(brand.brand_photo)
          brand_photo = Document.find(brand.brand_photo).screenshot
        else
          brand_photo = ActionController::Base.helpers.asset_path('default_brand.jpg')
        end
        priority = 0
        if brand_priority_array.include?(brand.id)
          priority += 1
        end
        if shop_brand_priority_array.include?(brand.id)
          priority += 1
        end
        brand_hash = {
            :brand_id => brand.id,
            :name => brand.name,
            :brand_photo => brand_photo,
            :follow_count => (brand.users.blank?) ? 0 : brand.users.count,
            :shop_count => (brand.shops.blank?) ? 0 : brand.shops.count,
            :priority => priority,
            :updated_at => brand.updated_at.to_i
        }
        brand_array<<brand_hash
      end
      #排序
      brand_array.sort_by! { |m| [-m[:priority], -m[:follow_count], -m[:shop_count], -m[:updated_at]] }
    end
    brand_array = brand_array[0, 4]
    discount_types = DiscountType.where('parent=? and name not LIKE ? and name not LIKE ?', 0, "%平台%", "%洗车%").order('updated_at desc')
    discount_type_array = []
    if not discount_types.blank?
      discount_types.each do |discount_type|
        document_id = discount_type.icon
        if !document_id.blank? && Document.exists?(document_id)
          discount_type_photo = Document.find(document_id).screenshot
        else
          discount_type_photo = ActionController::Base.helpers.asset_path('default_discount_type.png')
        end
        discount_type_hash = {
            :discount_type_id => discount_type.id,
            :name => discount_type.name,
            :icon => discount_type_photo
        }
        discount_type_array<<discount_type_hash
      end
    end
    result= {
        :status => 1,
        :message => '请求成功',
        :brand_discount_array => brand_discount_array,
        :discount_array => discount_array,
        :brand_array => brand_array,
        :discount_type_array => discount_type_array
    }
    # 最后结果
    render :json => result.to_json
  end

  # 品牌-商店列表，点击品牌后需要展示商店列表
  def brand_shops
    page_size = params[:page_size] ? params[:page_size].to_i : 15
    page = (params[:page].blank?) ? 0 : params[:page].to_i
    longitude = params[:longitude].to_f
    latitude = params[:latitude].to_f
    brand_id = params[:brand_id]
    brand = Brand.find brand_id
    shops = brand.shops
    shop_priority_array=[]
    if not session[:user_id].blank?
      user = User.find(session[:user_id])
      if not user.shops.blank?
        user.shops.each do |shop|
          shop_priority_array<<shop.id
        end
      end
    end
    if shops.blank? || shops.count<1
      render :json => {:status => -1, :message => '没有找到店铺！'}.to_json and return
    else
      shop_array=[]
      shops.each do |shop|
        average_grade = shop.score_records.average(:average_grade)
        average_grade = (average_grade.blank?) ? 0 : average_grade
        if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
          shop_photo = Document.find(shop.shop_photo).screenshot
        else
          shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
        end
        if shop.cooperation
          priority = shop.extra_priority
        else
          priority = 0
        end
        followed=false
        if shop_priority_array.include?(shop.id)
          followed = true
          priority = priority+1
        end
        shop_hash={
            :shop_id => shop.id,
            :shop_photo => shop_photo,
            :name => shop.name,
            :address => shop.address,
            :order_count => (shop.orders.blank?) ? 0 : shop.orders.count,
            :priority => priority,
            :longitude => shop.longitude,
            :latitude => shop.latitude,
            :followed => followed,
            :follow_count => (shop.users.blank?) ? 0 : shop.users.count,
            :updated_at => shop.updated_at.to_i,
            :distance => shop.get_distance(longitude, latitude),
            :average_grade => average_grade
        }
        shop_array<<shop_hash
      end
      #排序
      shop_array.sort_by! { |m| [-m[:priority], -m[:order_count], -m[:average_grade]] }
      shop_array = shop_array[page_size*page, page_size]
      if shop_array.blank?
        render :json => {:status => 1, :message => "没有数据了！", :data => []}.to_json and return
      else
        render :json => {:status => 1, :message => "品牌店铺列表！", :data => shop_array}.to_json and return
      end
    end

  end

  # 品牌服务页面-点击品牌
  def brands
    page_size = params[:page_size] ? params[:page_size].to_i : 15
    page = (params[:page].blank?) ? 0 : params[:page].to_i
    brand_priority_array=[]
    shop_brand_priority_array=[]
    if not session[:user_id].blank?
      user = User.find(session[:user_id])
      if not user.brands.blank?
        user.brands.each do |brand|
          brand_priority_array<<brand.id
        end
      end
      if not user.shops.blank?
        user.shops.each do |shop|
          if not shop.brand.blank?
            shop_brand_priority_array<<shop.brand.id
          end
        end
      end
    end
    brands = Brand.all
    if brands.blank? || brands.count<1
      render :json => {:status => -1, :message => '没有品牌数据!'}.to_json and return
    else
      brand_array = []
      brands.each do |brand|
        if !brand.brand_photo.blank? && Document.exists?(brand.brand_photo)
          brand_photo = Document.find(brand.brand_photo).screenshot
        else
          brand_photo = ActionController::Base.helpers.asset_path('default_brand.jpg')
        end
        priority = 0
        followed = false
        if brand_priority_array.include?(brand.id)
          priority += 1
          followed = true
        end
        if shop_brand_priority_array.include?(brand.id)
          priority += 1
        end
        brand_hash = {
            :brand_id => brand.id,
            :name => brand.name,
            :brand_photo => brand_photo,
            :follow_count => (brand.users.blank?) ? 0 : brand.users.count,
            :shop_count => (brand.shops.blank?) ? 0 : brand.shops.count,
            :priority => priority,
            :followed => followed,
            :updated_at => brand.updated_at.to_i
        }
        brand_array<<brand_hash
      end
      #排序
      brand_array.sort_by! { |m| [-m[:priority], -m[:follow_count], -m[:updated_at]] }
      brand_array = brand_array[page_size*page, page_size]
      if brand_array.blank?
        render :json => {:status => 1, :message => "没有数据了！", :data => []}.to_json and return
      else
        render :json => {:status => 1, :message => "品牌店铺列表！", :data => brand_array}.to_json and return
      end
    end

  end

  # 品牌服务页面 用户收藏列表
  def recommend_discounts
    page_size = params[:page_size] ? params[:page_size].to_i : 15
    page = (params[:page].blank?) ? 0 : params[:page].to_i
    discount_list=[]
    discount_praise_list=[]
    if not session[:user_id].blank?
      user = User.find(session[:user_id])
      user.discounts.each do |discount|
        discount_list<< discount.id
      end
      user.praise_discounts.each do |discount|
        discount_praise_list<< discount.id
      end
    end
    discount_types_sql = "name not LIKE '%7座%' and name not LIKE '%SUV%' and name not LIKE '%5座%' and name not LIKE '%洗车%' and name not LIKE '%平台%'"
    discounts = Discount.joins(:discount_types).where(discount_types_sql).order('updated_at desc')
    discount_array = []
    discounts.each do |discount|
      documents = discount.documents
      shop = discount.shop
      if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
        shop_photo = Document.find(shop.shop_photo).original
      else
        shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
      end
      order_count = discount.orders.count
      discount_photo = []
      if !(documents.blank? || documents.count<1)
        discount_photo << {:original => documents[0].screenshot}
      end
      discount_types = discount.discount_types
      discount_type_array = []
      discount_types.each do |discount_type|
        discount_type_array<<discount_type.name
      end
      priority = 0
      followed=false
      praised = false
      if discount_praise_list.include? discount.id
        priority+=1
        praised=true
      end
      if discount_list.include? discount.id
        priority+=1
        followed=true
      end
      if !discount.shop.blank?&&discount.shop.cooperation
        priority += discount.shop.extra_priority
      end
      average_grade = (discount.score_records.blank?) ? 0 : discount.score_records.average(:average_grade)
      discount_hash = {
          :shop_id => shop.id,
          :name => shop.name,
          :discount_id => discount.id,
          :sale_price => discount.sale_price,
          :shop_photo => shop_photo,
          :address => shop.address,
          :price => discount.price,
          :order_count => order_count,
          :longitude => shop.longitude,
          :latitude => shop.latitude,
          :content => discount.content,
          :title => discount.title,
          :updated_at => discount.updated_at.to_i,
          :car_wash_bookable => shop.car_wash_bookable,
          :meet_needs => shop.car_wash_bookable,
          :discount_photo => discount_photo,
          :discount_types => discount_type_array,
          :average_grade => average_grade,
          :telephone_area_code => shop.telephone_area_code,
          :telephone_number => shop.telephone_number,
          :followed => followed,
          :follow_count => discount.users.count,
          :praised => praised,
          :praise_count => discount.praises.count,
          :integral => discount.integral,
          :priority => priority
      }
      discount_array<<discount_hash
    end
    # 排序
    discount_array.sort_by! { |m| [-m[:order_count], -m[:priority], -m[:updated_at]] }
    discount_array = discount_array[page_size*page, page_size]
    if discount_array.blank?
      render :json => {:status => 1, :message => "没有数据了！", :data => []}.to_json and return
    else
      render :json => {:status => 1, :message => "服务信息列表！", :data => discount_array}.to_json and return
    end

  end

  # 获取服务信息类型
  def discount_types
    discount_types = DiscountType.where('parent=? and name not LIKE ? and name not LIKE ?', 0, "%平台%", "%洗车%").order('updated_at desc')
    discount_type_array = []
    if not discount_types.blank?
      discount_types.each do |discount_type|
        document_id = discount_type.icon
        if !document_id.blank? && Document.exists?(document_id)
          discount_type_photo = Document.find(document_id).original
        else
          discount_type_photo = ActionController::Base.helpers.asset_path('default_discount_type.png')
        end
        discount_type_hash = {
            :discount_type_id => discount_type.id,
            :name => discount_type.name,
            :icon => discount_type_photo
        }
        discount_type_array<<discount_type_hash
      end
    end
    render :json => {
        :status => 1,
        :message => '获取服务信息类型',
        :discount_type_array => discount_type_array
    }.to_json
  end

  # 获取服务信息类型子类型
  def discount_types_sons
    name = params[:name]
    id = params[:id]
    if not id.blank?
      discount_types = DiscountType.where('parent=?', id).order('updated_at desc')
    else
      discount_type = DiscountType.find_by_name(name)
      discount_types = DiscountType.where('parent=?', discount_type.id).order('updated_at desc')
    end
    discount_type_array = []
    if not discount_types.blank?
      discount_types.each do |discount_type|
        document_id = discount_type.icon
        if !document_id.blank? && Document.exists?(document_id)
          discount_type_photo = Document.find(document_id).original
        else
          discount_type_photo = ActionController::Base.helpers.asset_path('default_discount_type.png')
        end
        discount_type_hash = {
            :discount_type_id => discount_type.id,
            :name => discount_type.name,
            :icon => discount_type_photo
        }
        discount_type_array<<discount_type_hash
      end
    end
    render :json => {
        :status => 1,
        :message => '获取服务信息类型子类型',
        :discount_type_array => discount_type_array
    }.to_json
  end

  # 获取某些服务类型的服务信息
  def discount_types_discounts
    page_size = params[:page_size] ? params[:page_size].to_i : 15
    page = (params[:page].blank?) ? 0 : params[:page].to_i
    discount_type_ids = params[:discount_types]
    discount_type_ids = JSON.parse(discount_type_ids)
    sql = ''
    discount_type_ids.each_with_index do |discount_type_id, index|
      discount_type = DiscountType.find(discount_type_id)
      if index==0
        sql=sql+'discount_type_id='+discount_type.id.to_s
      else
        sql=sql+' or discount_type_id='+discount_type.id.to_s
      end
      if discount_type.parent.blank? || discount_type.parent==0
        sql=sql+' or parent='+discount_type.id.to_s
      end
    end

    discount_array = []
    discount_list=[]
    discount_praise_list=[]

    if not session[:user_id].blank?
      user = User.find(session[:user_id])
      user.discounts.each do |discount|
        discount_list<< discount.id
      end
      user.praise_discounts.each do |discount|
        discount_praise_list<< discount.id
      end

    end
    discounts = Discount.joins(:discount_types).where(sql).order('updated_at desc')
    if not discounts.blank?
      discounts.each do |discount|
        shop = discount.shop
        documents = discount.documents
        if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
          shop_photo = Document.find(shop.shop_photo).original
        else
          shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
        end
        order_count = discount.orders.count
        image_list = []
        if not (documents.blank? || documents.count<1)
          documents.each do |document|
            document_hash = {:original => document.original}
            image_list << document_hash
          end
        end
        discount_types = discount.discount_types
        discount_type_array = []
        discount_types.each do |discount_type|
          discount_type_array<<discount_type.name
        end
        priority = 0
        followed=false
        praised = false
        if discount_praise_list.include? discount.id
          priority+=1
          praised=true
        end
        if discount_list.include? discount.id
          priority+=1
          followed=true
        end
        if !discount.shop.blank?&&discount.shop.cooperation
          priority += discount.shop.extra_priority
        end
        average_grade = (discount.score_records.blank?) ? 0 : discount.score_records.average(:average_grade)
        discount_hash={
            :shop_id => shop.id,
            :name => shop.name,
            :title => discount.title,
            :content => discount.content,
            :discount_id => discount.id,
            :sale_price => discount.sale_price,
            :shop_photo => shop_photo,
            :address => shop.address,
            :price => discount.price,
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
            :follow_count => discount.users.count,
            :praised => praised,
            :praise_count => discount.praises.count,
            :integral => discount.integral,
            :priority => priority
        }
        discount_array << discount_hash
      end
    end
    #排序
    discount_array.sort_by! { |m| [-m[:updated_at], -m[:order_count], -m[:priority]] }
    discount_array = discount_array[page_size*page, page_size]
    if discount_array.blank?
      render :json => {:status => 1, :message => "没有数据了！", :data => []}.to_json and return
    else
      render :json => {:status => 1, :message => "店铺服务列表！", :data => discount_array}.to_json and return
    end
  end

  # 点击店铺进入服务信息列表
  def shop_discounts
    page = (params[:page].blank?) ? 0 : params[:page].to_i
    page_size = params[:page_size] ? params[:page_size].to_i : 15
    page = page + 1
    shop_id = params[:shop_id]
    shop = Shop.find(shop_id)
    if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
      shop_photo = Document.find(shop.shop_photo).original
    else
      shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
    end
    discount_list=[]
    discount_praise_list=[]
    if not session[:user_id].blank?
      user = User.find(session[:user_id])
      user.discounts.each do |discount|
        discount_list<< discount.id
      end
      user.praise_discounts.each do |discount|
        discount_praise_list<< discount.id
      end
    end
    discount_types_sql = "name not LIKE '%7座%' and name not LIKE '%SUV%' and name not LIKE '%5座%' and name not LIKE '%洗车%' and name not LIKE '%平台%'"
    discounts = shop.discounts.joins(:discount_types).where(discount_types_sql).order('updated_at DESC').paginate(:page => page, :per_page => page_size)
    discount_array = []
    discounts.each do |discount|
      documents = discount.documents
      discount_photo = []
      if not (documents.blank? || documents.count<1)
        discount_photo << {:original => documents[0].screenshot}
      end
      discount_types = discount.discount_types
      discount_type_array = []
      discount_types.each do |discount_type|
        discount_type_array<<discount_type.name
      end
      followed=false
      praised = false
      if discount_praise_list.include? discount.id
        praised=true
      end
      if discount_list.include? discount.id
        followed=true
      end
      average_grade = (discount.score_records.blank?) ? 0 : discount.score_records.average(:average_grade)
      discount_hash={
          :shop_id => shop.id,
          :name => shop.name,
          :title => discount.title,
          :content => discount.content,
          :discount_id => discount.id,
          :sale_price => discount.sale_price,
          :shop_photo => shop_photo,
          :address => shop.address,
          :price => discount.price,
          :order_count => discount.orders.count,
          :longitude => shop.longitude,
          :latitude => shop.latitude,
          :updated_at => discount.updated_at.to_i,
          :car_wash_bookable => shop.car_wash_bookable,
          :meet_needs => shop.car_wash_bookable,
          :discount_photo => discount_photo,
          :discount_types => discount_type_array,
          :average_grade => average_grade,
          :telephone_area_code => shop.telephone_area_code,
          :telephone_number => shop.telephone_number,
          :followed => followed,
          :follow_count => discount.users.count,
          :praised => praised,
          :praise_count => discount.praises.count,
          :integral => discount.integral
      }
      discount_array << discount_hash
    end

    #排序
    if discount_array.blank?
      render :json => {:status => 1, :message => "没有数据了！", :data => []}.to_json and return
    else
      render :json => {:status => 1, :message => "店铺服务列表！", :data => discount_array}.to_json and return
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
      user.discounts.each do |discount|
        discount_list<< discount.id
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
        if discount_list.include? discount.id
          followed=true
        end

        average_grade = (discount.score_records.blank?) ? 0 : discount.score_records.average(:average_grade)
        discount_hash = {
            :shop_id => shop.id,
            :name => shop.name,
            :title => discount.title,
            :discount_id => discount.id,
            :sale_price => discount.sale_price,
            :shop_photo => shop_photo,
            :address => shop.address,
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
            :praise_count => discount.praises.count
        }
        render :json => {:status => 1, :message => "服务信息详情！", :data => discount_hash}.to_json and return
      end
    end
    render :json => {:status => -1, :message => " 没有该服务信息 ！ "}.to_json
  end

end
