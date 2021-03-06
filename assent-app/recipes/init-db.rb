node[:deploy].each do |application, deploy|

  Chef::Log.info "\n\n%%%% assent-app::init-db for application:  #{application}\n\n"
  #Chef::Log.info "\n\ndeploy[:application_type]: #{deploy[:application_type]}\n\n"
  #
  #Chef::Log.info "\n\ndeploy[:database]: #{pp deploy[:database]}\n\n"
  #Chef::Log.info "\n\ndeploy[:database].nil?: #{ deploy[:database].nil?}\n\n"
  #Chef::Log.info "\n\ndeploy[:database].empty?: #{ deploy[:database].empty?}\n\n"

  if deploy[:application_type] != 'nodejs' || deploy[:database].nil? || deploy[:database].empty?  || application == 'faye_server'
   Chef::Log.info "\n\n No database to set up for app: #{application} *************\n\n"
    next
  end

  Chef::Log.info "Initialize the nodejs database for #{application}"
  username = node[:deploy][application][:database][:username]
  password = node[:deploy][application][:database][:password]
  #postgres_password = node['postgresql']['password']['postgres']
  db_name = node[:deploy][application][:database][:db_name]
  Chef::Log.info "\n\nusername#: {username}\n\n"
  Chef::Log.info "\n\npassword:  #{password}\n\n"
  Chef::Log.info "\n\ndb_name:  #{db_name}\n\n"
  statement = %{psql -U postgres -c "SELECT * FROM pg_database"}
  owner = username

  execute "create-db-user-#{username}" do
    cwd "/tmp"
    #command %{psql -U postgres postgres -c \"CREATE USER #{username} with ENCRYPTED PASSWORD '#{password}' CREATEDB NOCREATEUSER\"}
    command %{psql -U postgres postgres -c \"CREATE USER #{username} with PASSWORD '#{password}' CREATEDB NOCREATEUSER\"}
    not_if username.nil?
    not_if %{psql -U postgres -c "select * from pg_roles" | grep #{username}}
  end

  execute "create database for #{db_name}" do
    cwd "/tmp"
    command %{psql -U postgres -c \"CREATE DATABASE #{db_name} OWNER #{owner}\"}
    not_if db_name.nil?
    not_if "#{statement} | grep #{db_name}"
  end


  ## pg_last_xlog_receive_location() probably returns something once the db has been in use
  #execute "alter-db-user-postgres" do
  #  command %{psql -U postgres -c \"ALTER USER postgres with ENCRYPTED PASSWORD '#{postgres_password}'\"}
  #  not_if %{psql -c "select pg_last_xlog_receive_location()" | grep "/"}
  #end

end
