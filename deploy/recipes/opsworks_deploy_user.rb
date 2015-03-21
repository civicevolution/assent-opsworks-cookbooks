include_recipe 'dependencies'

node[:deploy].each do |application, deploy|

  opsworks_deploy_user do
  end

end
