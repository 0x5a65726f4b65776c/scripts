#! /bin/bash

2>&1 >> Pi_WAP_Error_Log.txt
echo "Logging script errors to $PWD/Pi_WAP_Error_Log.txt"

echo "[+]...Updating system...[+]"
sleep 3
apt update && apt full-upgrade -y && apt autoremove -y && apt autoclean
sleep 1

echo "[+]...Installing TOR, Privoxy, HostAPD, IPTables, bridge utils, and DNSMasq...[+]"
apt install -y tor privoxy hostapd dnsmasq iptables bridge-utils

echo "[+]...Temporarily stopping HostAPD, DNSMasq, TOR, and Privoxy services...[+]"
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
sudo systemctl stop tor
sudo systemctl stop privoxy


echo "[+]...Editing DHCP confing finle...[+]"
sleep 3
printf "interface wlan0 \nstatic ip_address=192.168.0.1/24 \ndenyinterfaces eth0 \ndenyinterfaces wlan0\n" | tee -a /etc/dhcpcd.conf
tail /etc/dhcpcd.conf
sleep 3

echo "[+]...Confinguring DHCP server...[+]"
sleep 1
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
printf "interface=wlan0 \ndhcp-range=192.168.0.2,192.168.0.254,255.255.255.0,24h\n" | tee -a /etc/dnsmasq.conf


echo "[+]...Confinguring hostapd...[+]"
printf "country_code=us \ninterface=wlan0 \nbridge=br0 \nhw_mode=g \nchannel=7 \nwmm_enabled=0 \nmacaddr_acl=0 \nauth_algs=1 \nignore_broadcast_ssid=0 \nwpa=2\n wpa_key_mgmt=WPA-PSK \nwpa_pairwise=TKIP \nrsn_pairwise=CCMP \nssid=***YOUR NETWORK*** \nwpa_passphrase=***YOUR PASSWORD***\n
