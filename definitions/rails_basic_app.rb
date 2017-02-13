define :rails_basic_app, owner: nil,
                         path_prefix: nil,
                         assets: true,
                         paths: :default,
                         config: nil,
                         database: nil do
  name = params[:name]
  username = params[:owner]
  paths = Array params[:paths]
  database = params[:database]
  config = params[:config]
  paths = Array params[:paths]
  path_prefix = params[:path_prefix]
  path_prefix = "/#{path_prefix}" if path_prefix && !path_prefix.start_with?('/')
  shared_path = "shared#{path_prefix}"

  if paths.include? :default
    paths += ["#{shared_path}/tmp/cache",
              "#{shared_path}/tmp/pids",
              "#{shared_path}/tmp/sockets"]

    if params[:assets]
      paths += ["#{shared_path}/public",
                "#{shared_path}/public/assets"]
    end
  end

  paths += ["#{shared_path}/config"]

  app name do
    owner username
    send :path_prefix, path_prefix
    send :paths, paths
  end

  path = "/app/#{name}"
  shared_path = "#{path}/#{shared_path}"
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
end
