#! /bin/bash
#
# Copyright (C) 2021 Myron Weber
#
# Distributed under terms of the MIT license.
#

mkdir /etc/openvpn/ccd
echo ifconfig-push 10.8.0.10 255.255.255.255 > /etc/openvpn/ccd/raspiblitz
cp /tmp/raspiblitz_openvpn/lvpn.key /etc/openvpn/server/
cp /tmp/raspiblitz_openvpn/lvpn.crt /etc/openvpn/server/
cp /tmp/raspiblitz_openvpn/ca.crt /etc/openvpn/server/
cp /tmp/raspiblitz_openvpn/ta.key /etc/openvpn/server/
cp /tmp/raspiblitz_openvpn/server.conf /etc/openvpn/server/
cp /tmp/raspiblitz_openvpn/before.rules /etc/ufw/
echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
echo net.ipv4.ip_forward = 1 >> /etc/ufw/sysctl.conf
ufw default allow FORWARD
ufw allow proto udp to 0.0.0.0/0 port 1194
service ufw restart
systemctl -f enable openvpn-server@server.service
systemctl start openvpn-server@server.service
systemctl status openvpn-server@server.service

