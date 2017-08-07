#
# Cookbook:: netsec
# Recipe:: iptables
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Because fuck systemd
service 'firewalld' do
    action [:disable, :stop]
end

