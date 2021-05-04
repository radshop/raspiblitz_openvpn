#! /bin/bash
#
# Copyright (C) 2021 Myron Weber
#
# Distributed under terms of the MIT license.
#

mkdir ~/easy-rsa
ln -s /usr/share/easy-rsa/* ~/easy-rsa/
chmod -R 700 ~/easy-rsa
cp files/vars ~/easy-rsa/vars
cp files/before.rules /tmp/raspiblitz_openvpn
cp files/server.conf /tmp/raspiblitz_openvpn

pushd ~/easy-rsa
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req lvpn nopass
./easyrsa import-req ~/easy-rsa/pki/reqs/lvpn.req
./easyrsa sign-req server lvpn
openvpn --genkey --secret ~/easy-rsa/ta.key
cp ~/easy-rsa/pki/private/lvpn.key /tmp/raspiblitz_openvpn
cp ~/easy-rsa/pki/issued/lvpn.crt /tmp/raspiblitz_openvpn
cp ~/easy-rsa/pki/ca.crt /tmp/raspiblitz_openvpn
cp ~/easy-rsa/ta.key /tmp/raspiblitz_openvpn

popd

