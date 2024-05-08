#!/bin/bash

cd ~

# Step 0: Update apt packages
sudo apt update

# Step 1: Check for git and install if not present
if ! command -v git &> /dev/null
then
    sudo apt install -y git
fi

# Clone Volatility 3 if it doesn't exist
if [ ! -d "volatility3" ]; then
    git clone https://github.com/volatilityfoundation/volatility3.git
fi

# Step 2: Navigate to the Volatility 3 directory
cd volatility3

# Step 3: Install python3-pip if not present
if ! dpkg -s python3-pip &> /dev/null; then
    sudo apt install -y python3-pip
fi

# Step 4: Install libsnappy-dev if not present
if ! dpkg -s libsnappy-dev &> /dev/null; then
    sudo apt install -y libsnappy-dev
fi

# Step 5: Install Python dependencies
pip3 install -r requirements.txt

# Step 6-7: Build and install Volatility
python3 setup.py build
python3 setup.py install

# Step 8: Check if Volatility is installed correctly
python3 vol.py -h

# Step 9: Clone dwarf2json if it doesn't exist
if [ ! -d "~/dwarf2json" ]; then
    cd ~
    git clone https://github.com/volatilityfoundation/dwarf2json.git
    cd dwarf2json
else
    cd dwarf2json
fi

# Step 10: Install golang-go if not present
if ! dpkg -s golang-go &> /dev/null; then
    sudo apt install -y golang-go
fi

# Step 12-13: Download go dependencies and build dwarf2json
go mod download github.com/spf13/pflag
go build

# Step 14: Check if dwarf2json is installed correctly
./dwarf2json --help

# Step 15: Store the kernel version
kernel_version=$(uname -r)

# Step 16: Setup debugging symbols
echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/ddebs.list

# Step 17: Install ubuntu-dbgsym-keyring if not present
if ! dpkg -s ubuntu-dbgsym-keyring &> /dev/null; then
    sudo apt install -y ubuntu-dbgsym-keyring
fi

# Step 18-19: Update apt and import debug symbol key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F2EDC64DC5AEE1F6B9C621F0C8CAB6595FDFF622
sudo apt update

# Step 20: Install debugging symbols for the kernel
sudo apt install -y linux-image-${kernel_version}-dbgsym

# Step 22: Generate JSON symbol file
sudo ./dwarf2json linux --elf /usr/lib/debug/boot/vmlinux-$kernel_version --system-map /boot/System.map-$kernel_version > Ubuntu22.04-$kernel_version.json

# Step 23-24: Move the JSON file to the appropriate directory for Volatility 3
mkdir -p ~/volatility3/volatility3/symbols/linux
mv ./Ubuntu22.04-$kernel_version.json ~/volatility3/volatility3/symbols/linux

# Step 25: Clone UAC tool if it doesn't exist
if [ ! -d "~/LiME" ]; then
    git clone --recursive https://github.com/504ensicsLabs/LiME.git
fi

# Step 26-27: Run LiME to collect artifacts and take a memory snapshot
cd LiME
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
