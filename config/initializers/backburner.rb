Backburner.configure do |config|
  config.beanstalk_url    = ["beanstalk://127.0.0.1:11300"]
  config.tube_namespace   = "backburner.car_wash.queue"
  config.on_error         = lambda { |e| puts e }
  config.max_job_retries  = 3 # default 0 retries
  config.retry_delay      = 2 # default 5 seconds
  config.default_priority = 65536
  config.respond_timeout  = 3600
  config.default_worker   = Backburner::Workers::Simple
  config.primary_queue    = "encode-jobs"
  config.logger           = Logger.new(STDOUT)
end
