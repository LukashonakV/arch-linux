# Arch Linux install
Set of install and configuration files

## Notation
- Partition scheme full description https://wiki.archlinux.org/index.php/Partitioning
- Encrypting an entire system https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system
- Solid state drive https://wiki.archlinux.org/index.php/Solid_state_drive
---
## Introduction
- Modularity of the installation and configuration process
- Full disk encryption
- Separate password for each encrypted container
- Auto mounting home partition with the key file
- Hibernation support
- Mirror list ordered by the fastest to lowest
- Continuous TRIM
- Intel microcode
- Grub multi-boot loader
- systemd system and service manager
- [Partition scheme](#Notation): BIOS/GPT.
- Firewall support
- ZSwap suppot
---
## Requirements
- TRIM compatible SSD
- Intel CPU
- Unallocated SDA area
---
## Content
Chapter|      Object|       Description|
|:---:|:---:|:---:|
| 1. Base Installation|   1_baseInstall.sh|Install base clean system on Unalocated SDA area|
| 1. Base Installation|   1_2_firewallSetup.sh|Configures standart base firewall(nftables approach)|
---
## Prerequisites
- Download the freshet ISO Arch image [Arch ISO](https://www.archlinux.org/download/)
- Free up necessary space on [SDA](#Notation)
---
## Technical details
- To be able to open swap/home containers within booting without prompting of password there are appropriate file keys at /etc/luks-keys is used by the system.
- In additional home container can be encrypted with the encryption_passphrase_home.
- For hibernation support encrypted swap container must be early opened. To reach this goal /etc/luks-keys/swap key file is embedded into initramfs.
- When hibernation is OFF swap partition is mounted as plain encrypted with random UUID each boot.
- To get more about encryption [see](#Notation).
---
# 1. Base Installation
  ## 1.1 [Partition scheme](#Notation)
  |NAME|FSTYPE|FSVER|MOUNTPOINT|
  | --- | --- | --- | --- |
  |sda|||
  ├─sda1|||
  ├─sda2|crypto|1|
  &nbsp;&nbsp;&nbsp;&nbsp;└sda2|ext4|1.0|/boot
  └─sda3|LVM2_m|LVM2|
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├─{volume_group}-cryptroot|crypto|2|
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└─root|ext4|1.0|/|
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├─{volume_group}-cryptswap|crypto|2|
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└─swap|swap|1|\[SWAP\]|
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└─{volume_group}-crypthome|crypto|2|
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└─home|ext4|1.0|/home|
   ## 1.2 Variables
   > - continent_city. Is used to set machine zone. See [Arch time zone](https://wiki.archlinux.org/index.php/System_time#Time_zone)
   > - country_for_mirror. Is used to set mirror servers. See [Arch_mirrors](https://wiki.archlinux.org/index.php/Mirrors)
   > - encryption_passphrase_root. Is used to set encryption password for the root container.
   > - encryption_passphrase_boot. Is used to set encryption password for the boot container. The same as encryption_passphrase_root by default.
   > - encryption_passphrase_home. Is used to set encryption password for the home container. The same as encryption_passphrase_root by default.
   > - root_password. Is used to set encryption password for the root user. The same as encryption_passphrase_root by default.
   > - user_name. Defines user name for th new user.
   > - user_password. Is used to set encryption password for the new user. The same as encryption_passphrase_root by default.
   > - volume_group. Defines volume group name to store root,swap,home logical volumes. For example: vg0
   > - part_root_size. Gigabytes reserved for the root [partition](#Notation).
   > - part_swap_size. Gigabytes reserved for the swap [partition](#Notation).
   > - host_name. Defines machines host name.
   > - with_hibernation. Turns ON/OFF special setup in hibernation purpose for.
   > - with_firewall. Turns ON/OFF firewall setup. See [Arch firewall](https://wiki.archlinux.org/index.php/Category:Firewalls)   
   > - disk_type defines physical disk drive where system is going to be installed to. When SDA, TRIM and swappiness configurations take the part. More details about [SSD](#Notation). More details about [SWAP](https://wiki.archlinux.org/index.php/swap)
   > - Gigabytes reserved for the TMPFS. Is OFF, when equal to zero.
   > - with_zswap. Turns ON/OFF Zswap. More details about [ZSwap](https://wiki.archlinux.org/index.php/Improving_performance#Choosing_and_tuning_your_filesystem) zram and szwap section. For activation is used zramswap AUR package[zramswap](https://aur.archlinux.org/packages/zramswap/)
   ## 1.3 Installation
   - Boot into Arch ISO
   - Download Install/1_baseInstall.sh via wget https://raw.githubusercontent.com/lukashonak/arch-linux/master/Install/1_baseInstall.sh
   - Define all variables using favorite editor(vim,nano,etc...)
   - Make file executable using chmod +x 1_baseInstall.sh
   - Execute it using ./1_baseInstall.sh. For to get install.log use ./1_baseInstall.sh >> install.log
