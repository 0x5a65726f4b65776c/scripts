#!/bin/bash

vpn=$1

echo "[+] Establishing connection [+]"
sudo openvpn --config home/kali/Documents/OVPN/$vpn.ovpn --daemon

if [ grep"Initialization Sequence Completed" ] ;
then
	echo "[+] Connection Successful [+]"
else 
	echo "[+] Connection Unsuccessful [+]"
fi 
	
