class OrderManagerController < ApplicationController
  layout 'manager'
  before_filter :check_manager
  before_filter :set_order, :only => [:close, :confirm, :consume]

  def index
    employee = Employee.find session[:user_id]
    @orders = employee.shop.orders
    if not @orders.blank?
      @orders.each do |order|
        order_notifications = order.order_notifications
        if not order_notifications.blank?
          order_notifications.each do |order_notification|
            if order_notification.status == Order::NOT_READ
              order_notification.status = Order::READED
              order_notification.save!
            end
          end
        end

        score_notifications = order.score_notifications
        if not score_notifications.blank?
          score_notifications.each do |score_notification|
            if score_notification.status == ScoreRecord::NOT_READ
              score_notification.status = ScoreRecord::READED
              score_notification.save!
            end
          end
        end
      end
    end
  end

  # 关闭订单
  def close
    @order.status = 3
    @order.remark = '店主主动取消订单。'
    time = @order.book_time
    date_key = Time.new(time.year, time.month, time.day)
    time_zone = 'time_'+time.hour.to_s
    discount = @order.discount
    if !discount.blank?
      book_record = check_book_record(@order.discount.shop, date_key)
      book_record[time_zone]=book_record[time_zone].to_i-1
    end
    begin
      Order.transaction do
        @order.save!
        if !book_record.blank?
          book_record.save!
        end
      end
      order_type_array=[]
      if !discount.blank?
        discount.discount_types.each do |discount_type|
          order_type_array<<discount_type.name
        end
      else
        order_type_array<<'服务已删除'
      end
      order_notifications = @order.order_notifications
      OrderNotification.transaction do
        if not order_notifications.blank?
          order_notifications.each do |order_notification|
            if order_notification.status == Order::NOT_READ
              order_notification.status = Order::READED
              order_notification.save!
            end
          end
        end
      end
      result = {
          :success => 1,
          :id => @order.id,
          :order_number => @order.order_number,
          :order_types => order_type_array,
          :price => @order.price,
          :phone => @order.user.phone,
          :status => @order.status,
          :status_value => ORDER_STATUS[@order.status],
          :average_grade => (@order.score_record.blank?) ? '未评分' : @order.score_record.average_grade,
          :remark => @order.remark,
          :created_at => (@order.created_at.blank?) ? nil : @order.created_at.strftime('%Y年%m月%d日 %H时%M分')
      }
      flag = true
    rescue
      error_message = ''
      @order.errors[:error_message].each do |error|
        if error == @order.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      flag = false
    end
    respond_to do |format|
      format.json {
        if flag==true
          render :json => result.to_json
        else
          render :json => false
        end
      }
      format.any { head :no_content }
    end
  end

  # 确认订单
  def confirm
    @order.status = 0
    @order.remark = '用户付款后请确认消费。'
    begin
      Order.transaction do
        @order.save!
      end
      order_type_array=[]
      discount = @order.discount
      if !discount.blank?
        discount.discount_types.each do |discount_type|
          order_type_array<<discount_type.name
        end
      else
        order_type_array<<'服务已删除'
      end
      order_notifications = @order.order_notifications
      OrderNotification.transaction do
        if not order_notifications.blank?
          order_notifications.each do |order_notification|
            if order_notification.status == Order::NOT_READ
              order_notification.status = Order::READED
              order_notification.save!
            end
          end
        end
      end
      result = {
          :success => 1,
          :id => @order.id,
          :order_number => @order.order_number,
          :order_types => order_type_array,
          :price => @order.price,
          :phone => @order.user.phone,
          :status => @order.status,
          :status_value => ORDER_STATUS[@order.status],
          :average_grade => (@order.score_record.blank?) ? '未评分' : @order.score_record.average_grade,
          :remark => @order.remark,
          :created_at => (@order.created_at.blank?) ? nil : @order.created_at.strftime('%Y年%m月%d日 %H时%M分')
      }
      flag = true
    rescue
      error_message = ''
      @order.errors[:error_message].each do |error|
        if error == @order.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      flag = false
    end
    respond_to do |format|
      format.json {
        if flag==true
          render :json => result.to_json
        else
          render :json => false
        end
      }
      format.any { head :no_content }
    end
  end

  # 消费
  def consume
    @order.status = 2
    @order.remark = ''
    @user = @order.user
    @user.integral+=@order.integral
    time = @order.book_time
    # 应该还有积分奖励
    begin
      Order.transaction do
        @order.save!
        @user.save!
      end
      order_type_array=[]
      discount = @order.discount
      if !discount.blank?
        discount.discount_types.each do |discount_type|
          order_type_array<<discount_type.name
        end
      else
        order_type_array<<'服务已删除'
      end

      result = {
          :success => 1,
          :id => @order.id,
          :order_number => @order.order_number,
          :order_types => order_type_array,
          :price => @order.price,
          :phone => @order.user.phone,
          :status => @order.status,
          :status_value => ORDER_STATUS[@order.status],
          :average_grade => (@order.score_record.blank?) ? '未评分' : @order.score_record.average_grade,
          :remark => @order.remark,
          :created_at => (@order.created_at.blank?) ? nil : @order.created_at.strftime('%Y年%m月%d日 %H时%M分')
      }
      flag = true
    rescue
      error_message = ''
      @order.errors[:error_message].each do |error|
        if error == @order.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      flag = false
    end
    respond_to do |format|
      format.json {
        if flag==true
          render :json => result.to_json
        else
          render :json => false
        end
      }
      format.any { head :no_content }
    end
  end

  def order_notifications
    employee = Employee.find session[:user_id]
    shop = employee.shop
    order_notifications = shop.order_notifications.order('created_at desc')
    order_notification_array=[]
    if not order_notifications.blank?
      order_notifications.each do |order_notification|
        if Order::NOT_READ==order_notification.status
          created_at = order_notification.created_at
          current_time = Time.now
          dis_year = current_time.year - created_at.year
          dis_month = current_time.month - created_at.month
          dis_day = current_time.day - created_at.day
          dis_hour = current_time.hour - created_at.hour
          dis_minute = current_time.min - created_at.min
          if dis_year>1
            time = created_at.strftime('%Y年%m月%d日 %H时%M分')
          elsif dis_month>1
            time = dis_month.to_s+'个月前'
          elsif dis_day>1
            time = dis_day.to_s+'天前'
          elsif dis_hour>1
            time = dis_hour.to_s+'小时前'
          elsif dis_minute>3
            time= dis_minute.to_s+'分钟前'
          else
            time = '刚刚'
          end
          discount = order_notification.order.discount
          order_notification_hash={
              :order_notification_id => order_notification.id,
              :name => order_notification.user.name||order_notification.user.account||order_notification.user.phone,
              :title => (discount.blank?) ? '服务已删除' : discount.title,
              :remark => order_notification.order.remark,
              :order_number => order_notification.order.order_number,
              :type => order_notification.order_notification_type,
              :user_photo => order_notification.user.user_photo||ActionController::Base.helpers.asset_path('default_user.jpg'),
              :created_at => time
          }
          order_notification_array<<order_notification_hash
        end
      end
    end

    respond_to do |format|
      format.json { render :json => {:count => order_notification_array.count, :order_notifications => order_notification_array}.to_json }
      format.any { head :no_content }
    end
  end

  def score_notifications
    employee = Employee.find session[:user_id]
    shop = employee.shop
    score_notifications = shop.score_notifications.order('created_at desc')
    score_notification_array=[]
    if not score_notifications.blank?
      score_notifications.each do |score_notification|
        if ScoreRecord::NOT_READ==score_notification.status
          created_at = score_notification.created_at
          current_time = Time.now
          dis_year = current_time.year - created_at.year
          dis_month = current_time.month - created_at.month
          dis_day = current_time.day - created_at.day
          dis_hour = current_time.hour - created_at.hour
          dis_minute = current_time.min - created_at.min
          if dis_year>1
            time = created_at.strftime('%Y年%m月%d日 %H时%M分')
          elsif dis_month>1
            time = dis_month+'个月前'
          elsif dis_day>1
            time = dis_day+'天前'
          elsif dis_hour>1
            time = dis_hour+'小时前'
          elsif dis_minute>3
            time= dis_minute+'分钟前'
          else
            time = '刚刚'
          end
          score_notification_hash={
              :score_notification_id => score_notification.id,
              :name => score_notification.user.name||score_notification.user.account||score_notification.user.phone,
              :average_grade => score_notification.score_record.average_grade,
              :env_grade => score_notification.score_record.env_grade,
              :speed_grade => score_notification.score_record.speed_grade,
              :service_grade => score_notification.score_record.service_grade,
              :wash_grade => score_notification.score_record.wash_grade,
              :comment => score_notification.score_record.comment,
              :order_number => score_notification.score_record.order.order_number,
              :user_photo => score_notification.user.user_photo||ActionController::Base.helpers.asset_path('default_user.jpg'),
              :created_at => time
          }
          score_notification_array<<score_notification_hash
        end
      end
    end

    respond_to do |format|
      format.json { render :json => {:count => score_notification_array.count, :score_notifications => score_notification_array}.to_json }
      format.any { head :no_content }
    end
  end

  private

  def set_order
    begin
      @order = Order.find(params[:id])
    rescue
      error_message = ''
      @order.errors[:error_message].each do |error|
        if error == @order.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      return false
    end

  end

end
