node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    next
  end

  log "Run the database migration for #{application}"
  Chef::Log.info "CL: Run the database migration for  #{application}"

  Chef::Log.info "CL: pp deploy  #{ pp deploy}"
  
  Chef::Log.info "ok  #{}"

  pp deploy



  #username = node[:deploy][application][:database][:username]
  #password = node[:deploy][application][:database][:password]
  ##postgres_password = node['postgresql']['password']['postgres']
  #db_name = node[:deploy][application][:database][:db_name]
  #statement = %{psql -U postgres -c "SELECT * FROM pg_database"}
  #owner = username
  #
  #execute "create-db-user-#{username}" do
  #  #command %{psql -U postgres postgres -c \"CREATE USER #{username} with ENCRYPTED PASSWORD '#{password}' CREATEDB NOCREATEUSER\"}
  #  command %{psql -U postgres postgres -c \"CREATE USER #{username} with PASSWORD '#{password}' CREATEDB NOCREATEUSER\"}
  #  not_if %{psql -U postgres -c "select * from pg_roles" | grep #{username}}
  #end
  #
  #execute "create database for #{db_name}" do
  #  command %{psql -U postgres -c \"CREATE DATABASE #{db_name} OWNER #{owner}\"}
  #  not_if "#{statement} | grep #{db_name}"
  #end

end