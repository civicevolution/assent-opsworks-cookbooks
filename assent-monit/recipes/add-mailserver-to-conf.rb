template node[:monit][:conf] do
  source "monitrc.erb"
  mode 0600
  #TODO: This should only happen if the service is running, after rebooting
  #  notifies :restart, resources(:service => "monit")
end