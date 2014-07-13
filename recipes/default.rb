#
# Cookbook Name:: webdis
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

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
	EOC
end

service "iptables" do
	action [:disable, :stop]
end
