#!/bin/bash

echo "[+] Starting Active Recon [+]"
read -p 'URL: ' url
read -p 'IP range: ' ip
    
#echo "[+] Starting Ping Sweep [+]"
#sudo nmap -n -v -sn $ip -oG - | grep -i 'up' | cut -d " " -f 2 | sort -nzf | #tee /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt

if [[ ! -z /shared/OffSec/PwK/$url/{Recon,Exploit,Report} ]]; 
then 
	for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo mkdir -p /shared/OffSec/PwK/$url/Recon/$ip; done
fi

echo "[+] Starting Discovery scan [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo nmap -Pn -v --script discovery -e tun0 --script-args=dns-brute.domain,shodan-api.apikey=OT5HY0ZzH32ftaBb7UExMzoeWLfxJKI3 --open --reason -p- -sV -T4 $ip -oA /shared/OffSec/PwK/$url/Recon/$ip/nmapDiscovery.txt; done

echo "[+] Starting Vuln scan [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo nmap -Pn -v --script vuln -e tun0 --script-args=dns-brute.domain,shodan-api.apikey=OT5HY0ZzH32ftaBb7UExMzoeWLfxJKI3 --open --reason -p- -T4 $ip -oA /shared/OffSec/PwK/$url/Recon/$ip/nmapVuln; done

echo "[+] Starting Auth scan [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo nmap -Pn -v --script auth -e tun0  --script-args=dns-brute.domain,shodan-api.apikey=OT5HY0ZzH32ftaBb7UExMzoeWLfxJKI3 --open --reason -p- -T4 $ip -oA /shared/OffSec/PwK/$url/Recon/$ip/nmapAuth; done

echo "[+] Starting NFS scan [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo nmap -Pn -v --script nfs* -e tun0  --script-args=dns-brute.domain,shodan-api.apikey=OT5HY0ZzH32ftaBb7UExMzoeWLfxJKI3 --open --reason -p 111,635,2049,4045,4046 -sV -T4 $ip -oA /shared/OffSec/PwK/$url/Recon/$ip/nmapNFS; done

echo "[+] Starting HTTP scan [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo nmap -Pn -v --script http* -e tun0  --script-args=dns-brute.domain,shodan-api.apikey=OT5HY0ZzH32ftaBb7UExMzoeWLfxJKI3 --open --reason -p 80,443,8000,8080,8443,8880 -T4 $ip -oA /shared/OffSec/PwK/$url/Recon/$ip/nmapWeb; done

echo "[+] Starting SMB scan [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo nmap -Pn -v --script smb* -e tun0 --open --reason -p 137,138,139,445 -T4 $ip -oA /shared/OffSec/PwK/$url/Recon/$ip/nmapSMB; done

echo "[+] Starting LDAP scan [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/DCIPs.txt); do sudo nmap -Pn -v --script ldap* -e tun0 --open --reason -p 389,636,3268,3269 -T4 $ip -oA /shared/OffSec/PwK/$url/Recon/$ip/nmapLDAP; done

echo "[+] Starting Masscan UDP scan [+]"
for ip in $(cat ActiveHosts.txt); do sudo masscan -pU:1-65535 $ip --rate=1000 -e tun0 --router-ip 10.11.1.1 -oA /shared/OffSec/PwK/$url/Recon/$ip/masscan.txt; done

echo "[+] Starting Enum4Linux [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo enum4linux -MavdlK $ip | tee /shared/OffSec/PwK/$url/Recon/$ip/E4L; done  

echo "[+] Starting nbtscan [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo nbtscan -r $ip | tee /shared/OffSec/PwK/$url/Recon/$ip/nbtscan.txt; done
done

echo "[+] Starting OneSixtyOne [+]"
for ip in $(cat /shared/OffSec/PwK/megacorpone.com/Recon/ActiveHosts.txt); do sudo onesixtyone -c /shared/OffSec/PwK/megacorpone.com/Recon/community -i /shared/OffSec/PwK/megacorpone.com/Recon/ActiveHosts.txt | tee /shared/OffSec/PwK/$url/Recon/$ip/onesixtyone.txt; done

echo "[+] Starting SNMPWalk [+]"
for ip in $(cat /shared/OffSec/PwK/megacorpone.com/Recon/ActiveHosts.txt); do sudo snmpwalk -c public -t 10 -v1 $ip | tee /shared/OffSec/PwK/$url/Recon/$ip/SNMP.txt; done 
