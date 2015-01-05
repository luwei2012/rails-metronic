class CommentsController < ApplicationController
  layout 'admin'
  before_filter :check_admin
  before_action :set_comment, :only => [:show, :update, :destroy, :edit]

  def index
    @comments = Comment.all
    if not @comments.blank?
      @comments.each do |comment|
        comment_notifications = comment.comment_notifications
        if not comment_notifications.blank?
          comment_notifications.each do |comment_notification|
            if comment_notification.status == Comment::NOT_READ
              comment_notification.status = Comment::READED
              comment_notification.save!
            end
          end
        end
      end
    end
  end

  def show
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

  def update
    @comment.bonus_integral = params[:bonus_integral].to_i
    if  @comment.bonus_integral > 0
      @comment.status = COMMENT_STATUS[:bonus]
    else
      @comment.status = COMMENT_STATUS[:checked]
    end

    user = @comment.user
    user.integral += @comment.bonus_integral
    begin
      Comment.transaction do
        @comment.save!
        user.save!
      end
    rescue
      error_message = ''
      @comment.errors[:error_message].each do |error|
        if error == @comment.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      user.errors[:error_message].each do |error|
        if error == @comment.errors[:error_message].last
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
      User.transaction do
        @comment.destroy
      end
      flag = true
    rescue
      error_message = ''
      @comment.errors[:error_message].each do |error|
        if error == @comment.errors[:error_message].last
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

  def comment_notifications
    comment_notifications = CommentNotification.where('status=?', Comment::NOT_READ).order('created_at desc')
    comment_notification_array=[]
    if not comment_notifications.blank?
      comment_notifications.each do |comment_notification|
        created_at = comment_notification.created_at
        current_time = Time.now
        dis_year = current_time.year - created_at.year
        dis_month = current_time.month - created_at.month
        dis_day = current_time.day - created_at.day
        dis_hour = current_time.hour - created_at.hour
        dis_minute = current_time.min - created_at.min
        if dis_year>1
          time = created_at.strftime('%Y年%m月%d日 %H时%M分')
        elsif dis_month>1
          time = dis_month.to_s+'个月前'
        elsif dis_day>1
          time = dis_day.to_s+'天前'
        elsif dis_hour>1
          time = dis_hour.to_s+'小时前'
        elsif dis_minute>3
          time= dis_minute.to_s+'分钟前'
        else
          time = '刚刚'
        end
        comment_notification_hash={
            :comment_notification_id => comment_notification.id,
            :name => comment_notification.user.name||comment_notification.user.account||comment_notification.user.phone,
            :comment => comment_notification.comment.content,
            :user_photo => comment_notification.user.user_photo||ActionController::Base.helpers.asset_path('default_user.jpg'),
            :created_at => time
        }
        comment_notification_array<<comment_notification_hash
      end
    end
    respond_to do |format|
      format.json { render :json => {:count => comment_notification_array.count, :comment_notifications => comment_notification_array}.to_json }
      format.any { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    begin
      @comment = Comment.find(params[:id])
    rescue
      error_message = ''
      @comment.errors[:error_message].each do |error|
        if error == @comment.errors[:error_message].last
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
