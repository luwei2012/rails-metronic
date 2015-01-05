class Mobile::LoginController < ActionController::Base

  # 登陆
  def index
    account = params[:account]
    password = params[:password]
    if !(account.blank? || password.blank?)
      user = User.find_by_account(account);
      if !user.blank?
        if !user.password_reset_token.blank?
          if user.password_reset_sent_at < 2.hours.ago
            user.password_reset_token = nil
            user.save!
          else
            if user.password_reset_token==password
              user.password = password
              user.password_reset_token = nil
              user.save!
            end
          end
        end
        if user.authenticate(password)
          session[:user_id] = user.id
          result = {
              :status => 1,
              :message => '登陆成功！',
              :email => user.email,
              :name => user.name,
              :phone => user.phone,
              :licence_plate => user.licence_plate,
              :car_type => user.car_type,
              :account => user.account,
              :sex => user.sex,
              :percent => user.percent,
              :integral => user.integral,
              :integral_tip => '下订单需要抵押积分，完成订单会奖励积分。'
          }
          render :json => result.to_json and return
        end
      end
    end
    reset_session
    result = {:status => -1, :message => '账号或密码不正确！'}
    render :json => result.to_json
  end

  # 注册
  def register
    phone = params[:account]
    password = params[:password]
    name = params[:name]
    # true表示男性。false表示女性
    sex = (params[:sex].blank?) ? 1 : params[:sex].to_i
    car_type = params[:car_type]
    licence_plate = params[:licence_plate]
    email = params[:email]
    if phone.blank? || password.blank?
      reset_session
      render :json => {:status => -1, :message => '手机号或者密码不能为空！'}.to_json and return
    end

    user = User.find_by_phone phone

    if user # 已经注册过
      render :json => {:status => -1, :message => "该手机号已经注册过了！"}.to_json and return
    end

    user = User.new
    user.account = phone
    user.phone = phone
    user.password = password
    user.email = email
    percent = 0.2
    if !name.blank?
      user.name = name
      percent+=0.2
    end
    user.sex = sex
    percent+=0.2
    if !car_type.blank?
      user.car_type = car_type
      percent+=0.2
    end
    if !licence_plate.blank?
      user.licence_plate = licence_plate
      percent+=0.2
    end
    begin
      message = '注册成功，赠送10点积分！'
      user.integral = 10
      user.percent=percent
      if percent==1.0
        integral = 5
        user.integral+=integral
        message+=' 个人信息完善，奖励5点积分!'
      end
      User.transaction do
        user.save!
      end
      session[:user_id] = user.id
      render :json => {
          :status => 1,
          :message => message,
          :email => user.email,
          :name => user.name,
          :phone => user.phone,
          :account => user.account,
          :licence_plate => user.licence_plate,
          :car_type => user.car_type,
          :sex => user.sex,
          :integral => user.integral,
          :percent => user.percent,
          :integral_tip => '下订单需要抵押积分，完成订单会奖励积分。'
      }.to_json
    rescue
      reset_session
      render :json => {:status => -1, :message => '服务器异常，请稍后再试！'}.to_json
    end
  end


end
