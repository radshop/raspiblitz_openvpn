#! /bin/bash
#
# Copyright (C) 2021 Myron Weber
#
# Distributed under terms of the MIT license.
#

# get your server ready
apt update
apt upgrade -y
# close off ports except SSH with the ufw firewall
ufw allow OpenSSH
ufw --force enable
#install the packages we need
apt install -y openvpn easy-rsa

mkdir -p /tmp/raspiblitz_openvpn
chmod 777 /tmp/raspiblitz_openvpn
