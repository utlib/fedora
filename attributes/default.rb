#
# Cookbook Name:: fedora
# Default:: default
#
# Copyright 2012 UTL
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

default['fedora']['db_name'] = ""
default['fedora']['mysql_host'] = ""
default['fedora']['db_user_name'] = ""
default['fedora']['db_user_pwd'] = ""
default['fedora']['root'] = "/opt/fedora"
default['fedora']['real_root'] = "/opt/fedora3"
default['fedora']['source_server'] = ""
default['fedora']['source_path'] = ""
default['fedora']['version'] = ""
default['fedora']['install_tmp'] = ""
default['fedora']['fedora_admin_pass'] = ""
default['fedora']['fedora_admin_user'] = "fedoraAdmin"
default['fedora']['allow_non_local'] = "yes"

###properties for install.prpoerties
default['fedora']['resource_index_enabled'] = "true"
default['fedora']['messaging_enabled'] = "true"
default['fedora']['apia_auth_required'] = "false"
default['fedora']['database_jdbcDriverClass'] = "com.mysql.jdbc.Driver"
default['fedora']['ssl_available'] = "false"
default['fedora']['messaging_uri'] = "vm\\:(broker\\:(tcp\\://localhost\\:61616))"
default['fedora']['database_mysql_driver'] = "/usr/share/java/mysql-connector-java.jar"
default['fedora']['fesl_authz_enabled'] = "false"
default['fedora']['deploy_local_services'] = "true"
default['fedora']['xacml_enabled'] = "false"
default['fedora']['database_mysql_jdbcDriverClass'] = "com.mysql.jdbc.Driver"
default['fedora']['fedora_serverHost'] = "#{node['fqdn']}"
default['fedora']['database'] = "mysql"
default['fedora']['database_driver'] = "/usr/share/java/mysql-connector-java.jar"
default['fedora']['fedora_serverContext'] = "fedora"
default['fedora']['llstore_type'] = "akubra-fs"
default['fedora']['fesl_authn_enabled'] = "true"
default['fedora']['install_type'] = "custom"
default['fedora']['servlet_engine'] = "existingTomcat"
