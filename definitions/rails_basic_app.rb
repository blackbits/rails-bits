define :rails_basic_app, owner: nil, paths: :default, database: nil do
  name = params[:name]
  username = params[:owner]
  path = Array params[:paths]
  database = params[:database]
  config = params[:config]

  if path.include? :default
    path += ['shared/tmp/cache',
             'shared/tmp/pids',
             'shared/tmp/sockets']
  end

  app name do
    owner username
    paths path
  end

  path = "/app/#{name}"
  current_path = "#{path}/current"
  shared_path = "#{path}/shared"
  logs_path = "#{shared_path}/log"

  directory "#{shared_path}/config" do
    recursive true
    owner username
    group username
    mode 00700
  end

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
