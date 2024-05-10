#!/bin/bash

# Remove Volatility 3, dwarf2json, UAC directories if they exist
USER_HOME=$(eval echo ~${SUDO_USER})
rm -rf $USER_HOME/volatility3 $USER_HOME/dwarf2json $USER_HOME/LiME

# Remove any unneeded packages installed during the script execution
sudo apt autoremove -y

# 아래는 예시이며 상황에 맞게 변경하여 사용바람
# SELinux를 enforcing 모드로 설정
echo "Configuring SELinux to enforcing mode..."

# if grep -q "^SELINUX=" /etc/selinux/config; then
#     # 기존 SELINUX 설정을 enforcing 모드로 변경
#     sudo sed -i "s/^SELINUX=.*/SELINUX=enforcing/" /etc/selinux/config
# else
#     # SELINUX 설정이 없는 경우 새로 추가
#     echo "SELINUX=enforcing" | sudo tee -a /etc/selinux/config
# fi

# # 즉시 enforcing 모드로 변경
# echo "Enabling SELinux enforcing mode..."
# sudo setenforce 1

# GRUB_CMDLINE_LINUX에서 iomem=relaxed 제거
GRUB_CONFIG_FILE="/etc/default/grub"
GRUB_CMDLINE="iomem=relaxed"

echo "Removing '$GRUB_CMDLINE' from GRUB_CMDLINE_LINUX..."

# GRUB_CMDLINE_LINUX에서 해당 옵션을 제거
if grep -q "^GRUB_CMDLINE_LINUX=.*$GRUB_CMDLINE" "$GRUB_CONFIG_FILE"; then
    sudo sed -i "s/\(GRUB_CMDLINE_LINUX=.*\)$GRUB_CMDLINE\(.*\)/\1\2/" "$GRUB_CONFIG_FILE"
else
    echo "The specified GRUB_CMDLINE_LINUX value is not present."
fi

# if systemctl list-units --type=service | grep -q 'apparmor.service'; then
#     echo "apparmor service found."

#     # Check if apparmor is active
#     if ! systemctl is-active --quiet apparmor; then
#         echo "apparmor service is unactive. Starting service..."
#         sudo systemctl start apparmor
#         echo "apparmor service started."
#     else
#         echo "apparmor service is already started."
#     fi
# else
#     echo "apparmor service not found on this system."
# fi
# GRUB 구성을 업데이트하여 변경사항 적용
echo "Updating GRUB configuration..."
sudo update-grub

echo "Configuration completed."

# Notify that cleanup is complete
echo "Cleanup complete!"

