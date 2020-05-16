#!/bin/bash

#Turn on/off zswap
with_zswap="1"

if [[ with_zswap -eq 1 ]] && [[ -z $(lsblk /dev/zram0) ]]
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

echo "Setup neovim"
mkdir -p $XDG_CONFIG_HOME/nvim
touch $XDG_CONFIG_HOME/nvim/init.vim

mkdir -p ~/.local/share

echo "Setup bash promt"
sed -i "s/PS1.*/#&1/" ~/.bashrc
echo "# Bash promt customization
    set_prompt() {
    Date_right='\\[\$(tput sc; printf \"%*s\" \$COLUMNS \"[\\t]\"; tput rc)\\]'
    Color_3='\\[\\e[38;5;3m\\]'
    Color_223='\\[\\e[38;5;223m\\]'
    Color_reset='\\[\\e[0m\\]'

    PS1=\"\$Date_right\"\"\$Color_223\"\"\\u\$Color_reset\"\"@\\h \$Color_223\"\"\\w\\n\$Color_reset\"\"> \$Color_3\"\"\\$ \$Color_reset\"
}
PROMPT_COMMAND='set_prompt'" >> ~/.bashrc
#sed -i "s/PS1.*/PS1='\\\[\$(tput sc; printf \"%*s\" \$COLUMNS \"[\\\t]\"; tput rc)\\\]\\\[\\\e[38;5;223m\\\]\\\u\\\[\\\e[38;5;20m\\\]@\\\h \\\[\\\e[38;5;223m\\\]\\\W\\\n\\\[\\\e[38;5;20m\\\]> \\\[\\\e[38;5;3m\\\]\\\$ \\\[\\\e[0m\\\]'/" ~/.bashrc

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
echo "	Setup grep colors"
echo "# grep colors
alias grep='grep --color=auto -n'" >> ~/.bashrc
echo "	Setup ip colors"
echo "# ip colors
alias ip='ip -color=auto'" >> ~/.bashrc

echo "Setup bash functions"
echo "# cd + ls
cl() {
	local dir=\"\$1\"
	local dir=\"\${dir:=\$HOME}\"
	if [[ -d \"\$dir\" ]]; then
		cd \"\$dir\" >/dev/null; ls
	else
		echo \"bash: cl: \$dir: Directory not found\"
	fi
}" >> ~/.bashrc
