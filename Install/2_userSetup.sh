#!/bin/bash

#Turn on/off zswap
with_zswap="1"

if [[ with_zswap -eq 1 ]]
then
  mkdir zswapSetup
  cd zswapSetup
  git clone https://aur.archlinux.org/zramswap.git
  cd zramswap
  makepkg -si --noconfirm
  cd ../..
  rm -rf zswapSetup
  systemctl enable zramswap.service
fi

echo "Updating packages"
sudo pacman -Syu --noconfirm

echo "Creating user's folders"
sudo pacman -S --noconfirm xdg-user-dirs
xdg-user-dirs-update

echo "Adding Vulkan support"
sudo pacman -S --noconfirm vulkan-intel vulkan-icd-loader

echo "Installing common applications"
sudo pacman -S --noconfirm firefox openssh htop nmon p7zip ripgrep unzip

echo "Installing fonts"
sudo pacman -S --noconfirm ttf-roboto ttf-droid ttf-opensans ttf-dejavu ttf-liberation ttf-hack noto-fonts ttf-fira-code cantarell-fonts

rm 2_userSetup.sh
