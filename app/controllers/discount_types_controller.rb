class DiscountTypesController < ApplicationController

  layout 'admin'
  before_filter :check_admin
  before_filter :set_discount_type, :only => [:show, :edit, :update, :destroy]

  def index
    @discount_types = DiscountType.where('parent = ?', 0)
  end

  def new
    @discount_type = DiscountType.new
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
      format.any { redirect_to :action => :index }
    end
  end

  def edit
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  def create
    # 创建商户
    @discount_type = DiscountType.new()
    @discount_type.name = params[:name]
    parent = params[:parent]
    if !parent.blank? && parent != 0
      @discount_type.parent = parent
    end
    if not params[:icon].blank?
      @discount_type.icon = params[:icon]
    end
    begin
      DiscountType.transaction do
        @discount_type.save!
      end
      discount_types_list = DiscountType.where('parent = ?', @discount_type.id)
      result = {
          :success => 1,
          :id => @discount_type.id,
          :name => @discount_type.name,
          :count => (discount_types_list.blank?) ? 0 : discount_types_list.count,
          :parent => (DiscountType.exists?(@discount_type.parent)) ? DiscountType.find(@discount_type.parent).name : nil
      }
      flag = true
    rescue
      error_message = ''
      @discount_type.errors[:error_message].each do |error|
        if error == @discount_type.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      flag=false
    end
    respond_to do |format|
      format.json {
        if flag==true
          render :json => result.to_json
        else
          render :json => false
        end
      }
      format.js
      format.any { head :no_content }
    end
  end

  # PATCH/PUT /shops/1
  # PATCH/PUT /shops/1.json
  def update
    @discount_type.name = params[:name]
    parent = params[:parent]
    if !@discount_type.parent.blank?&& @discount_type.parent!=0 && !parent.blank? && parent != 0
      @discount_type.parent = parent
    end
    if not params[:icon].blank?
      @discount_type.icon = params[:icon]
    end
    begin
      DiscountType.transaction do
        @discount_type.save!
      end
      discount_types_list = DiscountType.where('parent = ?', @discount_type.id)
      result = {
          :success => 1,
          :id => @discount_type.id,
          :name => @discount_type.name,
          :count => (discount_types_list.blank?) ? 0 : discount_types_list.count,
          :parent => (DiscountType.exists?(@discount_type.parent)) ? DiscountType.find(@discount_type.parent).name : nil
      }
      flag=true
    rescue
      error_message = ''
      @discount_type.errors[:error_message].each do |error|
        if error == @discount_type.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      flag=false
    end
    respond_to do |format|
      format.json {
        if flag==true
          render :json => result.to_json
        else
          render :json => false
        end
      }
      format.js
      format.any { head :no_content }
    end
  end

  def discount_type_name
    begin
      id = params[:id]
      discount_type = DiscountType.find_by_name(params[:discount_type_name])
      if discount_type.blank?
        flag = true
      elsif !id.blank? && id.to_i == discount_type.id
        flag = true
      else
        flag = false
      end
    rescue
      flag = false
    end
    respond_to do |format|
      format.json { render :json => flag }
      format.any { head :no_content }
    end
  end

  # DELETE /shops/1
  # DELETE /shops/1.json
  def destroy
    begin
      DiscountType.transaction do
        @discount_type.destroy
      end
      flag=true
    rescue
      error_message = ''
      @discount_type.errors[:error_message].each do |error|
        if error == @discount_type.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flag=false
    end
    respond_to do |format|
      format.json {
        render :json => flag
      }
      format.any { head :no_content }
    end
  end

  def discount_type_list
    @discount_type = DiscountType.find(params[:parent])
    if !@discount_type.blank? && @discount_type.parent == 0
      @discount_types_list = DiscountType.where('parent = ?', @discount_type.id)
    end
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  private

  def set_discount_type
    begin
      @discount_type = DiscountType.find(params[:id])
    rescue
      error_message = ''
      @discount_type.errors[:error_message].each do |error|
        if error == @discount_type.errors[:error_message].last
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
