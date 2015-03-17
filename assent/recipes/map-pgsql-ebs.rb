
#Chef::Log.info "do pretty print on node  #{}"
#Chef::Log.info "check for the mount_point node:  #{ JSON.pretty_generate(node) }"

Chef::Log.info "Find mount_point  #{}"
#mount_point = node['ebs']['raids']['/dev/md0']['mount_point'] rescue nil
mount_point = node['ebs']['devices']['/dev/xvdi']['mount_point'] rescue nil

Chef::Log.info "the mount_point IS   #{mount_point}"


if mount_point
  Chef::Log.info "Inside if mount_point with   #{mount_point}"
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