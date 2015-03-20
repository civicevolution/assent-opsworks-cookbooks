#
# original code from https://github.com/opscode/chef/blob/master/lib/chef/provider/deploy.rb
#
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# This patch will only show environment variables, when explicitly wanted. To do this
# the environment variable SHOW_ENVIRONMENT_VARIABLES must exist

class Chef
  class Provider
    class Deploy

      def migrate
        run_symlinks_before_migrate

        Chef::Log.info "\n\n%%%%% Assent migrate for nodejs Happens here, migrate flag #{@new_resource.migrate}\n"

        # store variables for the ruby_block
        name = @new_resource.name
        stop_command = @new_resource.params[:deploy_data][:nodejs][:stop_command]
        restart_command = @new_resource.params[:deploy_data][:nodejs][:restart_command]
        user = @new_resource.user
        current_path = @new_resource.current_path
        migration_command = @new_resource.migration_command

        Chef::Log.info "name: #{name}"
        Chef::Log.info "stop_command: #{stop_command}"
        Chef::Log.info "restart_command: #{restart_command}"
        Chef::Log.info "user: #{user}"
        Chef::Log.info "current_path: #{current_path}"
        Chef::Log.info "migration_command: #{migration_command}"

        ruby_block "stop node.js application #{@new_resource.name}" do
          block do
            puts "Stop nodejs before proceeding"
            psAux1 = `ps aux | grep assent/current/server.js | grep -v NODE_PATH  | grep -v grep`
            Chef::Log.info "ps for nodejs server.js, psAux1:  #{psAux1}"
            nodeRunning = psAux1 =~ /server.js/

            # actually stop the service here
            Chef::Log.info("stop node.js via: #{stop_command}")
            Chef::Log.info(`#{stop_command}`)
            #$? == 0

            # wait for the service to be stopped
            loopCtr = 60
            while nodeRunning && loopCtr > 0 do
              loopCtr -= 1
              puts Time.now
              psAux1 = `ps aux | grep assent/current/server.js | grep -v NODE_PATH  | grep -v grep`
              puts psAux1
              nodeRunning = psAux1 =~ /server.js/
              if !nodeRunning
                break
              end
              sleep 0.05
            end

            if nodeRunning
              raise Exception.new("nodejs wasn't stopped in a timely manner")
            end

            Chef::Log.info "nodejs has stopped, run the migration now by continuing to the next block"

          end
        end

        execute "do-migration: #{migration_command}" do
          cwd current_path
          user user
          command migration_command
        end

      end

    end
  end
end
