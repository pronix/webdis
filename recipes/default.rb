#
# Cookbook Name:: webdis
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'redis' do
	action :install
end
package 'nginx' do
	action :install
end
package 'httpd-tools' do
	action :install
end

package 'libevent-devel' do
	action :install
end

git '/tmp/webdis' do
	repository 'git://github.com/nicolasff/webdis.git'
	reference 'master'
	action :checkout
end

bash 'install-webdis' do
	code <<-EOC
		cd /tmp/webdis
		make
    make install
	EOC
  not_if { File.exists? '/usr/local/bin/webdis' }
end

service 'iptables' do
	action [:disable, :stop]
end

service 'redis' do
	action [:enable, :start]
end

execute 'sudo -u nobody /usr/local/bin/webdis &'

package 'libevent-devel' do
	action :install
end

git '/tmp/webdis' do
	repository 'git://github.com/nicolasff/webdis.git'
	reference 'master'
	action :checkout
end

bash 'install-webdis' do
	code <<-EOC
		cd /tmp/webdis
		make
    make install
	EOC
  not_if { File.exists? '/usr/local/bin/webdis' }
end

bash 'set basic passsword' do
  code <<-EOC
    htpasswd -cb /etc/nginx/htpass dariususer gjh65kHj7UYOPojndrettYt0o
  EOC
  not_if { File.exists? '/etc/nginx/htpass' }
end

bash 'close all except ssh http and localhost connections' do
  code <<-EOC
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -p tcp -s localhost -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -j DROP
    iptables-save > /etc/sysconfig/iptables
  EOC
  not_if { File.exists? '/etc/sysconfig/iptables' }
end

service 'iptables' do
	action [:enable, :restart]
end

service 'redis' do
	action [:enable, :start]
end

execute 'sudo -u nobody /usr/local/bin/webdis &'

template "/etc/nginx/conf.d/virtual.conf" do
  source "virtual.conf.erb"
  mode 0755
end

service 'nginx' do
	action [:enable, :restart]
end
