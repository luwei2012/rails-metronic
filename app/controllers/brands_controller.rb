class BrandsController < ApplicationController
  layout 'admin'
  before_filter :check_admin
  before_filter :set_brand, :only => [:show, :edit, :update, :destroy, :brand_shop_list]

  def index
    @brands = Brand.all
  end

  def brand_shop_list
    @shops = @brand.shops
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

  def new
    @brand = Brand.new
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
    @brand = Brand.new
    @brand.name = params[:name]
    brand_photo = params[:brand_photo]
    @brand.brand_photo = brand_photo
    begin
      Brand.transaction do
        @brand.save!
      end
    rescue
      error_message = ''
      @brand.errors[:error_message].each do |error|
        if error == @brand.errors[:error_message].last
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

  def update
    @brand.name = params[:name]
    brand_photo = params[:brand_photo]
    if !@brand.brand_photo.blank? && Document.exists?(@brand.brand_photo) && brand_photo != @brand.brand_photo
      Document.find(@brand.brand_photo).destroy
    end
    @brand.brand_photo = brand_photo
    begin
      Brand.transaction do
        @brand.save!
      end
    rescue
      error_message = ''
      @brand.errors[:error_message].each do |error|
        if error == @brand.errors[:error_message].last
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

  def brand_name
    begin
      id = params[:id]
      brand = Brand.find_by_name(params[:brand_name])
      if brand.blank?
        flag = true
      elsif !id.blank? && id.to_i == brand.id
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

  def destroy
    begin
      Brand.transaction do
        @brand.destroy
      end
      flag = true
    rescue
      error_message = ''
      @brand.errors[:error_message].each do |error|
        if error == @brand.errors[:error_message].last
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


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_brand
    begin
      @brand = Brand.find(params[:id])
    rescue
      error_message = ''
      @brand.errors[:error_message].each do |error|
        if error == @brand.errors[:error_message].last
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
