#
# Cookbook:: netsec
# Recipe:: iptables
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'simple_iptables'

# Because fuck systemd
service 'firewalld' do
    action [:disable, :stop]
end

# Base table policies
simple_iptables_policy 'INPUT' do
    policy 'DROP'
end
simple_iptables_policy 'FORWARD' do
    policy 'DROP'
end
simple_iptables_policy 'OUTPUT' do
    policy 'ACCEPT'
end

## INBOUND
#

## Basic Stack
# localhost allow
simple_iptables_rule "lo" do
    chain "INPUT"
    rule "-i lo"
    jump "ACCEPT"
end

# icmp allow
simple_iptables_rule "icmp" do
    chain "INPUT"
    rule [ "-p icmp --icmp-type echo-reply",
           "-p icmp --icmp-type destination-unreachable",
           "-p icmp --icmp-type time-exceeded" ]
    jump "ACCEPT"
end

## Services
# ssh
simple_iptables_rule "ssh" do
    chain "INPUT"
    rule "-m state --state NEW --proto tcp --dport 22"
    jump "ACCEPT"
end

# http
simple_iptables_rule "http" do
    chain "INPUT"
    rule [ "-m state --state NEW --proto tcp --dport 80",
           "-m state --state NEW --proto tcp --dport 443" ]
    jump "ACCEPT"
end

## Functional 
# conntrack inbound
simple_iptables_rule "conntrack" do
    chain "INPUT"
    rule "-m state --state RELATED,ESTABLISHED"
    jump "ACCEPT"
end

# Log spoofed addresses
simple_iptables_rule "log_spoof" do
    rule [ '-s 172.16.0.0/12 -j LOG --log-prefix "IP SPOOF A:: "',
           '-s 224.0.0.0/4 -j LOG --log-prefix "IP SPOOF MULTICAST: "',
           '-s 240.0.0.0/5 -j LOG --log-prefix "IP SPOOF B: "' ]
    jump false
end

# drop and log all other traffic
simple_iptables_rule "log_drop" do
    direction :none
    rule [ '-j LOG --log-level 4 --log-prefix "IPTABLES DROP: "',
           '-j DROP' ]
    jump false
end

