define :rails_app, owner: nil, paths: nil, database: nil, domains: nil do
  name = params[:name]
  username = params[:owner]
  path = Array params[:paths]
  domains = Array params[:domains]

  if path.include? :default
    path += ['shared/tmp/cache',
             'shared/tmp/pids',
             'shared/tmp/sockets',
             'shared/public',
             'shared/public/assets']
  end

  app name do
    owner username
    paths path
  end

  path = "/app/#{name}"
  current_path = "#{path}/current"
  shared_path = "#{path}/shared"
  logs_path = "#{shared_path}/log"

  if params[:database]
    template 'config/database.yml' do
      path "#{shared_path}/config/database.yml"
      source 'database.yml.erb'
      cookbook 'rails-bits'
      owner username
      group username
      variables configs: params[:database]
    end
  end

  pid_path = "#{shared_path}/tmp/pids/unicorn.pid"
  socket_path = "#{shared_path}/tmp/sockets/unicorn.sock"

  template 'config/unicorn.rb' do
    path "#{shared_path}/config/unicorn.rb"
    source 'unicorn.rb.erb'
    cookbook 'rails-bits'
    owner username
    group username
    variables path: current_path,
              pid_path: pid_path,
              log_path: "#{logs_path}/unicorn",
              socket_path: socket_path
  end

  logrotate_app "unicorn-#{name}" do
    path        "#{logs_path}/production.log"
    frequency   'daily'
    create      "644 #{username} #{username}"
    rotate      7
    compress
    dateext
    delaycompress
    notifempty
    missingok
    lastaction "/etc/init.d/#{name} reopen-logs"
  end

  template "/etc/init.d/#{name}" do
    source 'unicorn_init.erb'
    cookbook 'rails-bits'
    mode 0755
    variables path: current_path,
              pid_path: pid_path,
              username: username
  end

  template "/etc/nginx/sites-available/#{name}" do
    source 'app.conf.erb'
    cookbook 'rails-bits'
    variables domains: domains,
              path: "#{current_path}/public",
              socket_path: socket_path,
              log_path: "#{logs_path}/nginx"

    notifies :reload, resources(service: 'nginx')
  end

  logrotate_app "nginx-#{name}" do
    path       "#{logs_path}/nginx.access.log", "#{logs_path}/nginx.error.log"
    frequency  'daily'
    create     "644 #{username} #{username}"
    rotate     7
    compress
    dateext
    delaycompress
    notifempty
    missingok
    copytruncate
    sharedscripts true
    postrotate '[ ! -f /var/run/nginx.pid ] || kill -USR1 `cat /var/run/nginx.pid`'
  end

  nginx_site name do
    action :enable
  end
end
