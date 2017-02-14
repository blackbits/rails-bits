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
  path_prefix = "#{path_prefix}/" if path_prefix && !path_prefix.end_with?('/')

  if paths.include? :default
    paths.delete :default

    paths += ["#{path_prefix}config",
              "#{path_prefix}log",
              "#{path_prefix}tmp/cache",
              "#{path_prefix}tmp/pids",
              "#{path_prefix}tmp/sockets"]

    if params[:assets]
      paths += ["#{path_prefix}public",
                "#{path_prefix}public/assets"]
    end
  else
    paths += ["#{path_prefix}config"]
  end

  app name do
    owner username
    send :path_prefix, path_prefix
    send :paths, paths
  end

  path = "/app/#{name}"
  shared_path = "#{path}/shared"
  shared_path += "/#{path_prefix}" if path_prefix
  logs_path = "#{shared_path}/log"

  if database
    db_config = database.reduce({}) do |result, (name, config)|
      result[name] = { adapter: 'postgresql',
                       encoding: 'utf8',
                       host: config.host,
                       database: config.name,
                       username: config.user,
                       password: config.password,
                       pool: 30,
                       allow_concurrency: true }
      result
    end

    yaml_config "#{shared_path}/config/database.yml" do
      send :config, db_config
    end
  end

  if config
    yaml_config "#{shared_path}/config/config.yml" do
      send :config, config
    end
  end
end
