define :rails_app, owner: nil, paths: :default, database: nil, domains: nil do
  rails_nginx_app name do
    domains params[:domains]
  end

  rails_unicorn_app name do
    owner params[:owner]
    paths params[:paths]
    database params[:database]
    config params[:config]
  end
end
