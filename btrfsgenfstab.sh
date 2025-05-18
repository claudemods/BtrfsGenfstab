#!/bin/bash

# Colors
red_color="\033[38;2;255;0;0m"
cyan_color="\033[38;2;0;255;255m"
reset_color="\033[0m"

# Display header in red
echo -e "${red_color}"
cat << 'EOF'
░█████╗░██╗░░░░░░█████╗░██║░░░██╗██████╗░███████╗███╗░░░███╗░█████╗░██████╗░░██████╗
██╔══██╗██║░░░░░██╔══██╗██║░░░██║██╔══██╗██╔════╝████╗░████║██╔══██╗██╔══██╗██╔════╝
██║░░╚═╝██║░░░░░███████║██║░░░██║██║░░██║█████╗░░██╔████╔██║██║░░██║██║░░██║╚█████╗░
██║░░██╗██║░░░░░██╔══██║██║░░░██║██║░░██║██╔══╝░░██║╚██╔╝██║██║░░██║██║░░██║░╚═══██╗
╚█████╔╝███████╗██║░░██║╚██████╔╝██████╔╝███████╗██║░╚═╝░██║╚█████╔╝██████╔╝██████╔╝
░╚════╝░╚══════╝╚═╝░░╚═╝░╚═════╝░╚═════╝░╚══════╝╚═╝░░░░░╚═╝░╚════╝░╚═════╝░╚═════╝░
EOF
echo -e "${cyan_color}claudemods btrfs system fstab generator v1.0${reset_color}"

# Set ALL remaining text to cyan
echo -e "${cyan_color}"

# Backup existing fstab
echo "Backing up fstab..."
cp /etc/fstab /etc/fstab.bak || { echo -e "${red_color}Error: Could not backup fstab${reset_color}"; exit 1; }

# Get root UUID from current / mount
echo "Getting root UUID..."
ROOT_UUID=$(findmnt -no UUID /) || { echo -e "${red_color}Error: Could not get root UUID${reset_color}"; exit 1; }

# Check and add ONLY the mounts you specified
echo "Checking and adding subvolume entries..."
{
    echo ""
    echo "# Btrfs subvolumes (auto-added)"
    grep -q "UUID=$ROOT_UUID.*/root" /etc/fstab       || echo "UUID=$ROOT_UUID /root          btrfs   subvol=/@root,defaults,noatime,compress=zstd,commit=120 0 0"
    grep -q "UUID=$ROOT_UUID.*/home" /etc/fstab       || echo "UUID=$ROOT_UUID /home          btrfs   subvol=/@home,defaults,noatime,compress=zstd,commit=120 0 0"
    grep -q "UUID=$ROOT_UUID.*/srv" /etc/fstab        || echo "UUID=$ROOT_UUID /srv           btrfs   subvol=/@srv,defaults,noatime,compress=zstd,commit=120 0 0"
    grep -q "UUID=$ROOT_UUID.*/var/cache" /etc/fstab || echo "UUID=$ROOT_UUID /var/cache     btrfs   subvol=/@cache,defaults,noatime,compress=zstd,commit=120 0 0"
    grep -q "UUID=$ROOT_UUID.*/var/tmp" /etc/fstab   || echo "UUID=$ROOT_UUID /var/tmp       btrfs   subvol=/@tmp,defaults,noatime,compress=zstd,commit=120 0 0"
    grep -q "UUID=$ROOT_UUID.*/var/log" /etc/fstab   || echo "UUID=$ROOT_UUID /var/log       btrfs   subvol=/@log,defaults,noatime,compress=zstd,commit=120 0 0"
} >> /etc/fstab

echo -e "Installation Complete You Can Now Reboot"

# Reset terminal color before exiting
echo -ne "${reset_color}"
