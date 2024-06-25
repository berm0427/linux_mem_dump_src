#!/bin/bash

# Set the original user's home directory before switching to root
USER_HOME=$(eval echo ~${SUDO_USER})

# Switch to root account
if [[ $EUID -ne 0 ]]; then
    echo "Switching to root account"
    exec su -c "USER_HOME=${USER_HOME} bash $0"
fi

# Verify that the script is now running as root
if [[ $EUID -ne 0 ]]; then
   echo "Failed to switch to root account" 
   exit 1
fi

# Retrieve system info variables
kernel_version=$(uname -r)
lsb_v=$(lsb_release -r | awk '{print $2}')

# Step 22: Generate JSON symbol file
cd "$USER_HOME/dwarf2json"
mkdir -p "$USER_HOME/volatility3/volatility3/symbols/linux"

if ./dwarf2json linux --elf /usr/lib/debug/boot/vmlinux-$kernel_version --system-map /boot/System.map-$kernel_version > Ubuntu$lsb_v-$kernel_version.json; then
    echo "JSON symbol file generated successfully."
else
    echo "Error: Failed to generate JSON symbol file. Please ensure vmlinux file exists."
    exit 1
fi

# Step 23-24: Move the JSON file to the appropriate directory for Volatility 3
mkdir -p "$USER_HOME/volatility3/volatility3/symbols/linux"
mv "./Ubuntu$lsb_v-$kernel_version.json" "$USER_HOME/volatility3/volatility3/symbols/linux"

# Step 25: Clone LiME tool if it doesn't exist
if [ ! -d "$USER_HOME/LiME" ]; then
    cd "$USER_HOME"
    git clone --recursive https://github.com/504ensicsLabs/LiME.git
else
    echo "LiME directory already exists."
fi

# Step 26-27: Run LiME to collect artifacts and take a memory snapshot
cd "$USER_HOME/LiME/src"
apt install -y gcc-12
apt install -y gcc
make

# LiME 모듈을 루트 권한으로 로드
sudo insmod ./lime-$kernel_version.ko "path=$USER_HOME/volatility3/Ubuntu.lime format=lime"

# if ocuur skip BTf ~ 
# https://askubuntu.com/questions/1348250/skipping-btf-generation-xxx-due-to-unavailability-of-vmlinux-on-ubuntu-21-04

# Step 28: Notify completion
echo "The GRUB configuration has been updated and now you can use vol3 with the lime file!"
