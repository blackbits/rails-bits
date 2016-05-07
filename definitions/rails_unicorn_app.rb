define :rails_unicorn_app, owner: nil, paths: nil, database: nil do
  name = params[:name]
  username = params[:owner]
  path = Array params[:paths]
  database = params[:database]
  config = params[:config]

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

  if database
    template 'config/database.yml' do
      path "#{shared_path}/config/database.yml"
      source 'database.yml.erb'
      cookbook 'rails-bits'
      owner username
      group username
      variables configs: database
    end
  end

  if config
    template 'config/config.yml' do
      path "#{shared_path}/config/config.yml"
      source 'config.yml.erb'
      cookbook 'rails-bits'
      owner username
      group username
      variables config: config
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
end
