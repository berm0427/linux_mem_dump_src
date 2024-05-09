#!/bin/bash

# you should run it if occur unknown error
 
# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Get the original user's home directory
USER_HOME=$(eval echo ~${SUDO_USER})

kernel_version=$(uname -r)
lsb_v=$(lsb_release -r | awk '{print $2}')

echo $USER_HOME
echo $kernel_version
echo $lsb_v
