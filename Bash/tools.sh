#!/bin/bash

git clone https://github.com/mzet-/linux-exploit-suggester.git
git clone https://github.com/rebootuser/LinEnum.git
git clone https://github.com/pentestmonkey/unix-privesc-check.git
mkdir -v linux-pe-scripts
cp linux-exploit-suggester/linux-exploit-suggester.sh linux-pe-scripts/
cp LinEnum/LinEnum.sh linux-pe-scripts/
cp unix-privesc-check/upc.sh linux-pe-scripts/
echo "Done"
echo "Downloading MS17-010 tools..."
git clone https://github.com/worawit/MS17-010.git
git clone https://github.com/3ndG4me/AutoBlue-MS17-010.git
echo "Downloading JAWS..."
git clone https://github.com/411Hall/JAWS.git
echo "Done."
