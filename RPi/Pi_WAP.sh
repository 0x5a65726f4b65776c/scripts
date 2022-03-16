#! /bin/bash

2>&1 >> Pi_WAP_Error_Log.txt
echo "Logging errors to $PWD/Pi_WAP_Error_Log.txt"

echo "[+]...Updating sudo system...[+]"
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
printf "interface wlan0\nstatic ip_address=192.168.0.1/24\ndenyinterfaces eth0\ndenyinterfaces wlan0\n" | tee -a /etc/dhcpcd.conf
tail /etc/dhcpcd.conf
sleep 3

echo "[+]...Confinguring DHCP server...[+]"
sleep 1
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
printf "interface=wlan0\n dhcp-range=192.168.0.2,192.168.0.254,255.255.255.0,24h\n" | tee -a /etc/dnsmasq.conf


echo "[+]...Confinguring hostapd...[+]"
printf "country_code=us\ninterface=wlan0\nbridge=br0\nhw_mode=g\nchannel=7\nwmm_enabled=0\nmacaddr_acl=0\nauth_algs=1\nignore_broadcast_ssid=0\nwpa=2\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP\nrsn_pairwise=CCMP\nssid=Something Witty\nwpa_passphrase=Y0u-W1ll-N0t-G3t,TH!$\n" | tee /etc/hostapd/hostapd.conf
if $? != 0;
    then echo "[+]***Command failed. Exiting now***[+]" && cat ./Pi_WAP_Error_Log.txt
    else echo "[+]***Command successful. Moving on***[+]" && sleep 3
fin

echo "[+]...Showing the sudo system where hostapg confing is...[+]"
printf "DAEMON_CONF="/etc/hostapd/hostapd.conf"" | tee -a /etc/default/hostapd
if $? != 0;
    then echo "[+]***Command failed. Exiting now***[+]" && cat ./Pi_WAP_Error_Log.txt
    else echo "[+]***Command successful. Moving on***[+]" && sleep 3
fin

echo "[+]...Forwarding IP traffic...[+]"
printf "net.ipv4.ip_forward=1" | tee -a /etc/sudo sysctl.conf
if $? != 0;
    then echo "[+]***Command failed. Exiting now***[+]" && cat ./Pi_WAP_Error_Log.txt
    else echo "[+]***Command successful. Moving on***[+]" && sleep 3
fin

echo "[+]...Editing IPTables rules...[+]"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sh -c "iptables-save > /etc/iptables.ipv4.nat"
if $? != 0;
    then echo "[+]***Command failed. Exiting now***[+]" && cat ./Pi_WAP_Error_Log.txt
    else echo "[+]***Command successful. Moving on***[+]" && sleep 3
fin

echo "[+]...Adding a new bridge...[+]"
brctl addbr br0
if $? != 0;
    then echo "[+]***Command failed. Exiting now***[+]" && cat ./Pi_WAP_Error_Log.txt
    else echo "[+]***Command successful. Moving on***[+]" && sleep 3
fin

echo "[+]...Linking br0 to eth0...[+]"
brctl addif br0 eth0
if $? != 0;
    then echo "[+]***Command failed. Exiting now***[+]" && cat ./Pi_WAP_Error_Log.txt
    else echo "[+]***Command successful. Moving on***[+]" && sleep 3
fin

echo "[+]...Adding br0 to Network Interfaces...[+]"
printf "auto br0 \niface br0 inet manual \nbridge_ports eth0 wlan0"
if $? != 0;
    then echo "[+]***Command failed. Exiting now***[+]" && cat ./Pi_WAP_Error_Log.txt
    else echo "[+]***Command successful. Moving on***[+]" && sleep 3
fin

echo "[+]...Enabling services...[+]"
sudo systemctl enable tor
sudo systemctl enable privoxy
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
if $? != 0;
    then echo "[+]***Command failed. Exiting now***[+]" && cat ./Pi_WAP_Error_Log.txt
    else echo "[+]***Command successful. Moving on***[+]" && sleep 3
fin

echo "[+]...Rebooting now...[+]"
sleep 3

sudo reboot
