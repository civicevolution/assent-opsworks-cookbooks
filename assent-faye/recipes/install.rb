#
# Cookbook Name:: ce2-custom
# Recipe:: install-faye
#
# Install and start Juggernaut server
#
# IMPORTANT: This has to run AFTER opsworks_nodejs is run

# redis is on the same machine as db

app_name = "assent_prod" # get this from stack json
faye_directory = '/opt/faye'
faye_server = "#{faye_directory}/server-redis.js"
faye_port = 8000
redis_host = "localhost" # get from stack json
redis_port = 6379

faye_user = 'deploy'
node_path = "/usr/local/bin/node"
faye_log_directory = "/var/log/faye-server-redis"
faye_log_name = "access.log"


directory faye_log_directory do
  recursive true
  owner "deploy"
  group "nobody"
  mode 0755
  not_if { ::File.directory?(faye_log_directory) }
end


#pid_directory = '/var/run/faye'
#pid_file = '/var/run/faye/faye.pid'
#log_file = '/var/log/engineyard/juggernaut.log'
#chef_file = '/etc/chef/dna.json'
#chef_config = JSON.parse(File.read(chef_file))
#master_app_server_host = chef_config['master_app_server']['public_ip']
#node_js_port = 8080

#redis_host = 'http://brian:123@ec2-50-18-101-127.us-west-1.compute.amazonaws.com:6379'

# Install nodejs & npm using recipe opsworks_nodejs::default

# Create a directory where I want to run Faye

directory faye_directory do
  recursive true
  owner "deploy"
  group "nobody"
  mode 0755
  not_if { ::File.directory?(faye_directory) }
end

#
# Install Faye

npmlist  = `npm list --depth=0`

nodejs_npm "faye" do
  cwd  faye_directory
  path faye_directory
  action :install
  not_if { npmlist =~ /faye@/ }
end

nodejs_npm "faye-redis" do
  cwd  faye_directory
  path faye_directory
  action :install
  not_if { npmlist =~ /faye-redis@/ }
end


#
# Add my server-redis.js file
#

template "#{faye_server}" do
  source "server-redis.js.erb"
  owner "deploy"
  group "root"
  mode 0755
  variables({
                :faye_port => faye_port,
                :redis_host => redis_host,
                :redis_port => redis_port
            })
end


# Run from upstart script
template "/etc/init/faye.conf" do
  source "faye.upstart.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
                :faye_user => faye_user,
                :node_path => node_path,
                :faye_server => faye_server,
                :faye_log_directory => faye_log_directory,
                :faye_log_name => faye_log_name
            })
end




execute "Start faye" do
  command "start faye"
  not_if("ps aux | grep faye/server-redis.js | grep -v grep | grep -v sudo")
end

=begin
#create pidfile directory
directory pid_directory do
  recursive true
  owner "deploy"
  group "nobody"
  mode 0755
  not_if { ::File.directory?(pid_directory) }
end
=end

=begin
# create monit script
# add to monit
case node[:instance_role]
  when "solo", "app_master"
    template "/etc/monit.d/juggernaut.monitrc" do
      source "juggernaut.monitrc.erb"
      owner "root"
      group "root"
      mode 0644
      variables({
                    :pid_file => pid_file
                })
    end
end
=end

=begin
execute "monit reload" do
  action :run
end
=end


=begin
# add log_rotate
  template "/etc/logrotate.d/juggernaut" do
    source "juggernaut.logrotate.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
      :pid_file => pid_file,
      :log_file => log_file
    })
  end
=end

=begin
# do I need a symlink?
  execute "symlink juggernaut" do
    # create a sym link to juggernuat
    command "ln -sfv /opt/nodejs/bin/juggernaut /usr/local/bin"
    not_if { FileTest.exists?("/usr/local/bin/juggernaut") }
  end
=end




