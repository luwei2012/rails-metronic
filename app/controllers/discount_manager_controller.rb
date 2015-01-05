class DiscountManagerController < ApplicationController
  layout 'manager'
  before_filter :check_manager
  before_filter :set_discount, :only => [:show, :edit, :update, :destroy]
  before_action :set_discount_type, :only => [:index, :new, :edit, :create, :update]

  def index
    @discount_type_id = (params[:discount_type].blank?) ? 0 : params[:discount_type]
    if @discount_type_id == 0
      @discounts = Employee.find(session[:user_id]).shop.discounts
    elsif @discount_type_id == 'discount'
      @discounts = Employee.find(session[:user_id]).shop.discounts.where('discount IS NOT NULL')
    elsif @discount_type_id == 'hot'
      @discounts = Employee.find(session[:user_id]).shop.discounts.where('hot IS NOT NULL and hot=?', true)
    else
      @discounts = Employee.find(session[:user_id]).shop.discounts.joins(:discount_types).where('discount_types.parent=? or discount_types.id = ?', @discount_type_id, @discount_type_id)
    end

  end

  def new
    @discount = Discount.new
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  def show
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  # GET /shops/1/edit
  def edit
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  # POST /shops
  # POST /shops.json
  def create
    @discount = Discount.new
    @discount.title = params[:title]
    @discount.content = params[:content]
    discount_types = params[:sub_discount_type]
    if !discount_types.blank?
      wash_car_types = DiscountType.where("name LIKE '%7座%' or name LIKE '%SUV%' or name LIKE '%5座%' or name LIKE '%洗车%'")
      wash_car_types_array = []
      wash_car_types.each do |wash_car_type|
        wash_car_types_array<<wash_car_type.id
      end
      flag = false
      discount_types.each do |discount_type_id|
        discount_type = DiscountType.find(discount_type_id)
        @discount.discount_types<<discount_type
        if wash_car_types_array.include?(discount_type_id.to_i)
          flag = true
        end
      end
      if flag
        @discount.integral = 5
      else
        @discount.integral = 0
      end

    else
      @discount.integral = 0
    end
    @discount.price = params[:price]
    @discount.sale_price = params[:sale_price]
    if not params[:price].blank?
      if params[:sale_price].blank?
        @discount.sale_price = params[:price]
      end
    else
      if not params[:sale_price].blank?
        @discount.price = params[:sale_price]
      end
    end

    if !@discount.price.blank?
      if @discount.price!=0
        @discount.discount = @discount.sale_price/@discount.price
      else
        @discount.discount = 0
      end
    end

    if !params[:hot].blank? && params[:hot] == "on"
      @discount.hot = true
    else
      @discount.hot = false
    end
    @discount.shop = Employee.find(session[:user_id]).shop
    documents = params[:documents]
    begin
      Discount.transaction do
        if !documents.blank?
          documents.each do |document_id|
            if Document.exists?(document_id)
              document = Document.find(document_id);
              @discount.documents<<document
            end
          end
        end
        @discount.save!
      end
    rescue
      error_message = ''
      @discount.errors[:error_message].each do |error|
        if error == @discount.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      if !documents.blank?
        documents.each do |document_id|
          if Document.exists?(document_id)
            document = Document.find(document_id);
            document.destroy
          end

        end
      end
      flash.now[:error] = error_message
    end
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end

  end

  def update
    @discount.title = params[:title]
    @discount.content = params[:content]
    discount_types = params[:sub_discount_type]
    if !discount_types.blank?
      @discount.discount_types.clear
      discount_types.each do |discount_type|
        @discount.discount_types<<DiscountType.find(discount_type)
      end
    end
    @discount.price = params[:price]
    @discount.sale_price = params[:sale_price]
    if not params[:price].blank?
      if params[:sale_price].blank?
        @discount.sale_price = params[:price]
      end
    else
      if not params[:sale_price].blank?
        @discount.price = params[:sale_price]
      end
    end

    if !@discount.price.blank?
      if @discount.price!=0
        @discount.discount = @discount.sale_price/@discount.price
      else
        @discount.discount = 0
      end
    end

    if !params[:hot].blank? && params[:hot] == "on"
      @discount.hot = true
    else
      @discount.hot = false
    end
    @discount.shop = Employee.find(session[:user_id]).shop
    documents = params[:documents]
    begin
      Discount.transaction do
        if !documents.blank?
          documents.each do |document_id|
            if Document.exists?(document_id)
              document = Document.find(document_id);
              @discount.documents<<document
            end

          end
        end
        @discount.save!
      end
    rescue
      error_message = ''
      @discount.errors[:error_message].each do |error|
        if error == @discount.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      if !documents.blank?
        documents.each do |document_id|
          if Document.exists?(document_id)
            document = Document.find(document_id);
            document.destroy
          end

        end
      end
      flash.now[:error] = error_message
    end
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end

  end

  def destroy
    begin
      Discount.transaction do
        @discount.destroy!
      end
      flag = true
    rescue
      error_message = ''
      @discount.errors[:error_message].each do |error|
        if error == @discount.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      flag = false
    end
    respond_to do |format|
      format.json { render :json => flag }
      format.any { head :no_content }
    end

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_discount
    begin
      @discount = Discount.find(params[:id])
    rescue
      error_message = ''
      @discount.errors[:error_message].each do |error|
        if error == @discount.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      return false
    end

  end

  def set_discount_type
    sql = ''
    if session[:admin]==1
      sql = "name LIKE '%平台%'"
    else
      if session[:wash]==1
        sql = "name not LIKE '%平台%' and (name LIKE '%7座%' or name LIKE '%SUV%' or name LIKE '%5座%' or name LIKE '%洗车%')"
        if session[:brand]==1
          sql = "name not LIKE '%平台%'"
        end
      elsif session[:brand]==1
        sql = "name not LIKE '%平台%' and name not LIKE '%7座%' and name not LIKE '%SUV%' and name not LIKE '%5座%' and name not LIKE '%洗车%'"
      end
    end
    @discount_types = DiscountType.where(sql).order('created_at desc')
  end
end
