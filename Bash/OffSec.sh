#!/bin/bash

read -p 'URL: ' url


if [[ ! -z /shared/OffSec/PwK/$url/{Recon,Exploit,Report} ]]; 
then 
	mkdir -p /shared/OffSec/PwK/$url/{Recon,Exploit,Report}

fi

#sudo apt update && sudo apt install -y masscan amass 

echo "[+] Starting OSINT scans [+]"
echo "[+] Starting Spiderfoot in background [+]"
python /usr/share/spiderfoot/sf.py -s $url -o /shared/OffSec/PwK/$url/recon/spiderfoot.csv &

echo "[+] Hitting that HOST data homie [+]"
host www.$url | grep "has address" | cut -d " " -f 4 | sort -u | tee /shared/OffSec/PwK/$url/recon/ips.txt

echo -e "www\nftp\nmail\nowa\nproxy\nrouter" > /shared/OffSec/PwK/$url/recon/list.txt
for ip in $(cat /shared/OffSec/PwK/$url/recon/list.txt); do host $ip.$url | tee /shared/OffSec/PwK/$url/recon/host_subs.txt; done 

echo "[+] Finding MX data [+]"
host -t mx $url | grep "handled by" | cut -d " " -f 7 | sort -u | tee /shared/OffSec/PwK/$url/recon/mx.txt

echo "[+] Finding IPs [+]"
for url1 in $(cat /shared/OffSec/PwK/$url/recon/mx.txt); do host $url1; done | grep "has address" | cut -d " " -f 4 | sort -u | tee -a /shared/OffSec/PwK/$url/recon/ips.txt

echo "[+] Grabbing available text [+]"
host -t txt $url | grep "text" | cut -d " " -f 4,5 | tee /shared/OffSec/PwK/$url/recon/text.txt

echo "[+] HERE COMES SHOOOOOOOOOOODAAAAAAAAAAAAN!!!!! [+]"
shodan init OT5HY0ZzH32ftaBb7UExMzoeWLfxJKI3
shodan domain $url | tee /shared/OffSec/PwK/$url/recon/shodan.txt

echo "[+] Gathering WhoIs data [+]"
whois $url | grep 'Name Server' | cut -d ":" -f 2 | sort -u | tee /shared/OffSec/PwK/$url/Recon/whois.txt

echo "[+] Gathering Harvester Data [+]"
theHarvester -d $url -b all -nct | tee /shared/OffSec/PwK/$url/Recon/theHarvester.txt

echo " [+] Conjuring Deep Magik [+]"
dmitry -winseo /shared/OffSec/PwK/$url/Recon/DMITRY $url

echo "[+] Starting DNSrecon [+]"
dnsrecon -d $url -t axfr -asgbkwz -v | tee /shared/OffSec/PwK/$url/Recon/DNSrecon.txt

echo "[+] Digging deep [+]"
dig -t ANY $url | tee /shared/OffSec/PwK/$url/Recon/Dig

echo "[+] Starting dnsenum [+]"
dnsenum $url --private | tee /shared/OffSec/PwK/$url/Recon/dnsenum.txt

echo "[+] Starting DirBuster [+]"
dirb http://www.$url -r -z 10 | tee /shared/OffSec/PwK/$url/Recon/DirB

echo "[+] Starting Amass [+]"
amass intel -ip -d http://$url | sort -u | tee /shared/OffSec/PwK/$url/Recon/amass_intel.txt
amass enum -active -ip -d $url | sort -u | tee /shared/OffSec/PwK/$url/Recon/amass_enum.txt

echo "[+] Starting Active Recon [+]"

read -p 'IP range: ' ip

echo "[+] Starting Ping Sweep [+]"
sudo nmap -n -v -sn $ip -oG - | grep -i 'up' | cut -d " " -f 2 | sort -nzf | tee /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt

if [[ ! -z /shared/OffSec/PwK/$url/{Recon,Exploit,Report} ]]; 
then 
	for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo mkdir -p /shared/OffSec/PwK/$url/Recon/$ip; done
fi

echo "[+] Starting Discovery scan [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo nmap -Pn -v --script discovery -e tun0 --script-args=dns-brute.domain,shodan-api.apikey=OT5HY0ZzH32ftaBb7UExMzoeWLfxJKI3 --open --reason -p- -sV -T4 $ip -oA /shared/OffSec/PwK/$url/Recon/$ip/nmapDiscovery; done

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
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo enum4linux -MavdlK $ip | tee /shared/OffSec/PwK/$url/Recon/$ip/E4L.txt; done  

echo "[+] Starting nbtscan [+]"
for ip in $(cat /shared/OffSec/PwK/$url/Recon/ActiveHosts.txt); do sudo nbtscan -r $ip | tee /shared/OffSec/PwK/$url/Recon/$ip/nbtscan.txt; done
done

echo "[+] Starting OneSixtyOne [+]"
for ip in $(cat /shared/OffSec/PwK/megacorpone.com/Recon/ActiveHosts.txt); do sudo onesixtyone -c /shared/OffSec/PwK/megacorpone.com/Recon/community -i /shared/OffSec/PwK/megacorpone.com/Recon/ActiveHosts.txt | tee /shared/OffSec/PwK/$url/Recon/$ip/onesixtyone.txt; done

echo "[+] Starting SNMPWalk [+]"
for ip in $(cat /shared/OffSec/PwK/megacorpone.com/Recon/ActiveHosts.txt); do sudo snmpwalk -c public -t 10 -v1 $ip | tee /shared/OffSec/PwK/$url/Recon/$ip/SNMP.txt; done
