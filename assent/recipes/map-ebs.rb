node[:opsworks][:ebs].each do |ebs|
  Chef::Log.info "setup ebs mount for  #{ebs[:layer]} at #{ebs[:mount_point]} with link: #{ebs[:link]}"
  directory "#{ebs[:mount_point]}#{ebs[:link]}" do
    owner ebs[:mount_owner]
    group ebs[:mount_group]
    mode 00770
    recursive true
    not_if { ::File.directory?(ebs[:mount_point]) }
  end

  link ebs[:link] do
    to "#{ebs[:mount_point]}#{ebs[:link]}"
    owner ebs[:mount_owner]
    group ebs[:mount_group]
    mode 00770
    not_if { ::File.directory?(ebs[:link]) }
  end
end
