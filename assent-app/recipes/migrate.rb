#Chef::Log.info "\n\n%%%%% Assent migrate for nodejs Happens here, migrate flag #{@new_resource.migrate}\n"
Chef::Log.info "\n\n%%%%% Assent migrate for nodejs Happens here, migrate flag\n"

pp node

#if @new_resource.migrate
# # store variables for the ruby_block
# name = @new_resource.name
# stop_command = @new_resource.params[:deploy_data][:nodejs][:stop_command]
# restart_command = @new_resource.params[:deploy_data][:nodejs][:restart_command]
# user = @new_resource.user
# current_path = @new_resource.current_path
# migration_command = @new_resource.migration_command
# appName = @new_resource.params[:deploy_data][:application]
# psStr = "ps aux | grep #{appName}/current/server.js | grep -v NODE_PATH  | grep -v grep"
# Chef::Log.info "Inside migrate for appName #{appName}"
# #Chef::Log.info "name: #{name}"
# #Chef::Log.info "stop_command: #{stop_command}"
# #Chef::Log.info "restart_command: #{restart_command}"
# #Chef::Log.info "user: #{user}"
# #Chef::Log.info "current_path: #{current_path}"
# #Chef::Log.info "migration_command: #{migration_command}"
# ruby_block "stop node.js application #{appName}" do
#   block do
#     psAux = `#{psStr}`
#     Chef::Log.info "ps for nodejs server.js, psAux:  #{psAux}"
#     nodeRunning = psAux =~ /server.js/
#     # actually stop the service here
#     Chef::Log.info("stop node.js via: #{stop_command}")
#     Chef::Log.info(`#{stop_command}`)
#     #$? == 0
#     # wait for the service to be stopped
#     loopCtr = 60
#     while nodeRunning && loopCtr > 0 do
#       loopCtr -= 1
#       puts Time.now
#       psAux = `#{psStr}`
#       puts psAux
#       nodeRunning = psAux =~ /server.js/
#       if !nodeRunning
#         break
#       end
#       sleep 0.05
#     end
#     if nodeRunning
#       raise Exception.new("nodejs wasn't stopped in a timely manner")
#     end
#     Chef::Log.info "nodejs has stopped, run the migration for '#{appName}' now by continuing to the next block"
#   end
# end
# execute "do-migration: #{migration_command}" do
#   cwd current_path
#   user user
#   command migration_command
# end
#end