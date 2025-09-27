#!/bin/bash
sudo cp -r . /usr/share/plymouth/themes/evil-nix/
sudo plymouth-set-default-theme evil-nix
sudo update-initramfs -u
echo "Evil Nix Plymouth theme installed!"
