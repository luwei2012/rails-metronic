require 'rails_helper'

RSpec.describe Mobile::LoginController, :type => :controller do
  before(:each) do
    create_test_user
  end

  it '注册用户成功，立即生效' do
    #USER_APPROVE = false
    # 成功注册
    #$redis.del(User.device_token_key(@user.id))
    #Rails.stub(:env).and_return('test_success_spec')
    post :register, :phone => '111111', :password => '123456'
    user = User.last
    user.account.should == '111111'
    result = JSON::parse(response.body)
    result['status'].should == 1
    result['message'].should == '注册成功！'
    #result["page"].should == "alert"
    #result["msg"].should == "该用户名已经被占过了！"
    #$redis.get(User.device_token_key(user.id)).should_not == nil
  end


  it '用户登陆成功' do
    #USER_APPROVE = false
    # 成功注册
    #$redis.del(User.device_token_key(@user.id))
    #Rails.stub(:env).and_return('test_success_spec')
    post :index, :account => '123456', :password => '123456'
    result = JSON::parse(response.body)
    result['status'].should == 1
    result['message'].should == '登陆成功！'
  end

  it '用户登陆失败,用户不存在' do
    #USER_APPROVE = false
    # 成功注册
    #$redis.del(User.device_token_key(@user.id))
    #Rails.stub(:env).and_return('test_success_spec')
    post :index, :account => '123', :password => '123456'
    result = JSON::parse(response.body)
    result['status'].should == 0
    result['message'].should == '账号或密码不正确！'
  end

  it '用户登陆失败,密码错误' do
    #USER_APPROVE = false
    # 成功注册
    #$redis.del(User.device_token_key(@user.id))
    #Rails.stub(:env).and_return('test_success_spec')
    post :index, :account => '123456', :password => '11111'
    result = JSON::parse(response.body)
    result['status'].should == 0
    result['message'].should == '账号或密码不正确！'
  end

  it "注册用户失败,重名" do
    #USER_APPROVE = false
    User.create! :phone => "111111", :password => "123456"
    post :register, :phone => "111111", :password => "123456"
    result = JSON::parse(response.body)
    result["status"].should == 0
    result["message"].should == "该手机号已经注册过了！"

  end

end
