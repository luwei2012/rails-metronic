class Mobile::OrderController < Mobile::BaseController

  before_filter :check_login
  before_action :set_user, :only => [:car_wash_order, :order, :my_orders, :cancel, :comment]


  # 下订单
  def order
    discount = Discount.find(params[:discount_id])
    if discount.blank?
      render :json => {:status => -1, :message => '该服务信息不存在！'}.to_json and return
    end
    # 首先验证积分是否足够
    if @user.integral<discount.integral
      render :json => {:status => -1, :message => '账户积分不足！'}.to_json and return
    else
      @user.integral=@user.integral-discount.integral
      order = Order.new
      order.discount = discount
      order.user = @user
      employee = discount.shop.employee
      order_notification = OrderNotification.new
      order_notification.status = Order::NOT_READ
      order.status = 1
      order.remark='请商家尽快联系客户，确认详细信息！'
      message = '请等候商家与您联系！' #   发送通知
      # 创建消息记录
      order_notification.order_notification_type = Order::CHECK_ORDER
      order.is_car_wash = false
      order.price = discount.sale_price||discount.price
      order.integral = discount.integral
      # 产生订单号码
      order.generate_token(:order_number)
      order.book_time = Time.now
      order_notification.order=order
      order_notification.user = @user
      User.transaction do
        @user.save!
        order.save!
        order_notification.save!
      end
      comment = {
          :order_notification_id => order_notification.id,
          :name => order_notification.user.name||order_notification.user.account||order_notification.user.phone,
          :title => order_notification.order.discount.title,
          :remark => order_notification.order.remark,
          :order_number => order_notification.order.order_number,
          :user_photo => order_notification.user.user_photo||ActionController::Base.helpers.asset_path('default_user.jpg'),
          :type => order_notification.order_notification_type,
          :updated_at => '刚刚'
      }
      Fiber.new { WebsocketRails[employee.email].trigger(:order, comment) }.resume
      render :json => {:status => 1, :message => message}.to_json and return
    end
  end

  # 下订单
  def car_wash_order
    discount = Discount.find(params[:discount_id])
    if discount.blank?
      render :json => {:status => -1, :message => '该服务信息不存在！'}.to_json and return
    end
    day_index = params[:day_index].blank? ? 0 : params[:day_index].to_i
    # time_zone="time_"+params[:time_zone].to_s
    time_zone = params[:time_zone].to_i
    # 首先验证时间是否已经过了
    if time_zone>17 || time_zone<9
      # 超过可预约时间了
      render :json => {:status => -1, :message => '可预约时间为9:00之后到18:00之前！'}.to_json and return
    else
      if day_index == 0
        current_time_zone = Time.now.hour.to_i
        if current_time_zone > time_zone
          render :json => {:status => -1, :message => '当前可预约时间为'+current_time_zone.to_s+':00之后,请刷新后重试！'}.to_json and return
        end
      end
      # 进入下面的判断
      time_zone="time_"+time_zone.to_s
    end
    # 验证积分是否足够
    if @user.integral<discount.integral
      render :json => {:status => -1, :message => '账户积分不足！'}.to_json and return
    else
      # 检查是否还有预约量
      book_record = check_book_record(discount.shop, Time.now.midnight+day_index.day)
      schedule_record = check_schedule_record(discount.shop)
      if schedule_record[time_zone]-book_record[time_zone]>0
        @user.integral=@user.integral-discount.integral
        order = Order.new
        order.discount = discount
        order.user = @user
        order_notification = OrderNotification.new
        order_notification.status = Order::NOT_READ
        employee = discount.shop.employee
        order.status = 0
        order_notification.order_notification_type = Order::ORDER
        message = '预约成功，到店消费后，您的积分会返回到您的账户！'
        order.price = discount.sale_price||discount.price
        order.integral = discount.integral
        order.is_car_wash = true
        book_record[time_zone]=book_record[time_zone]+1
        order.book_time = Time.now.midnight+day_index.day+(params[:time_zone].to_i).hour
        # 产生订单号码
        order.generate_token(:order_number)
        order_notification.order=order
        order_notification.user = @user
        User.transaction do
          @user.save!
          order.save!
          book_record.save!
          order_notification.save!
        end
        comment = {
            :order_notification_id => order_notification.id,
            :name => order_notification.user.name||order_notification.user.account||order_notification.user.phone,
            :title => order_notification.order.discount.title,
            :remark => order_notification.order.remark,
            :order_number => order_notification.order.order_number,
            :user_photo => order_notification.user.user_photo||ActionController::Base.helpers.asset_path('default_user.jpg'),
            :type => order_notification.order_notification_type,
            :updated_at => '刚刚'
        }
        Fiber.new { WebsocketRails[employee.email].trigger(:order, comment) }.resume
        render :json => {:status => 1, :message => message, :left_number => (schedule_record[time_zone]-book_record[time_zone])}.to_json and return
      else
        render :json => {:status => -1, :message => '预约完啦，换个时间段吧！', :left_number => 0}.to_json and return
      end
    end
  end

  def my_orders
    page_size = params[:page_size] ? params[:page_size].to_i : 15
    page = (params[:page].blank?) ? 0 : params[:page].to_i
    page = page+1
    order_status = params[:status].blank? ? -1 : params[:status].to_i
    if order_status==-1
      orders = @user.orders.order('updated_at desc').paginate(:page => page, :per_page => page_size)
    else
      orders = @user.orders.where('status=?', order_status).order('updated_at desc').paginate(:page => page, :per_page => page_size)
    end
    order_array = []
    orders.each do |order|
      discount = order.discount
      if !discount.blank?
        documents = discount.documents
        if !documents.blank?&&documents.count>0
          discount_photo = discount.documents[0].screenshot
        elsif Document.exists?(discount.shop.shop_photo)
          discount_photo = Document.find(discount.shop.shop_photo).screenshot
        else
          discount_photo = ActionController::Base.helpers.asset_path('default_document.jpg')
        end
      else
        discount_photo = ActionController::Base.helpers.asset_path('default_document.jpg')
      end
      order_hash={
          :order_id => order.id,
          :order_number => order.order_number,
          :status => order.status,
          :price => order.price,
          :remark => order.remark,
          :updated_at => order.created_at.to_i,
          :discount_id => (discount.blank?) ? nil : discount.id,
          :shop_name => (discount.blank?) ? '该服务已下架' : discount.shop.name,
          :discount_photo => discount_photo,
          :title => (discount.blank?) ? '该服务已下架' : discount.title,
          :is_graded => !order.score_record.blank?,
          :average_grade => (order.score_record.blank?) ? 0 : order.score_record.average_grade,
          :integral => order.integral,
          :book_time => order.book_time.to_i,
          :is_car_wash => order.is_car_wash
      }
      order_array << order_hash
    end
    if order_array.count<=0
      message = '没有订单信息'
    else
      message = ''
    end
    render :json => {:status => 1, :message => message, :data => order_array}.to_json
  end

  def order_detail
    order_id = params[:order_id]
    order = Order.find(order_id)
    discount = order.discount
    if !discount.blank?
      documents = discount.documents
      if !documents.blank?&&documents.count>0
        discount_photo = discount.documents[0].screenshot
      elsif Document.exists?(discount.shop.shop_photo)
        discount_photo = Document.find(discount.shop.shop_photo).screenshot
      else
        discount_photo = ActionController::Base.helpers.asset_path('default_document.jpg')
      end
    else
      discount_photo = ActionController::Base.helpers.asset_path('default_document.jpg')
    end
    order_hash={
        :order_id => order.id,
        :order_number => order.order_number,
        :status => order.status,
        :price => order.price,
        :remark => order.remark,
        :updated_at => order.created_at.to_i,
        :discount_id => (discount.blank?) ? nil : discount.id,
        :shop_name => (discount.blank?) ? '该服务已下架' : discount.shop.name,
        :discount_photo => discount_photo,
        :title => (discount.blank?) ? '该服务已下架' : discount.title,
        :is_graded => !order.score_record.blank?,
        :average_grade => (order.score_record.blank?) ? 0 : order.score_record.average_grade,
        :integral => order.integral,
        :book_time => order.book_time.to_i,
        :is_car_wash => order.is_car_wash
    }
    render :json => {:status => 1, :message => '', :data => order_hash}.to_json
  end

  def cancel
    order_id = params[:order_id]
    order = Order.find(order_id)
    flag = -1
    if order.status == 2
      message = ORDER_STATUS[2]
    elsif order.status == 3
      message = ORDER_STATUS[3]
    elsif order.status == 4
      message = ORDER_STATUS[4]
    else
      flag = 1
      message = ORDER_STATUS[3]
      order.status=3
      order.remark='用户主动取消订单'
      # 将商户的可预约量+1
      discount = order.discount
      if !discount.blank?
        time = order.book_time
        time_zone = 'time_'+time.hour.to_s
        date_key = Time.new(time.year, time.month, time.day)
        book_record = check_book_record(discount.shop, date_key)
        book_record[time_zone]=book_record[time_zone].to_i-1
      end
      employee = order.discount.shop.employee
      order_notification = OrderNotification.new
      order_notification.status = Order::NOT_READ
      order_notification.order_notification_type = Order::CANCLE_ORDER
      order_notification.order=order
      order_notification.user = @user
      Order.transaction do
        order.save!
        order_notification.save!
        if !book_record.blank?
          book_record.save!
        end
      end
      comment = {
          :order_notification_id => order_notification.id,
          :name => order_notification.user.name||order_notification.user.account||order_notification.user.phone,
          :title => (discount.blank?) ? '服务已删除' : discount.title,
          :remark => order_notification.order.remark,
          :order_number => order_notification.order.order_number,
          :user_photo => order_notification.user.user_photo||ActionController::Base.helpers.asset_path('default_user.jpg'),
          :type => order_notification.order_notification_type,
          :updated_at => '刚刚'
      }
      Fiber.new { WebsocketRails[employee.email].trigger(:order, comment) }.resume
    end
    render :json => {:status => flag, :message => message, :canceled => order.status}.to_json
  end

  def comment
    order_id = params[:order_id]
    order = Order.find(order_id)
    average_grade = params[:average_grade]
    if order.score_record.blank?
      flag = 1
      score_record = ScoreRecord.new
      score_record.user = @user
      score_record.order = order
      score_record.average_grade = average_grade
      employee = order.discount.shop.employee
      score_notification = ScoreNotification.new
      score_notification.status = ScoreRecord::NOT_READ
      score_notification.score_record = score_record
      score_notification.user = @user
      Order.transaction do
        order.save!
        score_record.save!
        score_notification.save!
      end
      discount = order.discount
      comment = {
          :score_notification_id => score_notification.id,
          :name => @user.name||@user.account||@user.phone,
          :title => (discount.blank?) ? '服务已删除' : discount.title,
          :remark => order.remark,
          :order_number => order.order_number,
          :user_photo => @user.user_photo||ActionController::Base.helpers.asset_path('default_user.jpg'),
          :average_grade => average_grade,
          :updated_at => '刚刚'
      }
      Fiber.new { WebsocketRails[employee.email].trigger(:score, comment) }.resume
      message='评价成功!'
    else
      flag = -1
      message='评价失败!'
    end
    render :json => {:status => flag, :message => message, :commented => score_record.average_grade}.to_json
  end


  private
  def set_user
    @user = User.find(session[:user_id])
  end


end
