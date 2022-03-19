#! /bin/bash

#This will download and configure everything needed to turn your Pi into a Wireless Access Point
read -p 'Network name: ' ssid
read -p 'Network passphrase: ' passphrase

{
echo "Logging script errors to $PWD/Pi_WAP_Errors.txt"

echo "[+]...Updating your system...[+]"
sleep 3
apt update && apt full-upgrade -y && apt autoclean && apt autoremove -y
sleep 1

echo "[+]...Installing TOR, Privoxy, HostAPD, IPTables, Bridge Utils, and DNSMasq...[+]"
apt install -y tor privoxy hostapd dnsmasq iptables

echo "[+]...Temporarily stopping HostAPD, DNSMasq, TOR, and Privoxy services...[+]"
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
sudo systemctl stop tor
sudo systemctl stop privoxy

echo "[+]...Editing the DHCP config file...[+]"
sleep 3
printf "interface=wlan0\nstatic ip_address=192.168.0.1\ndenyinterfaces eth0\ndenyinterfaces wlan0\n" | tee -a /etc/dhcpcd.conf
tail /etc/dhcpcd.conf
sleep 3

echo "[+]...Configuring the DHCP server...[+]"
sleep 1
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
printf "interface=wlan0\n dhcp-range=192.168.0.2,192.168.0.254,255.255.255.0,24h\n" | tee -a /etc/dnsmasq.conf

echo "[+]...Configuring hostapd...[+]"
printf "country_code=US\ninterface=wlan0\nbridge=br0\nhw_mode=g\nchannel=7\nwmm_enabled=0\nmacaddr_acl=0\nauth_algs=1\nignore_broadcast_ssid=0\nwpa=2\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP\nrsn_pairwise=CCMP\nssid=$ssid\nwpa_passphrase=$passphrase" | tee /etc/hostapd/hostapd.conf

echo "[+]...Telling the system where hostapd config is...[+]"
printf "DAEMON_CONF="/etc/hostapd/hostapd.conf"" | tee -a /etc/default/hostapd

echo "[+]...Forwarding IP traffic...[+]"
printf "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf

echo "[+]...Editing IPTables rules...[+]"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo "[+]...Adding the bridge interface as br0...[+]"
printf "[NetDev]\nName=br0\nKind=bridge | sudo tee -a /etc/systemd/network/bridge-br0.netdev

echo "[+]...Linking br0 to eth0...[+]"
printf "[Match]\nName=eth0\n\n[Network]\nBridge=br0

sudo systemctl enable systemd-networkd

echo "[+]***Ensuring WiFi isn't blocked***[+]
sudo rfkill unblock wlan

echo "[+]...Enabling services...[+]"
sudo systemctl enable tor
sudo systemctl enable privoxy
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq

echo "[+]...Rebooting now...[+]"
sleep 3
} 2>&1 >> $PWD/Pi_WAP_Errors.txt

sudo reboot
