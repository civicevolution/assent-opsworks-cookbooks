include_recipe 'dependencies'

node[:deploy].each do |application, deploy|

  opsworks_deploy_user do

    if deploy[:application_type] == 'nodejs'
      template "#{deploy[:deploy_to]}/shared/config/opsworks.js" do
        cookbook 'opsworks_nodejs'
        source 'opsworks.js.erb'
        mode '0660'
        owner deploy[:user]
        group deploy[:group]
        variables(:database => deploy[:database], :memcached => deploy[:memcached], :layers => node[:opsworks][:layers])
      end
    end

    deploy_data deploy
  end

end
