################################################################################
# To get details about variables visit https://github.com/lukashonak/arch-linux#
################################################################################
#Variables area
continent_city="Europe/Minsk"
country_for_mirror="BY"

#Passwords set for the partition encryption. By default the same for all partitions.
encryption_passphrase_root=""
encryption_passphrase_boot=$encryption_passphrase_root
encryption_passphrase_home=$encryption_passphrase_root
root_password=$encryption_passphrase_root

#User setting block
user_name=""
user_password=$encryption_passphrase_root

#Name of the LVM group
volume_group=""
#Size for root partition.
part_root_size="32"
part_swap_size="2"
host_name=""
#See General info on top
with_hibernation="1"
with_firewall="1"
#Disk type
disk_type="sda"
###############################################
#Tech variables. Don't touch
repo_git_path='https://raw.githubusercontent.com/lukashonak/arch-linux/master/Install'
addition_packages='yes | pacstrap /mnt pacman-contrib lvm2 device-mapper cryptsetup networkmanager wget man vim sudo git grub'
if [[ disk_type -eq "sda" ]]
then
  discard_HOOK=" rd.luks.options=discard"
  discard_FSTAB="discard,"
fi
###############################################
echo "Updating system clock"
timedatectl set-ntp true
timedatectl set-timezone $continent_city

echo "Creating partition tables"
printf "n\n1\n2048\n+1M\nef02\nw\ny\n" | gdisk /dev/"$disk_type"
printf "n\n2\n\n+500M\n8309\nw\ny\n" | gdisk /dev/"$disk_type"
printf "n\n3\n\n\n8e00\nw\ny\n" | gdisk /dev/"$disk_type"

echo "Crypting boot partition with luks1"
printf "%s" "$encryption_passphrase_boot" | cryptsetup luksFormat --type luks1 /dev/"$disk_type"2
printf "%s" "$encryption_passphrase_boot" | cryptsetup luksOpen /dev/"$disk_type"2 cryptlvm

echo "Creating and crypting LVM with luks2. LUKS on LVM"
pvcreate /dev/"$disk_type"3
vgcreate $volume_group /dev/"$disk_type"3
lvcreate -L "$part_root_size"GB -n cryptroot $volume_group
lvcreate -C y -L "$part_swap_size"GB -n cryptswap $volume_group
lvcreate -l 100%FREE -n crypthome $volume_group
printf "%s" "$encryption_passphrase_root" | cryptsetup luksFormat /dev/$volume_group/cryptroot
printf "%s" "$encryption_passphrase_root" | cryptsetup luksOpen /dev/$volume_group/cryptroot root
mkfs.ext4 /dev/mapper/root
mount /dev/mapper/root /mnt

echo "Preparing the boot partition"
mkfs.ext4 /dev/mapper/cryptlvm
mkdir /mnt/boot
mount /dev/mapper/cryptlvm /mnt/boot

echo "Installing base packages"
yes | pacstrap /mnt base linux linux-firmware intel-ucode

if [[ with_firewall -eq 1 ]]
then
  addition_packages="$addition_packages nftables"
fi

echo "Installing additional packages"
eval $addition_packages

echo "Installing fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "Installing home partition"
mkdir -m 700 /mnt/etc/luks-keys
dd if=/dev/random of=/mnt/etc/luks-keys/home bs=1 count=256 status=progress
printf "%s" "$encryption_passphrase_home" | cryptsetup luksFormat /dev/$volume_group/crypthome
printf "%s" "$encryption_passphrase_home" | cryptsetup luksAddKey /dev/$volume_group/crypthome /mnt/etc/luks-keys/home
cryptsetup -d /mnt/etc/luks-keys/home open /dev/$volume_group/crypthome home
mkfs.ext4 /dev/mapper/home
mount /dev/mapper/home /mnt/home

if [[ with_hibernation -eq 1 ]]
then
  echo "Installing swap for hibernation"
  dd if=/dev/random of=/mnt/etc/luks-keys/swap bs=1 count=256 status=progress
  printf "YES" | cryptsetup luksFormat -v /dev/$volume_group/cryptswap /mnt/etc/luks-keys/swap
  cryptsetup -d /mnt/etc/luks-keys/swap open /dev/$volume_group/cryptswap swap
fi

UUID_root=`blkid -s UUID -o value /dev/$volume_group/cryptroot`
UUID_boot=`blkid -s UUID -o value /dev/sda2`
UUID_swap=`blkid -s UUID -o value /dev/$volume_group/cryptswap`

if [[ with_hibernation -eq 1 ]]
then
  hibernation_HOOK=" rd.luks.name=$UUID_swap=swap rd.luks.key=$UUID_swap=\/etc\/luks-keys\/swap rd.luks.options=$UUID_swap=keyfile-timeout=10s,swap resume=\/dev\/mapper\/swap"
fi

echo "Creating Install directory"
mkdir /mnt/Install

if [[ with_firewall -eq 1 ]]
then
  echo "Getting FireWall setup script"
  eval "wget $repo_git_path\/1_2_firewallSetup.sh"
  cp 1_2_firewallSetup.sh /mnt/Install
  chmod +x /mnt/Install/1_2_firewallSetup.sh
fi

echo "Configuring new system"
arch-chroot /mnt /bin/bash <<EOF
echo "Setup MirrorList"
curl -s "https://www.archlinux.org/mirrorlist/?country=$country_for_mirror&country=all&protocol=https&protocol=http&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors - > /etc/pacman.d/mirrorlist

echo "Setup Timezone"
ln -sf /usr/share/zoneinfo/$continent_city /etc/localtime
hwclock --systohc

echo "Setup Localization"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

echo "Setup Network"
echo $host_name > /etc/hostname
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.0.1		$host_name.localdomain		$host_name" >> /etc/hosts

echo "Setup root password"
echo -en "$root_password\n$root_password" | passwd

echo "Setup new user"
useradd -m -G wheel -s /bin/bash $user_name
usermod -a -G video $user_name
echo -en "$user_password\n$user_password" | passwd $user_name
echo "$user_name ALL=(ALL) ALL" | EDITOR='tee -a' visudo

if (( $disk_type == "sda" ))
then
  echo "Setup TRIM for LVM"
  sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf
fi

echo "Setup Initframs"
sed -i 's/^HOOKS.*/HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)/' /etc/mkinitcpio.conf
sed -i 's/^MODULES.*/MODULES=(ext4)/' /etc/mkinitcpio.conf
if (( $with_hibernation == 1 ))
then
  sed -i 's/^FILES.*/FILES=(\/etc\/luks-keys\/swap)/' /etc/mkinitcpio.conf
fi

mkinitcpio -p linux

echo "Setup Grub2"
sed -i 's/^#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
sed -i 's/^GRUB_PRELOAD_MODULES=.*[^"]/& lvm/' /etc/default/grub
sed -i 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX=\"rd.luks.name=$UUID_root=root root=\/dev\/mapper\/root$hibernation_HOOK rd.luks.name=$UUID_boot=cryptlvm$discard_HOOK\"/' /etc/default/grub
sed -i 's/^#GRUB_BACKGROUND.*$/GRUB_BACKGROUND="\/boot\/grub\/themes\/starfield\/starfield.png"/' /etc/default/grub

if (( $with_hibernation != 1 ))
then
  echo "swap		/dev/$volume_group/cryptswap		/dev/urandom		$discard_FSTAB swap,cipher=aes-xts-plain64,size=256" >> /etc/crypttab
fi
echo "home		/dev/$volume_group/crypthome		/etc/luks-keys/home		$discard_FSTAB noauto" >> /etc/crypttab

sed -i -r '/^(# \/|UUID)/d' /etc/fstab
echo "/dev/mapper/root		/		ext4		defaults,noatime		0		1" >> /etc/fstab
echo "/dev/mapper/cryptlvm		/boot		ext4		defaults,noatime		0		2" >> /etc/fstab
echo "/dev/mapper/swap		none		swap		sw		0		0" >> /etc/fstab
echo "/dev/mapper/home		/home		ext4		defaults,noatime		0		2" >> /etc/fstab

grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

if (( $with_firewall == 1 ))
then
  echo "Setup FireWall"
  /Install/1_2_firewallSetup.sh '/etc/nftables.conf'
fi

echo "Setup NetworkManager"
systemctl enable NetworkManager
EOF

rm -rf /mnt/Install

umount -R /mnt

echo "ArchLinux is ready. Reboot now..."
