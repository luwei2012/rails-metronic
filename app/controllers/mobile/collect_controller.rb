class Mobile::CollectController < Mobile::BaseController

  before_filter :check_login
  before_action :set_user, :only => [:follow_discount, :follow_brand, :follow_shop, :user_fav_discounts, :user_fav_shops, :praise_discount]

  # 收藏
  def follow_shop
    shop_id = params[:shop_id].to_i
    flag = (params[:flag].blank?) ? true : (params[:flag]=='true')
    if !shop_id.blank? && Shop.exists?(shop_id)
      shop = Shop.find(shop_id)
      if flag
        if !@user.shops.exists?(shop)
          @user.shops<<shop
          @user.save!
          render :json => {:status => 1, :message => "收藏店铺成功！", :followed => true, :follow_count => shop.users.count}.to_json and return
        else
          render :json => {:status => 1, :message => "已经收藏过该店铺！", :followed => true, :follow_count => shop.users.count}.to_json and return
        end
      else
        if @user.shops.exists?(shop)
          @user.shops.delete(shop)
          @user.save!
          render :json => {:status => 1, :message => "取消收藏成功！", :followed => false, :follow_count => shop.users.count}.to_json and return
        else
          render :json => {:status => 1, :message => "没有收藏过该店铺！", :followed => false, :follow_count => shop.users.count}.to_json and return
        end
      end
    else
      render :json => {:status => -1, :message => "该店铺不存在！"}.to_json and return
    end
  end

  def follow_discount
    discount_id = params[:discount_id].to_i
    flag = (params[:flag].blank?) ? true : (params[:flag]=='true')
    if !discount_id.blank? && Discount.exists?(discount_id)
      discount = Discount.find(discount_id)
      if flag
        if @user.discounts.blank?||!@user.discounts.exists?(discount)
          @user.discounts<<discount
          @user.save!
          render :json => {:status => 1, :message => "收藏服务成功！", :followed => true, :follow_count => discount.users.count}.to_json and return
        else
          render :json => {:status => 1, :message => "已经收藏过该服务！", :followed => true, :follow_count => discount.users.count}.to_json and return
        end
      else
        if !@user.discounts.blank?&&@user.discounts.exists?(discount)
          @user.discounts.delete(discount)
          @user.save!
          render :json => {:status => 1, :message => "取消收藏成功！", :followed => false, :follow_count => shop.users.count}.to_json and return
        else
          render :json => {:status => 1, :message => "没有收藏过该服务！", :followed => false, :follow_count => shop.users.count}.to_json and return
        end
      end
    else
      render :json => {:status => -1, :message => "该服务不存在！"}.to_json and return
    end
  end

  def follow_brand
    brand_id = params[:brand_id].to_i
    flag = (params[:flag].blank?) ? true : (params[:flag]=='true')
    if !brand_id.blank? && Brand.exists?(brand_id)
      brand = Brand.find(brand_id)
      if flag
        if !@user.brands.exists?(brand)
          @user.brands<<brand
          @user.save!
          render :json => {:status => 1, :message => "收藏品牌成功！", :followed => true, :follow_count => brand.users.count}.to_json and return
        else
          render :json => {:status => 1, :message => "已经收藏过该品牌！", :followed => true, :follow_count => brand.users.count}.to_json and return
        end
      else
        if @user.brands.exists?(brand)
          @user.brands.delete(brand)
          @user.save!
          render :json => {:status => 1, :message => "取消收藏成功！", :followed => false, :follow_count => brand.users.count}.to_json and return
        else
          render :json => {:status => 1, :message => "没有收藏过该品牌！", :followed => false, :follow_count => brand.users.count}.to_json and return
        end
      end
    else
      render :json => {:status => -1, :message => "该品牌不存在！"}.to_json and return
    end
  end

  # 赞
  def praise_discount
    discount_id = params[:discount_id].to_i
    flag = (params[:flag].blank?) ? true : (params[:flag]=='true')
    if !discount_id.blank? && Discount.exists?(discount_id)
      discount = Discount.find(discount_id)
      if flag
        if !@user.praise_discounts.exists?(discount)
          @user.praise_discounts<<discount
          @user.save!
          render :json => {:status => 1, :message => "点赞成功！", :praised => true, :praise_count => discount.praises.count}.to_json and return
        else
          render :json => {:status => -1, :message => "已经赞过该服务！", :praised => true, :praise_count => discount.praises.count}.to_json and return
        end
      else
        if @user.praise_discounts.exists?(discount)
          @user.praise_discounts.delete(discount)
          @user.save!
          render :json => {:status => 1, :message => "取消赞成功！", :praised => false, :praise_count => discount.praises.count}.to_json and return
        else
          render :json => {:status => -1, :message => "没有赞过该服务！", :praised => false, :praise_count => discount.praises.count}.to_json and return
        end
      end
    else
      render :json => {:status => -1, :message => "该服务不存在！"}.to_json and return
    end
  end


# 用户收藏列表
  def user_fav_discounts
    page_size = params[:page_size] ? params[:page_size].to_i : 15
    page = (params[:page].blank?) ? 0 : params[:page].to_i
    page = page+1
    discount_praise_list=[]
    @user.praise_discounts.each do |discount|
      discount_praise_list<< discount.id
    end
    discounts = @user.discounts.order('updated_at desc').paginate(:page => page, :per_page => page_size)
    discount_array = []
    discounts.each do |discount|
      shop = discount.shop
      order_count = discount.orders.count
      discount_photo = []
      documents = discount.documents
      if !shop.shop_photo.blank? && Document.exists?(shop.shop_photo)
        shop_photo = Document.find(shop.shop_photo).original
      else
        shop_photo = ActionController::Base.helpers.asset_path('default_shop.jpg')
      end
      if not (documents.blank? || documents.count<1)
        discount_photo << {:original => documents[0].screenshot}
      end
      discount_type_array = []
      discount.discount_types.each do |discount_type|
        discount_type_array<<discount_type.name
      end
      praised = false
      if discount_praise_list.include? discount.id
        praised=true
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
          :average_grade => average_grade,
          :integral => discount.integral,
          :discount_types => discount_type_array,
          :telephone_area_code => shop.telephone_area_code,
          :telephone_number => shop.telephone_number,
          :followed => true,
          :follow_count => discount.users.count,
          :praised => praised,
          :praise_count => discount.praises.count

      }
      discount_array<<discount_hash
    end
    # 排序
    if discount_array.blank?
      render :json => {:status => 1, :message => "没有数据了！", :data => []}.to_json and return
    else
      render :json => {:status => 1, :message => "服务信息列表！", :data => discount_array}.to_json and return
    end

  end

  # 收藏店铺页面
  def user_fav_shops
    page_size = params[:page_size] ? params[:page_size].to_i : 15
    page = (params[:page].blank?) ? 0 : params[:page].to_i
    page = page+1
    longitude = params[:longitude].to_f
    latitude = params[:latitude].to_f
    shops = @user.shops.order('updated_at desc').paginate(:page => page, :per_page => page_size)
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

        shop_hash={
            :shop_id => shop.id,
            :shop_photo => shop_photo,
            :name => shop.name,
            :address => shop.address,
            :order_count => (shop.orders.blank?) ? 0 : shop.orders.count,
            :longitude => shop.longitude,
            :latitude => shop.latitude,
            :followed => true,
            :follow_count => (shop.users.blank?) ? 0 : shop.users.count,
            :updated_at => shop.updated_at.to_i,
            :distance => shop.get_distance(longitude, latitude),
            :average_grade => average_grade
        }
        shop_array<<shop_hash
      end
      #排序
      if shop_array.blank?
        render :json => {:status => 1, :message => "没有数据了！", :data => []}.to_json and return
      else
        render :json => {:status => 1, :message => "品牌店铺列表！", :data => shop_array}.to_json and return
      end
    end

  end

  private
  def set_user
    @user = User.find(session[:user_id])
  end

end
