default[:nodejs][:version] = '0.10.26'
default[:nodejs][:npm] = '1.4.3'

default[:nginx][:user] = node[:owner][:username]
default[:nginx][:group] = node[:owner][:username]
default[:nginx][:default_site_enabled] = false
default[:nginx][:worker_processes] = 2 * node[:cpu][:total]
default[:nginx][:worker_priority] = -5
default[:nginx][:worker_connections] = 4096
default[:nginx][:event] = 'epoll'
default[:nginx][:keepalive_timeout] = 30

default[:env]['RAILS_ENV'] = 'production'

if node[:postgresql] && node[:postgresql][:database]
  default[:app][:database][:host] = 'localhost'
  default[:app][:database][:name] = node.postgresql.database
  default[:app][:database][:user] = node.postgresql.users[0].name
  default[:app][:database][:password] = node.postgresql.users[0].password
end
