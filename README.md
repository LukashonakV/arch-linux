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
- {Partition scheme}: BIOS/GPT.
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
  
#part_schm
