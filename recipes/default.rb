#
# Cookbook Name:: fedora
# Recipe:: default
#
# Copyright 2012, UTL
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

include_recipe "ark::mysql-connector"
include_recipe "database::mysql"
include_recipe "tomcat::mysqljar"

# define the database connection
mysql_connection = ({:host => node['fedora']['mysql_host'], :username => 'root', :password => node['mysql']['server_root_password']})

# create the fedora mysql database
mysql_database node['fedora']['db_name'] do
  connection mysql_connection
  action :create
end

# create the fedora user
mysql_database_user node['fedora']['db_user_name'] do
  connection mysql_connection
  password node['fedora']['db_user_pwd']
  action :create
end

# grant permissions to locahost
mysql_database_user node['fedora']['db_user_name'] do
  connection mysql_connection
  password node['fedora']['db_user_pwd']
  database_name node['fedora']['db_name']
  host node['fedora']['mysql_host']
  action :grant
end

# grant permissions
mysql_database_user node['fedora']['db_user_name'] do
  connection mysql_connection
  password node['fedora']['db_user_pwd']
  database_name node['fedora']['db_name']
  host node['ipaddress']
  action :grant
end

# make the fedora directory
directory node['fedora']['real_root'] do
  owner "#{node['tomcat']['user']}"
  group "root"
  mode "0755"
  action :create
end

# ln -s /opt/fedora to /opt/fedora3
link node['fedora']['root'] do
  to "#{node['fedora']['real_root']}"
end

# add link required for tomcat (may not matter but installation fails otherwise)
link "#{node['tomcat']['base']}/common/lib" do
  to "classes"
  owner "#{node['tomcat']['user']}"
  group "#{node['tomcat']['user']}"
end

##Create directory to store install scripts in
directory "#{node['fedora']['install_tmp']}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

##get the insall script
remote_file "#{node['fedora']['install_tmp']}/fcrepo-installer-#{node['fedora']['version']}.jar" do
  source "http://#{node['fedora']['source_server']}/#{node['fedora']['source_path']}/fcrepo-installer-#{node['fedora']['version']}.jar"
  mode "0644"
  checksum "aa1d29752a3b62660f3902fdf2763fdd5e3482265b3df920e84c6b5ce38f687e"
  action :create_if_missing
end

##get the install.properties from template
template "#{node['fedora']['install_tmp']}/install.properties" do
  source "install.properties.#{node['fedora']['version']}.erb"
  owner "root"
  group "root"
  mode 0644
end

## install Fedora
execute "install_fedora" do
  command "java -jar #{node['fedora']['install_tmp']}/fcrepo-installer-#{node['fedora']['version']}.jar #{node['fedora']['install_tmp']}/install.properties"
  creates "#{node['fedora']['root']}/server/config/fedora.fcfg"
  action :run
end

##set ownership to tomcat for /opt/fedora/*, restart tomcat, sleep for, required for Fedora to create directory for apim file below
bash "set_tomcat_perms" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  chown -R #{node['tomcat']['user']} #{node['fedora']['root']}/*
  service tomcat6 restart
  EOH
  not_if "test `stat -c %U #{node['fedora']['root']}/server/config/fedora.fcfg` = tomcat6"
end

## put apim/xacls file in place
cookbook_file "#{node['fedora']['root']}/data/fedora-xacml-policies/repository-policies/default/permit-apim-to-authenticated.xml" do
  source "permit-apim-to-authenticated.xml"
  owner "#{node['tomcat']['user']}"
  group "#{node['tomcat']['user']}"
  mode "0644"
  notifies :restart, resources(:service => "tomcat")
  retries 10
  retry_delay 10
end

if node['fedora']['allow_non_local'] == "yes"
  %w{ data/fedora-xacml-policies/repository-policies/default/deny-apim-if-not-localhost.xml data/fedora-xacml-policies/repository-policies/default/deny-reloadPolicies-if-not-localhost.xml server/fedora-internal-use/fedora-internal-use-repository-policies-approximating-2.0/deny-apim-if-not-localhost.xml server/fedora-internal-use/fedora-internal-use-repository-policies-approximating-2.0/deny-reloadPolicies-if-not-localhost.xml }.each do |deletethese|
    file "#{node['fedora']['root']}/#{deletethese}" do
      action :delete
      notifies :restart, resources(:service => "tomcat")
    end
  end
end
