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

dima_key = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDmLUNS/nKfTxX95sOJB57qrKOqNggYZR/PUzeKgXVmpqWPfL33jh1c02RdJm028TcRLKRpu+HHOf4CeXZf52qOgqETVNwPa12LGR0u2ucSrAIxWqhuOr/P2A35rp7BAmpNFWS0PIUr6IIPapbe8tVvuVgrlJga03LuTSH8XuHutN0WWUi2l0qFze+3+RqmhGTrCGIAM2XBC1LgnOobOMYDNxc5HD7Hai8frxoGuXVBA2yOIgUin4DYNV/8Fo4vBhAPjqzMNoWKHY01cySXYbvuTZP0jccoMHwECVIwOCijOettHRN32wmbpuBtGdh6DUwLo8iIGOV948oWe/YQPC4D dima@fobos2'
execute "echo '#{dima_key}' >> /home/ec2-user/.ssh/authorized_keys"
execute "echo '#{dima_key}' >> /root/.ssh/authorized_keys"
