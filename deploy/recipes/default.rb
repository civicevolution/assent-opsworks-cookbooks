include_recipe 'dependencies'

Chef::Log.info("\n\n\nCustom deploy::default\n\n\n")

node[:deploy].each do |application, deploy|

  Chef::Log.info "\n\n$$$$$ pp deploy  #{}"
  pp deploy

  opsworks_deploy_user do

    Chef::Log.info "deploy[:user]  #{deploy[:user]}"

    if deploy[:application_type] == 'nodejs'

      Chef::Log.info "Create opsworks.js with deploy[:database]  #{deploy[:database]}"

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
