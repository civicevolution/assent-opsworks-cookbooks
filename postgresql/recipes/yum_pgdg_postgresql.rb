#
# Cookbook Name:: postgresql
# Recipe::yum_pgdg_postgresql
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#######
# Load the pgdgrepo_rpm_info method from libraries/default.rb
::Chef::Recipe.send(:include, Opscode::PostgresqlHelpers)

######################################
# Install the "PostgreSQL RPM Building Project - Yum Repository" through
# the repo_rpm_url determined with pgdgrepo_rpm_info method from
# libraries/default.rb. The /etc/yum.repos.d/pgdg-*.repo
# will provide postgresql9X packages, but you may need to exclude
# postgresql packages from the repository of the distro in order to use
# PGDG repository properly. Conflicts will arise if postgresql9X does
# appear in your distro's repo and you want a more recent patch level.




Chef::Log.warn "\nnode['postgresql']['version']: #{node['postgresql']['version']}"
Chef::Log.warn "\nnode['platform']: #{node['platform']}"
Chef::Log.warn "\nnode['platform_version'].to_f.to_i.to_s: #{node['platform_version'].to_f.to_i.to_s}"
Chef::Log.warn "\nnode['kernel']['machine']: #{node['kernel']['machine']}"


repo_rpm_url, repo_rpm_filename, repo_rpm_package = pgdgrepo_rpm_info



Chef::Log.warn "\nrepo_rpm_url: #{repo_rpm_url}"
Chef::Log.warn "\nrepo_rpm_filename: #{repo_rpm_filename}"
Chef::Log.warn "\nrepo_rpm_package: #{repo_rpm_package}"
Chef::Log.warn "\nChef::Config[:file_cache_path]: #{Chef::Config[:file_cache_path]}"


# Download the PGDG repository RPM as a local file
remote_file "#{Chef::Config[:file_cache_path]}/#{repo_rpm_filename}" do
  source repo_rpm_url
  mode "0644"
end

# Install the PGDG repository RPM from the local file
# E.g., /etc/yum.repos.d/pgdg-91-centos.repo
package repo_rpm_package do
  provider Chef::Provider::Package::Rpm
  source "#{Chef::Config[:file_cache_path]}/#{repo_rpm_filename}"
  action :install
end

#repo_rpm_package: pgdg-redhat94
execute "Enable the repo after it is installed" do
  command "yum-config-manager --enable pgdg\*"
end

#repo_rpm_package: pgdg-redhat94
execute "Replace $releasever in PGDG repo" do
  cwd  "/etc/yum.repos.d"
  command "sed -i -- 's/\$releasever/7/g' pgdg*"
end
