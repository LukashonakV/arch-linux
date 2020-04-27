#!/bin/bash

#Turn on/off zswap
with_zswap="1"

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

echo "Installing yay"
cd ~/Downloads
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ../..
rm -rf yay

if [[ with_zswap -eq 1 ]]
then
  echo "Setup zramswap"
  yay -S --nodiffmenu --nocleanmenu zramswap
  sudo systemctl enable zramswap.service
fi
