require File.expand_path('../boot', __FILE__)

require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if defined?(Bundler)
# If you precompile assets before deploying to production, use this line
#   Bundler.require(*Rails.groups(:assets => %w(development test)))
# If you want your assets lazily compiled in production, use this line
Bundler.require(:default, :assets, Rails.env)
end

class ActiveRecord::Base
  # 转化为hash，保留想要的，或者去除不想要的
  # t = Town.find 1
  # t.to_hash(:drop => %w(created_at updated_at))
  # t.to_hash(:keep => %w(created_at updated_at))
  # t.to_hash
  # t.to_hash :keep => "created_at"
  def to_hash(params = {})
    h = attributes
    h.symbolize_keys!
    if params[:drop]
      params[:drop].each { |s| h.delete(s.to_sym) }
    end
    if params[:keep]
      h.delete_if { |k, v| not params[:keep].include?(k.to_sym) }
    end
    h.each { |k, v|
      h[k] = v.to_i if h[k].class == ActiveSupport::TimeWithZone
      if h[k].blank?
        k.to_s.include?('_id') ? h.delete(k) : h[k] = v.to_s
      end
    }
    return h
  end


end

module CarWash
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.active_record.default_timezone = :local
    config.time_zone = 'Beijing'
    config.filter_parameters += [:password]
    # Enable the asset pipeline
    config.assets.enabled = true
    config.generators do |g|
      g.assets false
    end

    initializer 'setup_asset_pipeline', :group => :all  do |app|
      # We don't want the default of everything that isn't js or css, because it pulls too many things in
      app.config.assets.precompile.shift

      # Explicitly register the extensions we are interested in compiling
      app.config.assets.precompile.push(Proc.new do |path|
        File.extname(path).in? [
                                   '.html', '.erb', '.haml',                 # Templates
                                   '.png',  '.gif', '.jpg', '.jpeg','.ico',         # Images
                                   '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
                               ]
      end)
    end

  end
end

#Encoding.default_external = "utf-8"
Dir.glob(File.dirname(__FILE__) + '/const/*.rb') { |file| require file }
WillPaginate.per_page = 20


# overload  solved the exception after connection disconnected by reconnecting
module Backburner
  def self.enqueue(job_class, *args)
    retries = 1
    begin
      Backburner::Worker.enqueue(job_class, args, {})

    rescue
      if retries < 3
        Backburner::Worker.reconnect
        retries += 1
        retry
      else
        raise
      end
    end

  end

  class Worker
    def self.enqueue(job_class, args=[], opts={})
      retries = 1
      begin
        pri = opts[:pri] || job_class.queue_priority || Backburner.configuration.default_priority
        delay = [0, opts[:delay].to_i].max
        ttr = opts[:ttr] || Backburner.configuration.respond_timeout
        tube = connection.tubes[expand_tube_name(opts[:queue] || job_class)]
        res = Backburner::Hooks.invoke_hook_events(:before_enqueue, *args)
        return false unless res # stop if hook is false
        data = {:class => job_class.name, :args => args}
        tube.put data.to_json, :pri => pri, :delay => delay, :ttr => ttr
        Backburner::Hooks.invoke_hook_events(:after_enqueue, *args)

      rescue
        if retries < 3
          Backburner::Worker.reconnect
          retries += 1
          retry
        else
          raise
        end
      end

      return true
    end

    def self.reconnect
      if @connection
        @connection.connections.map do |c|
          c.close if c && c.connection
        end
        @connection = Connection.new(Backburner.configuration.beanstalk_url)
      end
    end

    def work_one_job(conn = nil)
      conn ||= self.connection
      job = Backburner::Job.new(conn.tubes.reserve)
      p "1:#{job}"
      self.log_job_begin(job.name, job.args)
      p "2:#{job}"
      job.process
      p "3:#{job}"
      self.log_job_end(job.name)
      p "4:#{job}"
    rescue Backburner::Job::JobFormatInvalid => e
      self.log_error self.exception_message(e)
    rescue => e # Error occurred processing job
      self.log_error self.exception_message(e)
      num_retries = job.stats.releases
      retry_status = "failed: attempt #{num_retries+1} of #{queue_config.max_job_retries+1}"
      if num_retries < queue_config.max_job_retries # retry again
        delay = queue_config.retry_delay + num_retries ** 3
        job.release(:delay => delay)
        self.log_job_end(job.name, "#{retry_status}, retrying in #{delay}s") if job_started_at
      else # retries failed, bury
        job.bury
        self.log_job_end(job.name, "#{retry_status}, burying") if job_started_at
      end
      handle_error(e, job.name, job.args)
    end

  end
end

# overload  solved thread dead lock
class Jabber::Client
  def stop
    @parser_thread.kill
    while @parser_thread.alive? do
    end
    @parser = nil
  end

end