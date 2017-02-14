define :unicorn_initd, path: nil,
                       pid_path: nil do
  username = node.owner.username
  template "/etc/init.d/#{params[:name]}" do
    source 'unicorn_init.erb'
    cookbook 'rails-bits'
    mode 0755
    variables path: params[:path],
              pid_path: params[:pid_path],
              username: username
  end
end
