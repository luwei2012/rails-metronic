rails-metronic
==============

基于Metronic静态页面改写的Rails的服务器端


首先需要你熟悉Ruby on Rails开发，其中deploy文件有些地方是需要换成自己的配置：
set :repo_url, '这里换成自己的git服务器地址'

我是使用的Thin服务器作为部署服务器，如果只想在development模式下运行请忽略下面。
我的项目中加了websocket_rails，这个目前和Unicorn不兼容，请注意。

还有在secret.yml中的key也需要替换为自己的key
