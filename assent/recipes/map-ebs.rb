node[:opsworks][:ebs].each do |ebs|
  dir = "#{ebs[:mount_point]}#{ebs[:link]}"
  Chef::Log.info "setup ebs mount for  #{ebs[:layer]} at mount_point #{ebs[:mount_point]} as dir: #{dir} with link: #{ebs[:link]}"
  directory dir do
    owner ebs[:mount_owner]
    group ebs[:mount_group]
    mode 00770
    recursive true
    not_if { ::File.directory?( dir ) }
  end

  link ebs[:link] do
    to dir
    owner ebs[:mount_owner]
    group ebs[:mount_group]
    not_if { ::File.symlink?(ebs[:link]) }
  end
end
