define :yaml_config, config: nil do
  username = node.owner.username
  current_params = params

  template params[:name] do
    source 'config.yml.erb'
    cookbook 'rails-bits'
    owner username
    group username
    variables config: current_params[:config]
  end
end
