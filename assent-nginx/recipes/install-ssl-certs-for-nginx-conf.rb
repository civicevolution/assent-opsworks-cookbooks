Chef::Log.info "%%%% Install placeholder certs so nginx will start after deploy"

template "/etc/nginx/nginx.crt" do
  source "nginx.crt.erb"
  owner "nginx"
  group "nginx"
  mode 0644
  not_if { ::File.exists?("/etc/nginx/nginx.crt") }
end

template "/etc/nginx/nginx.key" do
  source "nginx.key.erb"
  owner "nginx"
  group "nginx"
  mode 0644
  not_if { ::File.exists?("/etc/nginx/nginx.key") }
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action :restart
end