# -*- encoding : utf-8 -*-


default_port = 6382

#if Socket.gethostname  ==  "spider-01"
#  $redis = Redis.new(:timeout => 10.0,:host => '42.121.3.120', :port => default_port)
#elsif Socket.gethostname == "mof-sp"
#  $redis = Redis.new(:timeout => 10.0,:host => '10.135.49.145', :port => default_port)
#elsif Socket.gethostname == "stage-sp"
#  $redis = Redis.new(:timeout => 10.0,:host => '10.200.139.26', :port => default_port)
#else
  $redis = Redis.new(:timeout => 10.0,:host => 'localhost', :port => default_port)
#end



