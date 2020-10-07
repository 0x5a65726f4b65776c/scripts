#!/bin/bash


echo "*** UPDATING NOW ***"

sudo apt-get update &&
sudo apt-get full-upgrade -y &&
sudo apt-get dist-upgrade -y &&
sudo apt-get autoclean &&
sudo apt-get autoremove -y && 

echo "*** UPDATE COMPLETE ***"

#read -p "Press [Enter] to continue"

echo "*** INSTALLING OSINT TOOLS ***"

sudo apt-get install -y python3

sudo apt-get install -y tor privoxy openvpn flameshot shotwell audacity soundconverter darktable photoflare simplescreenrecorder chromium amass pdfsam bleachbit kate youtube-dl tinfoleak snort sublist3r openvas datasploit 

cd /usr/share/ &&

# the harvester
sudo git clone https://github.com/laramies/theHarvester
cd theHarvester
sudo pip3 install -r requirements.txt
cd ..

# photon
sudo git clone https://github.com/s0md3v/Photon
cd Photon
sudo pip install -r requirements.txt
cd ..

#Sherlock
sudo git clone https://github.com/sherlock-project/sherlock
cd sherlock 
sudo pip install -r requirements.txt
cd ..

#gasmask
sudo git clone https://github.com/twelvesec/gasmask
cd gasmask
sudo pip install -r requirement.txt
cd ..

#Phoneinfoga
sudo git clone https://github.com/sundowndev/PhoneInfoga
cd PhoneInfoga
sudo pip install -r requirements.txt
cd ..

#spiderfoot
sudo git clone https://github.com/smicallef/spiderfoot
cd spiderfoot
sudo pip install -r requirements.txt
cd ..

#SANS SIFT
#read -p "*** INSTALLING SIFT *** Press [Enter] to continue"
#!/usr/bin/env bash
# Install SIFT Workstation Tools - tested to work on Ubuntu 16.04
# j3rmbadger

# Snag the binaries - https://github.com/sans-dfir/sift-cli
#wget https://github.com/sans-dfir/sift-cli/releases/download/v1.5.1/sift-cli-linux
#wget https://github.com/sans-dfir/sift-cli/releases/download/v1.5.1/sift-cli-linux.sha256.asc1

# Validate signature file
#gpg --keyserver pgp.mit.edu --recv-keys 22598A94
#gpg --verify sift-cli-linux.sha256.asc

#sudo mv sift-cli-linux /usr/local/bin/sift
#sudo chmod 755 /usr/local/bin/sift

# Install SIFT
#sift install

#echo "*** SIFT INSTALLED ***"

read -p "*** OSINT INSTALLATION COMPLETE *** Press [Enter] to continue ***"

#echo "*** INSTALLING NETFLOW TOOLS ***"
#zeek - net flow analyzer
#sudo git clone --recursive https://github.com/zeek/zeek.git
#cd zeek
#sudo pip install -r requirements.txt
#cd ..


#echo "*** NETFLOW TOOLS INSTALLED ***"

echo "INSTALL COMPLETE"
