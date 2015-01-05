class ShopsController < ApplicationController
  layout 'admin'
  before_filter :check_admin
  before_filter :set_shop, :only => [:show, :edit, :update, :destroy]

  # GET /shops
  # GET /shops.json
  def index
    @shops = Shop.all
  end

  def authority
    @shops = Shop.all
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  def authority_edit
    @employee = Employee.find(params[:id])
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  def authority_update
    @employee = Employee.find params[:id]
    @employee.email = params[:email]
    @employee.password = params[:password]
    if not @employee.roles.blank?
      @employee.roles.clear
    end
    role_ids = params[:roles_select]
    if !role_ids.blank? && role_ids.count > 0
      role_ids.each do |role_id|
        role = Role.find role_id
        @employee.roles<<role
      end
    end
    begin
      Employee.transaction do
        @employee.save!
      end
      @shops = Shop.all
    rescue
      error_message = ''
      @employee.errors[:error_message].each do |error|
        if error == @employee.errors[:error_message].last
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


  # GET /shops/1
  # GET /shops/1.json
  def show
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  # GET /shops/new
  def new
    @shop = Shop.new
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
    # 创建商户
    @shop = Shop.new()
    @shop.name = params[:name]
    @shop.telephone_area_code = params[:telephone_area_code]
    @shop.telephone_number = params[:telephone_number]
    @shop.description = params[:description]
    @shop.shop_photo = params[:shop_photo]
    @shop.address = params[:address]
    @shop.longitude = params[:longitude]
    @shop.latitude = params[:latitude]
    brand = params[:select2_brands]
    if not brand.blank?
      brand = Brand.find brand
      @shop.brand = brand
    end
    cooperation = params[:cooperation]
    if !cooperation.blank? && cooperation == "on"
      @shop.cooperation = true
      @shop.extra_priority = params[:extra_priority]
    else
      @shop.cooperation = false
      @shop.extra_priority = 0
    end
    if params[:status_select].blank?
      @shop[:car_wash_bookable] = false
    else
      status = params[:status_select]
      if status.class == Array
        status.each do |key|
          @shop[key] = true
        end
      end
    end

    # 创建商户的预约安排信息
    @schedule_record = ScheduleRecord.new()

    # 创建商户的管理员账户
    @employee = Employee.new()
    @employee.email = params[:email]
    @employee.password = params[:password]

    role_ids = params[:roles_select]
    if !role_ids.blank? && role_ids.count > 0
      role_ids.each do |role_id|
        role = Role.find role_id
        @employee.roles<<role
      end
    end
    # 保存所有信息
    begin
      Shop.transaction do
        @shop.save!
        @employee.shop = @shop
        @employee.save!
        @schedule_record.shop = @shop
        @schedule_record.save!
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
      @schedule_record.errors[:error_message].each do |error|
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
    brand = params[:select2_brands]
    if not brand.blank?
      brand = Brand.find brand
      @shop.brand = brand
    end
    cooperation = params[:cooperation]
    if !cooperation.blank? && cooperation == "on"
      @shop.cooperation = true
      @shop.extra_priority = params[:extra_priority]
    else
      @shop.cooperation = false
      @shop.extra_priority = 0
    end
    if params[:status_select].blank?
      @shop[:car_wash_bookable] = false
    else
      status = params[:status_select]
      if status.class == Array
        status.each do |key|
          @shop[key] = true
        end
      end
    end

    # 创建商户的管理员账户
    @employee = @shop.employee
    @employee = (@employee.blank?) ? Employee.new() : @employee
    @employee.email = params[:email]
    if not params[:password].blank?
      @employee.password = params[:password]
    end
    role_ids = params[:roles_select]
    if not role_ids.blank?
      if not @employee.roles.blank?
        @employee.roles.clear
      end
      if !role_ids.blank? && role_ids.count > 0
        role_ids.each do |role_id|
          role = Role.find role_id
          @employee.roles<<role
        end
      end
    end

    # 保存所有信息
    begin
      Shop.transaction do
        @shop.save!
        @employee.shop = @shop
        @employee.save!
        @shops = Shop.all
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

  # DELETE /shops/1
  # DELETE /shops/1.json
  def destroy
    begin
      Shop.transaction do
        @shop.destroy
      end
      flag = true
    rescue
      error_message = ''
      @shop.errors[:error_message].each do |error|
        if error == @shop.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flag = false
    end
    respond_to do |format|
      format.json { render :json => flag }
      format.any { head :no_content }
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

  def email
    employee_id = params[:employee_id]
    begin
      employee = Employee.find_by_email(params[:email])
      if employee.blank?
        flag = true
      elsif !employee_id.blank? && employee_id.to_i == employee.id
        flag = true
      else
        flag = false
      end
    rescue
      error_message = ''
      employee.errors[:error_message].each do |error|
        if error == employee.errors[:error_message].last
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

  def shop_name
    begin
      id = params[:id]
      shop = Shop.find_by_name(params[:shop_name])
      if shop.blank?
        flag = true
      elsif !id.blank? && id.to_i == shop.id
        flag = true
      else
        flag = false
      end
    rescue
      error_message = ''
      shop.errors[:error_message].each do |error|
        if error == shop.errors[:error_message].last
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
