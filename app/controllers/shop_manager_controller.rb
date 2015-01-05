class ShopManagerController < ApplicationController
  layout 'manager'
  before_filter :check_manager
  before_filter :set_shop, :only => [:edit, :update, :destroy]

  def index
    @shop = Employee.find(session[:user_id]).shop
  end

  # GET /shops/1/edit
  def edit
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  # PATCH/PUT /shops/1
  # PATCH/PUT /shops/1.json
  def update
    @shop.name = params[:name]
    @shop.telephone_area_code = params[:telephone_area_code]
    @shop.telephone_number = params[:telephone_number]
    @shop.description = params[:description]
    @shop.shop_photo = params[:shop_photo]
    @shop.address = params[:address]
    @shop.longitude = params[:longitude]
    @shop.latitude = params[:latitude]
    # 创建商户的管理员账户
    @employee = @shop.employee
    @employee.email = params[:email]
    if not params[:password].blank?
      @employee.password = params[:password]
    end

    # 保存所有信息
    begin
      Shop.transaction do
        @shop.save!
        @employee.save!
      end
    rescue
      error_message = ''
      @shop.errors[:error_message].each do |error|
        if error == @shop.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      @employee.errors[:error_message].each do |error|
        if error == @shop.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
    end
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  def show_upload_div
    if (not params[:document_id].blank?) && Document.exists?(params[:document_id])
      @document = Document.find params[:document_id]
    end
    respond_to do |format|
      format.js
      format.any { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_shop
    begin
      @shop = Shop.find(params[:id])
    rescue
      error_message = ''
      @shop.errors[:error_message].each do |error|
        if error == @shop.errors[:error_message].last
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
