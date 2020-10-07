#!/bin/bash

url=$1

if [[! ~/Desktop/Offsec/$url/Recon]]; then
mkdir -p ~/Desktop/OffSec/$url/Recon
fi

sudo apt install -y masscan

echo "[+] Gathering WhoIs data [+]"
whois $url | tee -a ~/Desktop/OffSec/Recon/$url/Recon/whois.txt

echo "[+] Gathering Harvester Data [+]"
theharvester -d $url -b all | tee -a ~/Desktop/OffSec/Recon/$url/Recon/theHarvester.txt

echo "[+] Starting DNSrecon [+]"
dnsrecon -d $url -t axfr | tee -a ~/Desktop/OffSec/Recon/$url/Recon/DNSrecon.txt

echo "[+] Starting dnsenum [+]"
dnsenum $url | tee -a ~/Desktop/OffSec/Recon/$url/Recon/dnsenum.txt

echo "[+] Running nmap [+]"

#PwK NMAP exercises
sudo nmap -Pn -sn $url -oG ~/Desktop/OffSec/Recon/$url/Recon/nmap | grep Up | cut " " -f 2 | sort -u | tee -a ~/Desktop/OffSec/Recon/$url/Recon/nmapUp.txt
sudo nmap -Pn -p 80,443  -O -A -iL ~/Desktop/OffSec/Recon/$url/Recon/nmapUp.txt -oN ~/Desktop/OffSec/Recon/$url/Recon/nmapWeb.txt
sudo nmap -Pn --script smb* 10.0.0.0/8 -oN ~/Desktop/OffSec/Recon/$url/Recon/nmapLabSMB.txt

sudo nmap -Pn --script=discovery,vuln,auth,smb*,nfs*,asn-query,whois,ip-geolocation-maxmind,http*,rpc* -T4 --script-args=new-targets --open --reason -p- -sU -sV $url | tee -a ~/Desktop/OffSec/Recon/$url/Recon/nmapRecon.txt

#sudo nmap -Pn --script vuln --script-args=new-targets -p- -sU -sV -T4 --open --reason $url | tee -a ~/Desktop/OffSec/Recon/$url/Recon/nmapVuln.txt
#sudo nmap -Pn --script auth --script-args=new-targets -p- -sU -sV -T4 --open --reason $url | tee -a ~/Desktop/OffSec/Recon/$url/Recon/nmapAuth.txt
#sudo nmap -Pn --script nfs* --resolve-all -T4 --open --reason $url | tee -a ~/Desktop/OffSec/Recon/$url/Recon/nmapNFS.txt
#sudo nmap -Pn --script smb* --script-args=unsafe=1 -p- -sU -sV --open --reason -T4 $url | tee -a ~/Desktop/OffSec/Recon/$url/Recon/nmapSMB.txt

echo "[+] Starting masscan [+]"
sudo masscan -p80 10.11.1.0/24 --rate=1000 -e tap0 --router-ip 10.11.0.1 | tee -a ~/Desktop/OffSec/Recon/$url/Recon/masscan.txt

echo "[+] Starting nbtscan [+]"
sudo nbtscan -r 10.11.1.0/24 | tee -a ~/Desktop/OffSec/Recon/$url/Recon/nbtscan.txt

echo "[+] Starting Enum4Linux [+]"
enum4linux 10.11.1.0/24 | tee -a ~/Desktop/OffSec/Recon/$url/Recon/E4L.txt



