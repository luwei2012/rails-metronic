# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'car_wash'
set :repo_url, '这里换成自己的git服务器地址'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/car_wash'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :rails_env, "production"

# Default value for keep_releases is 5
# set :keep_releases, 5

`ssh-add`

namespace :bundler do
  desc "Run bundler, installing gems"
  task :install_app do
    on roles(:app) do
      execute("cd #{release_path} && bundle install --without=development test && rake db:migrate RAILS_ENV=production")
    end
  end

end

namespace :deploy do

  desc "Symlink shared"
  task :symlink_shared do
    on roles(:app) do
      execute "cp -fr #{release_path}/config/#{fetch(:database_config_file)} #{release_path}/config/database.yml"
      execute "ln -sf /var/www/upload/apps/car_wash/videos #{release_path}/public/videos"
      execute "ln -sf /var/www/upload/apps/car_wash/image_uploads #{release_path}/public/image_uploads"
    end

  end

  # NOTE: I don't use this anymore, but this is how I used to do it.
  desc "Precompile assets after deploy"
  task :precompile_assets do
    on roles(:app) do
      execute("cd #{release_path} && bundle exec rake assets:precompile RAILS_ENV=production")
    end
  end

  desc "create db"
  task :create_db do
    on roles(:app) do
      execute "cd #{release_path} &&  rake db:create RAILS_ENV=production"
    end
  end


  %w(start_thin stop_thin restart_thin).each do |action|
    desc "thin:#{action}"
    task action.to_sym do
      invoke "thin:#{action}"
      #find_and_execute_task("unicorn:#{action}")
    end
  end

  %w(start_websocket_rails stop_websocket_rails restart_websocket_rails).each do |action|
    desc "websocket_rails:#{action}"
    task action.to_sym do
      invoke "websocket_rails:#{action}"
      #find_and_execute_task("unicorn:#{action}")
    end
  end


  desc "start redis_server"
  task :start_redis_server do
    on roles(:app) do
      execute "redis-server #{deploy_to}/current/config/redis.conf"
    end
  end


  after :publishing, :symlink_shared
  after :publishing, 'bundler:install_app'
  after :publishing, :precompile_assets
  after :publishing, :start_redis_server
  after :publishing, :restart_websocket_rails
  after :publishing, :restart_thin
end

namespace :websocket_rails do

  desc "Start websocket_rails"
  task :start_websocket_rails do
    on roles(:app) do
      execute "cd #{release_path} && bundle exec rake websocket_rails:start_server"
    end
  end

  #desc "Start unicorn"
  #task :start, :except => { :no_release => true } do
  #  run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D"
  #  run "ps aux | grep unicorn_rails | head -n 1 | awk '{print $2}' > #{deploy_to}/shared/tmp/pids/unicorn.pid"
  #end

  desc "Stop websocket_rails"
  task :stop_websocket_rails do
    on roles(:app) do
      execute "cd #{release_path} && bundle exec rake websocket_rails:stop_server"
      #execute "kill -s QUIT `cat  #{deploy_to}/shared/tmp/pids/unicorn.pid`"
    end
  end

  #
  #desc "Stop unicorn"
  #task :stop, :except => { :no_release => true } do
  #  run "kill -s QUIT `cat  #{deploy_to}/shared/tmp/pids/unicorn.pid`"
  #end

  desc "Restart _websocket_rails"
  task :restart_websocket_rails do
    on roles(:app) do
      execute "cd #{release_path} && bundle exec rake websocket_rails:stop_server"
      sleep(5)
      execute "cd #{release_path} && bundle exec rake websocket_rails:start_server"
    end
  end
end

namespace :thin do

  desc "Start thin"
  task :start_thin do
    on roles(:app) do
      execute "cd #{current_path} ; bundle exec thin start -C #{deploy_to}/current/config/thin.yml -e production -d"
    end
  end

  #desc "Start unicorn"
  #task :start, :except => { :no_release => true } do
  #  run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D"
  #  run "ps aux | grep unicorn_rails | head -n 1 | awk '{print $2}' > #{deploy_to}/shared/tmp/pids/unicorn.pid"
  #end

  desc "Stop thin"
  task :stop_thin do
    on roles(:app) do
      execute "cd #{current_path} ; bundle exec thin stop -C #{deploy_to}/current/config/thin.yml -e production -d"
      #execute "kill -s QUIT `cat  #{deploy_to}/shared/tmp/pids/unicorn.pid`"
    end
  end

  #
  #desc "Stop unicorn"
  #task :stop, :except => { :no_release => true } do
  #  run "kill -s QUIT `cat  #{deploy_to}/shared/tmp/pids/unicorn.pid`"
  #end

  desc "Restart thin"
  task :restart_thin do
    on roles(:app) do
      execute "cd #{current_path} ; bundle exec thin stop -C #{deploy_to}/current/config/thin.yml -e production -d"
      sleep(5)
      execute "cd #{current_path} ; bundle exec thin start -C #{deploy_to}/current/config/thin.yml -e production -d"
    end
  end
end


