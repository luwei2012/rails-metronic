class RolesController < ApplicationController
  layout 'admin'
  before_filter :check_admin
  before_action :set_role, :only => [:update, :destroy]

  def index
    # authority=0代表管理员
    @roles = Role.where("authority!=?",0)
  end

  def authority
    @shops = Shop.all
  end

  def authority_edit
    @employee = Employee.find(params[:id])
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

  end


  def create
    # 创建商户
    @role = Role.new()
    @role.name = params[:name]
    @role.duty = params[:duty]
    begin
      Role.transaction do
        @role.save!
      end
      render :json => @role.to_json and return
    rescue
      error_message = ''
      @role.errors[:error_message].each do |error|
        if error == @role.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      render :json => false
    end
  end

  # PATCH/PUT /shops/1
  # PATCH/PUT /shops/1.json
  def update
    @role.name = params[:name]
    @role.duty = params[:duty]
    begin
      Role.transaction do
        @role.save!
      end
      render :json => @role.to_json and return
    rescue
      error_message = ''
      @role.errors[:error_message].each do |error|
        if error == @role.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      render :json => false
    end
  end

  # DELETE /shops/1
  # DELETE /shops/1.json
  def destroy
    begin
      Role.transaction do
        @role.destroy
      end
      render :json => true and return
    rescue
      error_message = ''
      @role.errors[:error_message].each do |error|
        if error == @role.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      render :json => false
    end

  end

  private
  def set_role
    @role = Role.find(params[:id])
  end

end
