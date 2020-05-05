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

echo "Setup XDG folders"
mkdir -p $XDG_DATA_HOME
mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_CACHE_HOME
mkdir -p $XDG_STATE_HOME

echo "Setup GTK3"
mkdir $XDG_CONFIG_HOME/gtk-3.0
cp /usr/share/gtk-3.0/settings.ini $XDG_CONFIG_HOME/gtk-3.0

mkdir -p ~/.local/share

echo "Setup colors"

echo "	Setup pacman colors"
sudo sed -i 's/#Color/Color/' /etc/pacman.conf
sudo sed -i 's/#TotalDownload/TotalDownload/' /etc/pacman.conf

echo "	Setup man colors"
echo "# man colors
man() {
	LESS_TERMCAP_md=$'\e[01;31m' \\
	LESS_TERMCAP_me=$'\e[0m' \\
	LESS_TERMCAP_se=$'\e[0m' \\
	LESS_TERMCAP_so=$'\e[01;44;33m' \\
	LESS_TERMCAP_ue=$'\e[0m' \\
	LESS_TERMCAP_us=$'\e[01;32m' \\
	command man \"\$@\"
}" >> ~/.bashrc
echo "	Setup diff colors"
echo "# diff colors
alias diff='diff --color=auto'" >> ~/.bashrc
