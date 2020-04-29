sudo pacman -S sway swaylock swayidle xorg-server-xwayland

mkdir ~/.config/sway
cp /etc/sway/config ~/.config/sway

echo '# Sway autostart
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  XKB_DEFAULT_LAYOUT=us exec sway
fi' >> ~/.bash_profile
