include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    Chef::Log.debug("Skipping deploy::nodejs for application #{application} as it is not a node.js app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  opsworks_nodejs do
    deploy_data deploy
    app application
  end

  application_environment_file do
    user deploy[:user]
    group deploy[:group]
    path ::File.join(deploy[:deploy_to], "shared")
    environment_variables deploy[:environment_variables]
  end

  Chef::Log.info "\n\nBefore ruby_block, deploy[:nodejs][:knex_migrate]: #{deploy[:nodejs][:knex_migrate]}\n"


  ruby_block "Do migration for application #{application}" do
    block do
      Chef::Log.info "pp deploy:  #{}"
      pp deploy

      Chef::Log.info "\n\n%%%%% Assent migrate for nodejs Happens here, migrate flag (deploy[:nodejs][:knex_migrate]): #{deploy[:nodejs][:knex_migrate]}\n"

      # store variables for the ruby_block
      stop_command = deploy[:nodejs][:stop_command]
      restart_command = deploy[:nodejs][:restart_command]
      user = deploy[:user]
      current_path = deploy[:current_path]
      migration_command = deploy[:nodejs][:migration_command]
      appName = deploy[:application]
      psStr = "ps aux | grep #{appName}/current/server.js | grep -v NODE_PATH  | grep -v grep"

      Chef::Log.info "Inside migrate for appName #{appName}"
      Chef::Log.info "stop_command: #{stop_command}"
      Chef::Log.info "restart_command: #{restart_command}"
      Chef::Log.info "user: #{user}"
      Chef::Log.info "current_path: #{current_path}"
      Chef::Log.info "migration_command: #{migration_command}"
      Chef::Log.info "psStr: #{psStr}"


      psAux = `#{psStr}`

      Chef::Log.info "ps for nodejs server.js, psAux:  #{psAux}"
      nodeRunning = psAux =~ /server.js/

      # actually stop the service here
      Chef::Log.info("stop node.js via: #{stop_command}")
      Chef::Log.info(`#{stop_command}`)
      #$? == 0

      # wait for the service to be stopped
      loopCtr = 60
      while nodeRunning && loopCtr > 0 do
        loopCtr -= 1
        puts Time.now
        psAux = `#{psStr}`
        puts psAux
        nodeRunning = psAux =~ /server.js/
        if !nodeRunning
          break
        end
        sleep 0.05
      end

      if nodeRunning
        raise Exception.new("nodejs wasn't stopped in a timely manner")
      end

      Chef::Log.info "nodejs has stopped, run the migration for '#{appName}' now by continuing to the next block"

      `cd #{current_path}`
      `su #{user}`
      `#{migration_command}`

      execute "do-migration: #{migration_command}" do
        cwd current_path
        user user
        command migration_command
      end

      Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
      Chef::Log.info(`#{node[:deploy][application][:nodejs][:restart_command]}`)
      $? == 0
    end
    only_if deploy[:nodejs][:knex_migrate]
  end

  ruby_block "restart node.js application #{application}" do
    block do
      Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
      Chef::Log.info(`#{node[:deploy][application][:nodejs][:restart_command]}`)
      $? == 0
    end
  end
end
