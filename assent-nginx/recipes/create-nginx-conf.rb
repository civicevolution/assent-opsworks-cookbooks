apps = [
  { name: 'faye', port: 8000, keepalive: 32 },
  { name: 'api', port: 90001, keepalive: 32 }
]
serverName = "getAssent.com getAssent"
accessLog = "/var/log/nginx/getassent.log"
root = "/srv/www/getassent/current/public/"

# Run from upstart script
template "/etc/nginx/sites-available/nginx-nodejs.conf" do
  source "nginx-nodejs.conf.erb"
  owner "nginx"
  group "nginx"
  mode 0644
  variables({
                :apps => apps,
                :serverName => serverName,
                :accessLog => accessLog,
                :root => root
            })
end

link "/etc/nginx/sites-enabled/nginx-nodejs.conf" do
  to "/etc/nginx/sites-available/nginx-nodejs.conf"
  owner "nginx"
  group "nginx"
  not_if { ::File.exists("/etc/nginx/sites-enabled/nginx-nodejs.conf") }
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