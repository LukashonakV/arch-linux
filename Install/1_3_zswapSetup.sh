#!/bin/bash

mkdir zswapSetup
cd zswapSetup
git clone https://aur.archlinux.org/zramswap.git
cd zramswap
makepkg -si --noconfirm
cd ../..
rm -rf zswapSetup
systemctl enable zramswap.service
