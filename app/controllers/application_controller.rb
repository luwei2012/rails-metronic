class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery :with => :exception
  skip_before_filter :verify_authenticity_token
  layout false

  def check_login
    flag = false
    @current_user ||= Employee.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
    if @current_user.blank?
      logger.info 'session timeout OR no cookies in request'
    else
      flag = true
    end
    respond_to do |format|
      if flag
        return true
      else
        format.html { redirect_to :root }
        format.js { render :js => "window.location = '#{root_path}'" }
      end
    end
  end

  def check_manager
    flag = false
    @current_user ||= Employee.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
    if @current_user.blank?
      logger.info 'session timeout OR no cookies in request'
    else
      session[:user_id] = @current_user.id
      session[:admin]=0
      session[:wash]=0
      session[:brand]=0
      @current_user.roles.each do |role|
        if role.authority == ROLE[:admin]
          session[:admin]=1
        elsif role.authority == ROLE[:wash]
          session[:wash]=1
        elsif role.authority == ROLE[:brand]
          session[:brand]=1
        end
      end
      if session[:admin]==1
        logger.info 'not manager'
      else
        flag = true
      end
    end
    respond_to do |format|
      if flag
        return true
      else
        format.html { redirect_to :root }
        format.js { render :js => "window.location = '#{root_path}'" }
      end
    end
  end

  def check_admin
    flag = false
    @current_user ||= Employee.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
    if @current_user.blank?
      logger.info 'session timeout OR no cookies in request'
    else
      session[:user_id] = @current_user.id
      session[:admin]=0
      session[:wash]=0
      session[:brand]=0
      @current_user.roles.each do |role|
        if role.authority == ROLE[:admin]
          session[:admin]=1
        elsif role.authority == ROLE[:wash]
          session[:wash]=1
        elsif role.authority == ROLE[:brand]
          session[:brand]=1
        end
      end
      if session[:admin]==0
        logger.info 'not admin'
      else
        flag = true
      end
    end
    respond_to do |format|
      if flag
        return true
      else
        format.html { redirect_to :root }
        format.js { render :js => "window.location = '#{root_path}'" }
      end
    end
  end

  def check_pre_schedule_record(shop)
    pre_schedule_record = shop.pre_schedule_record
    if !pre_schedule_record.blank? && !pre_schedule_record.start_time.blank?
      if pre_schedule_record.start_time<Time.now
        schedule_record = shop.schedule_record
        TIME_TABLE_LIST.each do |tr_key, tr_value|

          tr_value.each do |key, value|

            schedule_record[key] = pre_schedule_record[key]

          end

        end
        pre_schedule_record.start_time = nil
        schedule_record.save!
        pre_schedule_record.save!
      end
    end
  end

  def check_schedule_record(shop)
    schedule_record = shop.schedule_record
    if schedule_record.blank?
      schedule_record = ScheduleRecord.new()
      schedule_record.shop = shop
      schedule_record.save!
    end
    check_pre_schedule_record(shop)
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


end
