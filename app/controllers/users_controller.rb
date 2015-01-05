class UsersController < ApplicationController
  layout 'admin'
  before_filter :check_admin
  before_filter :set_user, only: [:show, :destroy, :update]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  def show
    respond_to do |format|
      format.js
      format.any { redirect_to :action => :index }
    end
  end

  def update
    @user.integral = params[:integral]
    begin
      User.transaction do
        @user.save!
      end
      result = {
          :success => 1,
          :id => @user.id,
          :account => @user.account,
          :phone => @user.phone,
          :integral => @user.integral,
          :effect_order_count => ((@user.orders.where('status=?', 2).blank?) ? 0 : @user.orders.where('status=?', 2).count),
          :order_count => (@user.orders.blank?) ? 0 : @user.orders.count,
          :created_at => (@user.created_at.blank?) ? nil : @user.created_at.strftime('%Y年%m月%d日 %H时%M分')
      }
      flag = true
    rescue
      error_message = ''
      @user.errors[:error_message].each do |error|
        if error == @user.errors[:error_message].last
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

  # DELETE /shops/1
  # DELETE /shops/1.json
  def destroy
    begin
      User.transaction do
        @user.destroy
      end
      flag = true
    rescue
      error_message = ''
      @user.errors[:error_message].each do |error|
        if error == @user.errors[:error_message].last
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
  def set_user
    begin
      @user = User.find(params[:id])
    rescue
      error_message = ''
      @user.errors[:error_message].each do |error|
        if error == @user.errors[:error_message].last
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
