define :rails_nginx_app, domains: nil,
                         mounts: {},
                         default: false,
                         disable_assets: false do
  name = params[:name]
  domains = Array params[:domains]
  default = params[:default]
  disable_assets = params[:disable_assets]
  username = params[:username]
  mounts = Hash[*params[:mounts].map {|app_name, mount|
    mount = if mount.is_a? Hash
              mount
            elsif mount.is_a? Regexp
              { path: "~* #{mount.inspect[1..-2]}",
                external: false }
            else
              { path: mount,
                external: false }
            end
    [app_name, mount]
  }.flatten]

  path = "/app/#{name}"
  current_path = "#{path}/current"
  shared_path = "#{path}/shared"
  logs_path = "#{shared_path}/log"
  socket_path = "#{shared_path}/tmp/sockets/unicorn.sock"

  template "/etc/nginx/sites-available/#{name}" do
    source 'app.conf.erb'
    cookbook 'rails-bits'
    variables name: name,
              default: default,
              domains: domains,
              path: "#{current_path}/public",
              socket_path: socket_path,
              log_path: "#{logs_path}/nginx",
              mounts: mounts,
              disable_assets: disable_assets

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
