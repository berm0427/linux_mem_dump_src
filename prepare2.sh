#!/bin/bash

# Step 22: Generate JSON symbol file
cd ~/dwarf2json
sudo ./dwarf2json linux --elf /usr/lib/debug/boot/vmlinux-$kernel_version --system-map /boot/System.map-$kernel_version > Ubuntu22.04-$kernel_version.json

# Step 23-24: Move the JSON file to the appropriate directory for Volatility 3
mkdir -p ~/volatility3/volatility3/symbols/linux
mv ./Ubuntu22.04-$kernel_version.json ~/volatility3/volatility3/symbols/linux

# Step 25: Clone LiME tool if it doesn't exist
if [ ! -d "~/LiME" ]; then
    cd ~
    git clone --recursive https://github.com/504ensicsLabs/LiME.git
fi

# Step 26-27: Run LiME to collect artifacts and take a memory snapshot
cd ~/LiME
cd src

# 현재 디렉토리의 절대 경로를 저장
CURRENT_DIR=$(pwd)

cd ..
CURRENT_DIR2=$(pwd)

# 루트 사용자로 전환하여 경로 이동
echo "Switching to root and changing directory to: $CURRENT_DIR"

# su -로 루트 전환 후 해당 경로로 이동
su -c "bash -c 'cd \"$CURRENT_DIR\" && make && \"$CURRENT_DIR\"insmod ./lime-${kernel_version}-generic.ko "path=./Ubuntu.lime format=lime"'"


# Step 28: Notify completion
exit
echo "Complete now you can use vol3! with lime file!"
