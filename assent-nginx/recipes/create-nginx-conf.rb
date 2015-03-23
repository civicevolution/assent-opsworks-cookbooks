#apps = [
#  { mount_name: 'faye', port: 8000, keepalive: 32 },
#  { mount_name: 'api', port: 9002, keepalive: 32 }
#]

Chef::Log.info "%%%% nginx needs actual data from custom json  #{}"
#Chef::Log.info "pp node[:deploy]:"
#pp node[:deploy]



apps = []
node[:deploy].each do |application, deploy|
  nodejs = deploy[:nodejs]
  apps.push( { mount_name: nodejs[:mount_name], port: nodejs[:port], keepalive: nodejs[:keepalive] || 32 } )
end

Chef::Log.info "pp app:"
pp apps


serverName = node[:nginx][:serverName]
accessLog = node[:nginx][:accessLog]
rootPath = node[:nginx][:rootPath]
confFileName = "#{serverName.gsub(/\W/,'-')}.conf"

Chef::Log.info "serverName  #{serverName}"
Chef::Log.info "accessLog  #{accessLog}"
Chef::Log.info "rootPath  #{rootPath}"
Chef::Log.info "confFileName  #{confFileName}"

# serverName = "getAssent.com getAssent"
# accessLog = "/var/log/nginx/getassent.log"
# rootPath = "/srv/www/getassent/current/public/"

#template "/etc/nginx/sites-available/nginx-nodejs.conf" do
template "/etc/nginx/sites-available/#{confFileName}" do
  source "nginx-nodejs.conf.erb"
  owner "nginx"
  group "nginx"
  mode 0644
  variables({
                :apps => apps,
                :serverName => serverName,
                :accessLog => accessLog,
                :rootPath => rootPath
            })
end

link "#{confFileName}" do
  target_file "/etc/nginx/sites-enabled/#{confFileName}"
  to          "/etc/nginx/sites-available/#{confFileName}"
  owner       "nginx"
  group       "nginx"
  not_if { ::File.exists?("/etc/nginx/sites-enabled/#{confFileName}") }
end

directory rootPath do
  recursive true
  owner "nginx"
  group "nginx"
  mode 0755
  not_if { ::File.directory?(rootPath) }
end

template "/srv/www/getassent/current/public/index.html" do
  source "index.html.erb"
  owner "nginx"
  group "nginx"
  mode 0644
end


# restart nginx
#execute "Start faye" do
#  command "start faye"
#  not_if("ps aux | grep faye/server-redis.js | grep -v grep | grep -v sudo")
#end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action :restart
end