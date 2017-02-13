define :rails_unicorn_app, owner: nil,
                           path_prefix: nil,
                           paths: :default,
                           assets: true,
                           config: nil,
                           database: nil,
                           worker_processes: 9 do
  name = params[:name]
  username = params[:owner]
  current_params = params
  worker_processes = params[:worker_processes].to_i
  path_prefix = params[:path_prefix]
  path_prefix = "/#{path_prefix}" if path_prefix && !path_prefix.start_with?('/')

  rails_basic_app name do
    owner username
    send :path_prefix, path_prefix
    assets current_params[:assets]
    paths current_params[:paths]
    database current_params[:database]
    config current_params[:config]
  end

  path = "/app/#{name}"
  current_path = "#{path}/current#{path_prefix}"
  shared_path = "#{path}/shared#{path_prefix}"
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
