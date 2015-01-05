class UserMailer < ActionMailer::Base

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(employee,request)
    @employee = employee
    @url  = "#{request.protocol}#{request.host_with_port}/password_modify/?id=#{@employee.password_reset_token}"
    mail :to => @employee.email, :subject => "Password Reset"
  end

  def user_password_reset(user)
    @user = user
    @new_password  = "#{@user.password_reset_token}"
    mail :to => @user.email, :subject => "Password Reset"
  end
end
