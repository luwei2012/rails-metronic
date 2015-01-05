# encoding: UTF-8
# This file is copied to spec/ when you run 'rails generate rspec:install'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

module RequestHeader
  extend ActiveSupport::Concern
  included do
    before do
      @request.env["HTTP_CVERSION"] = "1.0"
      @request.env["HTTP_CTYPE"] = "0"
    end
  end
end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

end


def create_test_user
  @user = User.create! :account => "123456", :password => "123456", :phone => "123456", :email => "11@11.com"
  session[:user_id] = @user.id
end


def end_time_travel
  Time.unstub(:now)
end

def json_to_hash(json)
  ActiveSupport::JSON.decode(json)
end


#
#def json_to_hash(json)
#  ActiveSupport::JSON.decode(json)
#end
# ActiveRecord::Base.connection.execute("OPTIMIZE TABLE #{merge1_table_name}")
