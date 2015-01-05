class LoginController < ActionController::Base
  layout 'login'

  def index
    @current_user ||= Employee.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
    if not @current_user.blank?
      session[:user_id] = @current_user.id
      session[:name] = @current_user.name||@current_user.email||@current_user.phone
      session[:admin]=0
      session[:wash]=0
      session[:brand]=0
      @current_user.roles.each do |role|
        if role.authority == ROLE[:admin]
          session[:admin]=1
        elsif role.authority == ROLE[:wash]
          session[:wash]=1
        elsif role.authority == ROLE[:brand]
          session[:brand]=1
        end
      end
      if  session[:admin]== 1
        redirect_to :controller => :shops, :action => :index and return
      else
        redirect_to :controller => :order_manager, :action => :index and return
      end
    else
      render :action => :index
    end
  end

  def logout
    session.clear
    cookies.delete(:auth_token)
    redirect_to root_url, :notice => "Logged out!"
  end

  def login
    email = params[:email]
    password = params[:password]
    if !(email.blank? || password.blank?)
      employee = Employee.find_by_email(email)
      if employee && employee.authenticate(password)
        #render to shop
        if params[:remember]
          cookies.permanent[:auth_token] = {
              value: employee.auth_token,
              expires: (Time.now.midnight + 7.days)
          }
        else
          cookies[:auth_token] = {
              value: employee.auth_token,
              expires: (Time.now.midnight + 7.days)
          }
        end
        session[:user_id] = employee.id
        session[:name] = employee.name||employee.email||employee.phone
        session[:admin]=0
        session[:wash]=0
        session[:brand]=0
        employee.roles.each do |role|
          if role.authority == ROLE[:admin]
            session[:admin]=1
          elsif role.authority == ROLE[:wash]
            session[:wash]=1
          elsif role.authority == ROLE[:brand]
            session[:brand]=1
          end
        end
        if  session[:admin]== 1
          redirect_to :controller => :shops, :action => :index and return
        else
          redirect_to :controller => :order_manager, :action => :index and return
        end

      else
        flash.now[:error] = '账号或密码不正确！'
      end
    end

    render :action => :index
  end

  def reset
    employee = Employee.find_by_email(params[:email])
    employee.send_password_reset(request) if employee
    redirect_to root_url, :notice => "Email sent with password reset instructions."
  end

  def password_modify
    @employee = Employee.find_by_password_reset_token!(params[:id])
  end

  def modify
    @employee = Employee.find(params[:id])
  end

  def modify_update
    @employee = Employee.find(params[:id])
    @employee.password = params[:password]
    begin
      Employee.transaction do
        @employee.save!
      end
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
      render action: :modify and return
    end
    redirect_to root_url, :notice => "Password has been reset."
  end


  def update_password
    @employee = Employee.find_by_password_reset_token!(params[:id])
    if !@employee.blank? && @employee.password_reset_sent_at < 2.hours.ago
      redirect_to root_url, :alert => "Password reset has expired."
    else
      @employee.password = params[:password]
      @employee.password_reset_token = nil
      begin
        Employee.transaction do
          @employee.save!
        end
        redirect_to root_url, :notice => "Password has been reset."
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
        render :password_modify
      end
    end
  end

end
