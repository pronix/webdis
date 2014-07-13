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

package "libevent-devel" do
	action :install
end

git "/tmp/webdis" do
	repository "git://github.com/nicolasff/webdis.git"
	reference "master"
	action :checkout
end

bash "install-webdis" do
	code <<-EOC
		cd /tmp/webdis
		make
    make install
	EOC
  not_if { File.exists? "/usr/local/bin/webdis" }
end

service "iptables" do
	action [:disable, :stop]
end

service 'redis' do
	action [:enable, :start]
end

execute "sudo -u nobody /usr/local/bin/webdis &"
