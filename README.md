# Arch Linux install
Set of install and configuration files

## Notation
- Partition scheme full description https://wiki.archlinux.org/index.php/Partitioning#GUID_Partition_Table
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
---
## Requirements
- TRIM compatible SSD
- Intel CPU
- Unallocated SDA area
---
## Content
Chapter|      Object|       Description|
|:---:|---:|:---:|
| 1. Base Installation|   1_baseInstall.sh|Install base clean system on Unalocated SDA area|
---
## Prerequisites
- Download the freshet ISO Arch image [Arch ISO](https://www.archlinux.org/download/)
- Free up necessary space on [SDA](#Notation)
---
# 1. Base Installation
  >## 1.1 [Partition scheme](#Notation)
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
