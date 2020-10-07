#!/bin/bash

url=$1

if [[ ! -z /shared/OffSec/PwK/$url ]]; 
then 
	mkdir -p /shared/OffSec/PwK/$url/{recon,exploit,report}

elif [[ ! -z /shared/OffSec/PwK/$url/{recon,exploit,report} ]];
then
	mkdir -p /shared/OffSec/PwK/$url/{recon,exploit,report}
fi

echo "[+] Starting passive recon [+]"
echo "[+] Collecting WhoIs info [+]"

whois $url | grep "Name Server" | cut -d ":" -f 2 | sort -u | tee -a /shared/OffSec/PwK/$url/recon/whois.txt

echo "[+] Starting OSINT scans [+]"
python3 /usr/share/spiderfoot/sf.py -s $url -o /shared/OffSec/PwK/$url/recon/spiderfoot.csv

host www.$url | grep "has address" | cut -d " " -f 4 | sort -u | tee -a /shared/OffSec/PwK/$url/recon/ip.txt
host -t mx $url | grep "handled by" | cut -d " " -f 7 | sort -u | tee -a /shared/OffSec/PwK/$url/recon/mx.txt
for url1 in $(cat /shared/OffSec/PwK/$url/recon/mx.txt); do host $url1; done | grep "has address" | cut -d " " -f 4 | sort -u | tee -a /shared/OffSec/PwK/$url/recon/ip.txt
host -t txt $url | grep "text" | cut -d " " -f 4,5 | tee -a /shared/OffSec/PwK/$url/recon/text.txt

shodan init OT5HY0ZzH32ftaBb7UExMzoeWLfxJKI3\
shodan host $url | sort -u | tee -a /shared/OffSec/PwK/$url/recon/shodan.txt

echo "[+] Harvesting subdomains with assetfinder..."
assetfinder $url | grep '.$url' | sort -u | tee -a /shared/OffSec/PwK/$url/recon/final1.txt

echo "[+] Double checking for subdomains with amass ..."
amass intel -ip -d $url | tee -a /shared/OffSec/PwK/$url
amass enum -active -ip -d $url | tee -a /shared/OffSec/PwK/$url/recon/final1.txt

echo "[+] Compiling 3rd lvl domains..."
cat /shared/OffSec/PwK/$url/recon/final.txt | grep -Po '(\w+\.\w+\.\w+)$' | sort -u | tee -a /shared/OffSec/PwK/$url/recon/3rd-lvl-domains.txt
#write in line to recursively run thru final.txt
for line in $(cat /shared/OffSec/PwK/$url/recon/3rd-lvl-domains.txt); do echo $line | sort -u | tee -a /shared/OffSec/PwK/$url/recon/final.txt;done

echo "[+] Harvesting full 3rd lvl domains with sublist3r..."
for domain in $(cat /shared/OffSec/PwK/$url/recon/3rd-lvl-domains.txt); do sublist3r -d $domain -o /shared/OffSec/PwK/$url/recon/3rd-lvls/$domain.txt;done

dnsrecon -d $url -asgbkwz | sort -u | tee -a /shared/OffSec/PwK/$url/recon/subdomains.txt

for url1 in $(cat /shared/OffSec/PwK/$url/recon/subdomains.txt); do host $url1; done | grep "has address" | cut -d " " -f 4 | sort -u | tee -a /shared/OffSec/PwK/$url/recon/ip.txt
for ip in $(cat /shared/OffSec/PwK/$url/recon/ip.txt); do whois $ip; done | grep "NetRange" "CIDR" | cut -d ":" -f 1 | tee -a /shared/OffSec/PwK/$url/recon/ip.txt

echo "[+] Web recon complete [+]"

