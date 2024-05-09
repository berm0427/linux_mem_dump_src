#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update

# Install SELinux packages
echo "Installing SELinux packages..."
sudo apt install -y selinux-basics selinux-policy-default auditd policycoreutils

# Set SELinux to enforcing mode in the config file
echo "Configuring SELinux to enforcing mode..."
if grep -q "^SELINUX=" /etc/selinux/config; then
   sudo sed -i "s/^SELINUX=.*/SELINUX=permissive/" /etc/selinux/config
else
    echo "SELINUX=permissive" >> /etc/selinux/config
fi

# Enable SELinux to start on boot
echo "disabling SELinux..."
sudo setenforce 0

# Define the GRUB_CMDLINE_LINUX value to add/update`
GRUB_CMDLINE="iomem=relaxed"

# Check if the line exists in /etc/default/grub and update or add it
if grep -q '^GRUB_CMDLINE_LINUX' /etc/default/grub; then
    # Update the existing GRUB_CMDLINE_LINUX
    sudo sed -i "s|^GRUB_CMDLINE_LINUX=\".*\"|GRUB_CMDLINE_LINUX=\"$GRUB_CMDLINE\"|" /etc/default/grub
else
    # Add the GRUB_CMDLINE_LINUX line if it doesn't exist
    echo "GRUB_CMDLINE_LINUX=\"$GRUB_CMDLINE\"" | sudo tee -a /etc/default/grub
fi

# Update the GRUB configuration to apply changes
sudo update-grub

if systemctl list-units --type=service | grep -q 'apparmor.service'; then
    echo "apparmor service found."

    # Check if apparmor is active
    if systemctl is-active --quiet apparmor; then
        echo "apparmor service is active. Stopping service..."
        sudo systemctl stop apparmor
        echo "apparmor service stopped."
    else
        echo "apparmor service is already inactive."
    fi
else
    echo "apparmor service not found on this system."
fi
