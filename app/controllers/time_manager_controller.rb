class TimeManagerController < ApplicationController
  layout 'manager'
  before_filter :check_manager

  def index
    @shop = Employee.find(session[:user_id]).shop

    book_records = @shop.book_records.where(created_at: Time.now.midnight)
    if book_records.blank?||book_records.count<1
      @today_book_record = BookRecord.new
      @today_book_record.shop = @shop
      @today_book_record.created_at = Time.now.midnight
      @today_book_record.transaction do
        @today_book_record.save!
      end
    else
      @today_book_record = book_records.take!
    end

    book_records = @shop.book_records.where(created_at: Time.now.midnight+1.day)
    if book_records.blank?||book_records.count<1
      @tomorrow_book_record = BookRecord.new
      @tomorrow_book_record.shop = @shop
      @tomorrow_book_record.created_at = Time.now.midnight+1.day
      @tomorrow_book_record.transaction do
        @tomorrow_book_record.save!
      end
    else
      @tomorrow_book_record = book_records.take!
    end

    @schedule_record = check_schedule_record(@shop)
    @pre_schedule_record = @shop.pre_schedule_record
  end

  def modify
    @shop = Employee.find(session[:user_id]).shop
    @pre_schedule_record = @shop.pre_schedule_record
    if @pre_schedule_record.blank?
      @pre_schedule_record = PreScheduleRecord.new
      @schedule_record = check_schedule_record(@shop)
      TIME_TABLE_LIST.each do |tr_key, tr_value|

        tr_value.each do |key, value|

          @pre_schedule_record[key] = @schedule_record[key]

        end

      end
      @pre_schedule_record.shop = @shop
      @pre_schedule_record.save!
    end
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  def modify_update
    index
    flag = false
    shrink = false
    TIME_TABLE_LIST.each do |tr_key, tr_value|
      tr_value.each do |key, value|
        if params[key].to_i!=@pre_schedule_record[key]
          flag = true
          @pre_schedule_record[key] = params[key].to_i
          if @schedule_record[key] > @pre_schedule_record[key]
            shrink = true
          else
            @schedule_record[key] = @pre_schedule_record[key]
          end
        end
      end
    end

    if flag
      if shrink
        @pre_schedule_record.start_time = Time.now.midnight + 2.days
      end
      @pre_schedule_record.save!
      @schedule_record.save!
    end
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  def book_record
    datetime =Time.at(params[:datetime].to_i)
    p '---------------'+params[:datetime]+'----------'
    employee = Employee.find(session[:user_id])
    shop = employee.shop
    @orders = shop.orders.where(book_time: datetime)
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

end
