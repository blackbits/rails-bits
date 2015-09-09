include_recipe 'nginx'
include_recipe 'nodejs'
include_recipe 'logrotate::global'
include_recipe 'ruby-bits'

nginx_template = resources template: 'nginx.conf'
nginx_template.cookbook 'rails-bits'
