#! /bin/bash
#
# Copyright (C) 2021 Myron Weber
#
# Distributed under terms of the MIT license.
#

mkdir -p ~/client-configs/keys
mkdir -p ~/client-configs/files
cp files/base.conf ~/client-configs/
pushd ~/easy-rsa
./easyrsa gen-req raspiblitz nopass
./easyrsa import-req pki/reqs/raspiblitz.req
./easyrsa sign-req client raspiblitz
cp pki/private/raspiblitz.key ~/client-configs/keys/
cp pki/issued/raspiblitz.crt ~/client-configs/keys/
cp pki/ca.crt ~/client-configs/keys/
cp ta.key ~/client-configs/keys/
popd

touch ~/client-configs/files/raspiblitz.ovpn
cat ~/client-configs/base.conf >> ~/client-configs/files/raspiblitz.ovpn
echo -e '<ca>' >> ~/client-configs/files/raspiblitz.ovpn
cat ~/client-configs/keys/ca.crt >> ~/client-configs/files/raspiblitz.ovpn
echo -e '</ca>\n<cert>' >> ~/client-configs/files/raspiblitz.ovpn
cat ~/client-configs/keys/raspiblitz.crt >> ~/client-configs/files/raspiblitz.ovpn
echo -e '</cert>\n<key>' >> ~/client-configs/files/raspiblitz.ovpn
cat ~/client-configs/keys/raspiblitz.key >> ~/client-configs/files/raspiblitz.ovpn
echo -e '</key>\n<tls-crypt>' >> ~/client-configs/files/raspiblitz.ovpn
cat ~/client-configs/keys/ta.key >> ~/client-configs/files/raspiblitz.ovpn
echo -e '</tls-crypt>' >> ~/client-configs/files/raspiblitz.ovpn

cat ~/client-configs/files/raspiblitz.ovpn

