define :rails_unicorn_app, owner: nil,
                           paths: :default,
                           database: nil,
                           worker_processes: 9 do
  name = params[:name]
  username = params[:owner]
  path = Array params[:paths]
  db_config = params[:database]
  app_config = params[:config]
  worker_processes = params[:worker_processes].to_i

  if path.include? :default
    path += ['shared/public',
             'shared/public/assets']
  end

  rails_basic_app name do
    owner username
    paths path
    database db_config
    config app_config
  end

  path = "/app/#{name}"
  current_path = "#{path}/current"
  shared_path = "#{path}/shared"
  logs_path = "#{shared_path}/log"

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
              socket_path: socket_path,
              worker_processes: worker_processes
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
