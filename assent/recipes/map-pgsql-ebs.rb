mount_point = node['ebs']['raids']['/dev/md0']['mount_point'] rescue nil

if mount_point
  directory "#{mount_point}/pgsql" do
    owner deploy[:user]
    group deploy[:group]
    mode 00770
    recursive true
  end

  link "/var/lib/pgsql-ebs" do
    to "#{mount_point}/pgsql"
  end
end

#if mount_point
#  node[:deploy].each do |application, deploy|
#    directory "#{mount_point}/#{application}" do
#      owner deploy[:user]
#      group deploy[:group]
#      mode 00770
#      recursive true
#    end
#
#    link "/srv/www/#{application}" do
#      to "#{mount_point}/#{application}"
#    end
#  end
#end