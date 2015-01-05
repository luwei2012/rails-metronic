class Mobile::OperationController < Mobile::BaseController

  before_filter :check_login, :only => [:order, :follow, :complete, :modify_password, :information, :feedBack]

  def information
    user = User.find(session[:user_id])
    render :json => {
        :status => 1,
        :name => user.name,
        :email => user.email,
        :account => user.account,
        :phone => user.phone,
        :licence_plate => user.licence_plate,
        :car_type => user.car_type,
        :sex => user.sex,
        :percent => user.percent,
        :integral => user.integral,
        :integral_tip => '下订单需要抵押积分，完成订单会奖励积分。'
    }.to_json
  end

  # 完善个人信息
  def complete
    user = User.find(session[:user_id])
    name = params[:name]
    # true表示男性。false表示女性
    sex = (params[:sex].blank?) ? 1 : params[:sex].to_i
    email = params[:email]
    car_type = params[:car_type]
    licence_plate = params[:licence_plate]
    percent = 0.0
    if !name.blank?
      percent+=0.2
      user.name = name
    end

    if !email.blank?
      percent+=0.2
      user.email = email
    end

    percent+=0.2
    user.sex = sex
    if !car_type.blank?
      percent+=0.2
      user.car_type = car_type
    end
    if !licence_plate.blank?
      percent+=0.2
      user.licence_plate = licence_plate
    end
    message = '修改成功！'
    if user.percent<1.0
      user.percent=percent
      if user.percent>=1.0
        integral = 5
        user.integral+=integral
        message+='个人信息完善，奖励5点积分!'
      end
    end
    user.save!
    begin
      result = {
          :status => 1,
          :message => message,
          :name => user.name,
          :phone => user.phone,
          :account => user.account,
          :licence_plate => user.licence_plate,
          :car_type => user.car_type,
          :email => user.email,
          :sex => user.sex,
          :integral => user.integral,
          :percent => user.percent,
          :integral_tip => '下订单需要抵押积分，完成订单会奖励积分。'
      }
      render :json => result.to_json
    rescue
      render :json => {:status => -1, :message => '服务器异常，请稍后再试！'}.to_json
    end
  end

  # 修改密码
  def modify_password
    user = User.find(session[:user_id])
    password = params[:password]
    new_password = params[:new_password]
    if user.authenticate(password) && !new_password.blank?
      user.password = new_password
      User.transaction do
        user.save!
      end
      render :json => {:status => 1, :message => '修改成功！'}.to_json
    else
      render :json => {:status => -1, :message => '密码不正确，请重试！'}.to_json
    end

  end

  # 忘记密码
  def forget_password
    email = params[:email]
    user = User.find_by_email(email)
    if user.blank?
      render :json => {:status => -1, :message => '该邮箱不存在，请输入注册时绑定的邮箱！'}.to_json and return
    else
      user.send_password_reset if user
      render :json => {:status => 1, :message => '新密码已发至邮箱，请查收！'}.to_json
    end

  end

  def feedBack
    user = User.find(session[:user_id])
    comment = Comment.new
    comment.user = user
    comment.status = COMMENT_STATUS[:not_checked]
    comment_notification = CommentNotification.new
    comment_notification.comment = comment
    comment_notification.user = user
    comment_notification.status = Comment::NOT_READ
    comment.content = params[:comment]

    Comment.transaction do
      comment.save!
      comment_notification.save!
    end
    comment = {
        :comment_notification_id => comment_notification.id,
        :name => user.name||user.account||user.phone,
        :title => '用户反馈',
        :comment => params[:comment],
        :user_photo => user.user_photo||ActionController::Base.helpers.asset_path('default_user.jpg'),
        :updated_at => '刚刚'
    }
    Fiber.new { WebsocketRails['admin'].trigger(:comment, comment) }.resume
    render :json => {:status => 1, :message => '反馈成功，平台会对有价值的建议奖励积分！'}.to_json
  end

end
