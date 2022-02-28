#! /bin/bash

printf "[+]...Updating system...[+]
apt update && apt full-upgrade -y && apt autoremove -y && apt autoclean
sleep 1

printf "[+]...Installing TOR, Privoxy, HostAPD, IPTables, bridge utils, and DNSMasq...[+]"
apt install -y tor privoxy hostapd dnsmasq iptables bridge-utils
sleep 1

printf "[+]...Stopping hostapd and dnsmasq...[+]"
systemctl stop hostapd
systemctl stop dnsmasq
systemctl stop tor
systemctl stop privoxy
sleep 1

printf "[+]...Editing DHCP config file...[+]"
sleep 1
printf "interface wlan0\n static ip_address=192.168.0.1/24\n denyinterfaces eth0\n denyinterfaces wlan0" | tee -a /etc/dhcpcd.conf
tail /etc/dhcpcd.conf
sleep 3

printf "[+]...Configuring DHCP server...[+]"
sleep 1
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
printf "interface=wlan0\n dhcp-range=192.168.0.2,192.168.0.254,255.255.255.0,24h" | tee -a /etc/dnsmasq.conf
sleep 1

printf "[+]...Configuring hostapd...[+]"
printf "country_code=us\n interface=wlan0\n bridge=br0\n hw_mode=g\n channel=7\n wmm_enabled=0\n macaddr_acl=0\n auth_algs=1\n ignore_broadcast_ssid=0\n wpa=2\n wpa_key_mgmt=WPA-PSK\n wpa_pairwise=TKIP\n rsn_pairwise=CCMP\n ssid=***NETWORK***\n wpa_passphrase=***PASSWORD***"
sleep 1

printf "[+]...Showing the system where hostapg config is...[+]"
printf "DAEMON_CONF="/etc/hostapd/hostapd.conf" | tee -a /etc/default/hostapd
sleep 1

printf "[+]...Forwarding IP traffic...[+]"
printf "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf

printf "[+]...Editing IPTables rules...[+]"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sh -c "iptables-save > /etc/iptables.ipv4.nat"

printf "[+]...Adding a new bridge...[+]"
brctl addbr br0

printf "[+]...Linking br0 to eth0...[+]"
brctl addif br0 eth0
sleep 1

printf "[+]...Adding br0 to Network Interfaces...[+]"
printf "auto br0\n iface br0 inet manual\n bridge_ports eth0 wlan0"
sleep 1

printf "[+]...Enabling services...[+]"
systemctl enable tor
systemctl enable privoxy
systemctl enable hostapd
systemctl enable dnsmasq 

printf "[+]...Rebooting...[+]"
sleep 3

reboot