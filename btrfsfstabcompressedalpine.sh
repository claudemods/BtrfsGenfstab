#!/bin/bash

# Colors
red_color="\033[38;2;255;0;0m"
cyan_color="\033[38;2;0;255;255m"
reset_color="\033[0m"

# Display header
echo -e "${red_color}"
cat << 'EOF'
░█████╗░██╗░░░░░░█████╗░██║░░░██╗██████╗░███████╗███╗░░░███╗░█████╗░██████╗░░██████╗
██╔══██╗██║░░░░░██╔══██╗██║░░░██║██╔══██╗██╔════╝████╗░████║██╔══██╗██╔══██╗██╔════╝
██║░░╚═╝██║░░░░░███████║██║░░░██║██║░░██║█████╗░░██╔████╔██║██║░░██║██║░░██║╚█████╗░
██║░░██╗██║░░░░░██╔══██║██║░░░██║██║░░██║██╔══╝░░██║╚██╔╝██║██║░░██║██║░░██║░╚═══██╗
╚█████╔╝███████╗██║░░██║╚██████╔╝██████╔╝███████╗██║░╚═╝░██║╚█████╔╝██████╔╝██████╔╝
░╚════╝░╚══════╝╚═╝░░╚═╝░╚═════╝░╚═════╝░╚══════╝╚═╝░░░░░╚═╝░╚════╝░╚═════╝░╚═════╝░
EOF
echo -e "${cyan_color}claudemods BtrfsGenFstab v1.01 Zstd Level 22 Compression${reset_color}"
echo -e "${cyan_color}"

# Now run ALL privileged commands in ONE SESSION
doas sh -c '
    # Backup fstab
    echo "Backing up fstab..."
    cp /etc/fstab /etc/fstab.bak || { echo "Backup failed"; exit 1; }

    # Get root UUID
    ROOT_UUID=$(findmnt -no UUID /) || { echo "Failed getting UUID"; exit 1; }

    # Generate new fstab entries
    {
        echo ""
        echo "# Btrfs subvolumes (auto-added)"
        grep -q "UUID=$ROOT_UUID.*/ .*subvol=/@" /etc/fstab || echo "UUID=$ROOT_UUID /              btrfs   rw,noatime,compress=zstd:22,discard=async,space_cache=v2,subvol=/@ 0 0"
        grep -q "UUID=$ROOT_UUID.*/root" /etc/fstab       || echo "UUID=$ROOT_UUID /root          btrfs   rw,noatime,compress=zstd:22,discard=async,space_cache=v2,subvol=/@root 0 0"
        grep -q "UUID=$ROOT_UUID.*/home" /etc/fstab       || echo "UUID=$ROOT_UUID /home          btrfs   rw,noatime,compress=zstd:22,discard=async,space_cache=v2,subvol=/@home 0 0"
        grep -q "UUID=$ROOT_UUID.*/srv" /etc/fstab        || echo "UUID=$ROOT_UUID /srv           btrfs   rw,noatime,compress=zstd:22,discard=async,space_cache=v2,subvol=/@srv 0 0"
        grep -q "UUID=$ROOT_UUID.*/var/cache" /etc/fstab || echo "UUID=$ROOT_UUID /var/cache     btrfs   rw,noatime,compress=zstd:22,discard=async,space_cache=v2,subvol=/@cache 0 0"
        grep -q "UUID=$ROOT_UUID.*/var/tmp" /etc/fstab   || echo "UUID=$ROOT_UUID /var/tmp       btrfs   rw,noatime,compress=zstd:22,discard=async,space_cache=v2,subvol=/@tmp 0 0"
        grep -q "UUID=$ROOT_UUID.*/var/log" /etc/fstab   || echo "UUID=$ROOT_UUID /var/log       btrfs   rw,noatime,compress=zstd:22,discard=async,space_cache=v2,subvol=/@log 0 0"
    } >> /etc/fstab
'

# Completion message
echo -e "\nInstallation Complete"

# Reboot prompt
read -p "Do you want to reboot now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${cyan_color}Rebooting system...${reset_color}"
    doas reboot
else
    echo -e "${cyan_color}Changes will take effect after reboot${reset_color}"
fi

echo -ne "${reset_color}"
