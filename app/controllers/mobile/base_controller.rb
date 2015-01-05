class Mobile::BaseController < ActionController::Base

  protect_from_forgery :with => :reset_session

  skip_before_filter :verify_authenticity_token

  def check_login
    #logger.info "cookie is #{cookies.to_a}"
    #logger.info "version is#{request.env["HTTP_CVERSION"]}"
    #return if Rails.env != 'production'
    #return if Rails.env != 'production'

    if session[:user_id].blank?
      logger.info 'session timeout OR no cookies in request！'
      render :json => {:status => -1, :message => 'session timeout OR no cookies in request！'}, :status => 900
      return false
    else
      return true
    end
    #if not session[:cas_user]
    #  logger.info "session timeout OR no cookies in request"
    #  redirect_to :controller => :session, :action => :index#, :port => PORT
    #end
    #if not session[:user_id]
    #    logger.info "session timeout OR no cookies in request"
    #    redirect_to :controller => :session, :action => :index#, :port => PORT
    #end
  end

  def check_pre_schedule_record(shop)
    pre_schedule_record = shop.pre_schedule_record
    if !pre_schedule_record.blank?&&!pre_schedule_record.start_time.blank?
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
