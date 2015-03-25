template "/etc/monit.d/nginx.monitrc" do
  source "nginx.monitrc.erb"
  owner "root"
  group "root"
  mode 0644
  not_if { ::File.exists?("/etc/monit.d/nginx.monitrc") }
end

