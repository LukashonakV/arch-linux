continent_city="Europe/Minsk"
country_for_mirror="BY"
encryption_passphrase_root=""
encryption_passphrase_boot=$encryption_passphrase_root
root_password=$encryption_passphrase_root
user_name=""
user_password=$encryption_passphrase_root
volume_group=""
part_root_size="32"
part_swap_size="2"
host_name=""
with_hibernation="1"

if [[ with_hibernation -eq 1 ]]
then
  hibernation_HOOK="resume=\/dev\/$volume_group\/cryptswap"
  hibernation_SWAP_crypt="swap		/dev/$volume_group/cryptswap		/etc/luks-keys/swap		swap,discard"
else
  hibernation_HOOK=""
  hibernation_SWAP_crypt="swap		/dev/$volume_group/cryptswap		/dev/urandom		swap,discard,cipher=aes-xts-plain64,size=256"
fi

echo "Updating system clock"
timedatectl set-ntp true
timedatectl set-timezone $continent_city

echo "Creating partition tables"
printf "n\n1\n2048\n+1M\nef02\nw\ny\n" | gdisk /dev/sda
printf "n\n2\n\n+500M\n8309\nw\ny\n" | gdisk /dev/sda
printf "n\n3\n\n\n8e00\nw\ny\n" | gdisk /dev/sda

echo "Crypting boot partition with luks1"
printf "%s" "$encryption_passphrase_boot" | cryptsetup luksFormat --type luks1 /dev/sda2
printf "%s" "$encryption_passphrase_boot" | cryptsetup luksOpen /dev/sda2 cryptlvm

echo "Creating and crypting LVM with luks2. LUKS on LVM"
pvcreate /dev/sda3
vgcreate $volume_group /dev/sda3
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

UUID_root=`blkid -s UUID -o value /dev/$volume_group/cryptroot`
UUID_boot=`blkid -s UUID -o value /dev/sda2`

echo "Installing base packages"
yes | pacstrap /mnt base linux linux-firmware intel-ucode

echo "Installing additional packages"
yes | pacstrap /mnt pacman-contrib lvm2 device-mapper cryptsetup networkmanager wget man vim sudo git grub

echo "Installing fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "Installing home partition"
mkdir -m 700 /mnt/etc/luks-keys
dd if=/dev/random of=/mnt/etc/luks-keys/home bs=1 count=256 status=progress
printf "YES" | cryptsetup luksFormat -v /dev/$volume_group/crypthome /mnt/etc/luks-keys/home
cryptsetup -d /mnt/etc/luks-keys/home open /dev/$volume_group/crypthome home
mkfs.ext4 /dev/mapper/home
mount /dev/mapper/home /mnt/home

if [ $with_hibernation -eq 1 ]
then
  echo "Installing swap for hibernation"
  dd if=/dev/random of=/mnt/etc/luks-keys/swap bs=1 count=256 status=progress
  printf "YES" | cryptsetup luksFormat -v /dev/$volume_group/cryptswap /mnt/etc/luks-keys/swap
  cryptsetup -d /mnt/etc/luks-keys/swap open /dev/$volume_group/cryptswap swap
fi

echo "Configuring new system"
arch-chroot /mnt /bin/bash <<EOF
echo "MirrorList"
curl -s "https://www.archlinux.org/mirrorlist/?country=$country_for_mirror&country=all&protocol=https&protocol=http&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors - > /etc/pacman.d/mirrorlist

echo "Timezone"
ln -sf /usr/share/zoneinfo/$continent_city /etc/localtime
hwclock --systohc

echo "Localization"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

echo "Network"
echo $host_name > /etc/hostname
echo "127.0.0.1		localhost" >> /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.0.1		$host_name.localdomain		$host_name" >> /etc/hosts

echo "root password"
echo -en "$root_password\n$root_password" | passwd

echo "Creating new user"
useradd -m -G wheel -s /bin/bash $user_name
usermod -a -G video $user_name
echo -en "$user_password\n$user_password" | passwd $user_name
echo "$user_name ALL=(ALL) ALL" | EDITOR='tee -a' visudo

echo "Initframs"
sed -i 's/^HOOKS.*/HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)/' /etc/mkinitcpio.conf
sed -i 's/^MODULES.*/MODULES=(ext4)/' /etc/mkinitcpio.conf
mkinitcpio -p linux

echo "Grub2"
sed -i 's/^#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
sed -i 's/^GRUB_PRELOAD_MODULES=.*[^"]/& lvm/' /etc/default/grub
sed -i 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX=\"rd.luks.name=$UUID_root=root root=\/dev\/mapper\/root ${hibernation_HOOK} rd.luks.name=$UUID_boot=cryptlvm rd.luks.options=discard\"/' /etc/default/grub

echo $hibernation_SWAP_crypt >> /etc/crypttab
echo "home		/dev/$volume_group/crypthome		/etc/luks-keys/home		noauto,discard" >> /etc/crypttab

sed -i -r 's/^(# \/|UUID).*$//' /etc/fstab
echo "/dev/mapper/root		/		ext4		defaults,noatime		0		1" >> /etc/fstab
echo "/dev/mapper/cryptlvm		/boot		ext4		defaults,noatime		0		2" >> /etc/fstab
echo "/dev/mapper/swap		none		swap		sw		0		0" >> /etc/fstab
echo "/dev/mapper/home		/home		ext4		defaults,noatime		0		2" >> /etc/fstab

grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "Enabling NetworkManager"
systemctl enable NetworkManager
EOF

umount -R /mnt

echo "ArchLinux is ready. Reboot now..."
