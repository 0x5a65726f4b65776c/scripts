#!/bin/bash

url=$1

if [[ ! -z ~/PwK/$url/{recon,exploit,report} ]]; 
then 
	mkdir -p ~/PwK/$url/{recon,exploit,report}
fi

host www.$url | grep "has address" | cut -d " " -f 4 | sort -u | tee -a ~/PwK/$url/recon/ip.txt
host -t mx $url | grep "handled by" | cut -d " " -f 7 | sort -u | tee -a ~/PwK/$url/recon/mx.txt
for url1 in $(cat ~/PwK/$url/recon/mx.txt); do host $url1; done | grep "has address" | cut -d " " -f 4 | sort -u | tee -a ~/PwK/$url/recon/ip.txt

host -t txt $url | grep "text" | cut -d " " -f 4,5 | tee -a ~/PwK/$url/recon/text.txt


