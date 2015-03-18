apps = [
  { name: 'faye', port: 8000, keepalive: 32 },
  { name: 'api', port: 9002, keepalive: 32 }
]
serverName = "getAssent.com getAssent"
accessLog = "/var/log/nginx/getassent.log"
rootPath = "/srv/www/getassent/current/public/"


template "/etc/nginx/sites-available/nginx-nodejs.conf" do
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

link "nginx-nodejs.conf" do
  target_file "/etc/nginx/sites-enabled/nginx-nodejs.conf"
  to          "/etc/nginx/sites-available/nginx-nodejs.conf"
  owner       "nginx"
  group       "nginx"
  not_if { ::File.exists?("/etc/nginx/sites-enabled/nginx-nodejs.conf") }
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