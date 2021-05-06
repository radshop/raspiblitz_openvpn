# raspiblitz_openvpn
Scripts to install and configure a clean Ubuntu 20.04 VPS as an OpenVPN gateway for Raspiblitz and install the client certificate.

## Acknowledgments
1. [Rootzoll](https://github.com/rootzoll) has done the hard part with the [Raspiblitz](https://github.com/rootzoll/raspiblitz) project - this is just a minor addition.
2. The [Podcast Index](https://podcastindex.org) is enabling Podcasting 2.0 to send micropayments over the Lightning Network for content creators. They inspired me to get involved in this whole deal.

## Assumptions, Warnings, Notes, Misc.
1. These scripts were developed and tested using a brand new Ubunutu 20.04 Server VPS. 
    1. If you run these scripts on a server that is already configured, there's no telling what you might break.
    2. If you use any other version of Linux, you are in uncharted territory.
2. These scripts are intended to create a VPN connection for a single Raspiblitz to connect to the Internet without using Tor and without exposing your home IP address. Because we map the necessary ports from the VPN to the Raspiblitz, it's really only suitable as a single-purpose VPN unless you are an expert in how to reconfigure for additional uses.
2. Get your Raspiblitz installed, configured, and confirmed to be working before you try to connect it to a VPN. Otherwise if you have any problems, you will not know if it's the VPN connection or your Raspiblitz configuration.
3. Recommended hosting providers:
    1. The first time I set up an OpenVPN server, I used a guide published by [Digital Ocean](https://digitalocean.com). I've since developed my own set of scripts and procedures based on what I learned from them and others. Since they helped me and now I'm helping you, it might be cool if you got one of their lowest tier droplets to run your VPN.
    2. I also am a fan of [Linode](https://linode.com).
    3. And there are many others to choose from. Just make sure you are a getting a plain-vanilla Ubuntu 20.04 LTS server, nothing preconfigured. Otherwise these scripts might not work.
4. This project creates the CA (certificate authority) key on the same server where we will be running our VPN. Normally this is not considered a good security practice. The reason it's okay in this case is that we are setting up this VPN to have only 1 client - Raspiblitz. So once we've generated that client certificate, we make an offline backup of the CA key and delete it from the server.
    1. If you want to create certificates for multiple clients to use your VPN, you should not use these scripts - set up a standalone CA server. Instructions for how to do that are outside the scope of this project.
5. The most reliable way to connect from a home-based Raspberry Pi to the hosted VPN is with UDP port 1194 - that's the standard port.
    1. If you know what you are doing and want to change that configuration, it's not a big deal.
    2. It's exceedingly rare for home or business ISPs to block UDP port 1194 - if they did, no one would be able to work from home over a VPN on that port. If you are having trouble with connectivity, don't assume that's the cause unless you check with your ISP first.
6. This is a "quick & dirty" way for me to get the scripts and procedure out to anyone who can benefit. I haven't tried to address all the ways this could be optimized. I have tested these scripts and this procedure multiple times, and it definitely works flawlessly for me on my VPS provider and my Raspiblitz on my home network. If it doesn't work for you, I have limited resources to help you, but I'll try.

---

## Installation Procedure
### Step 0: Preliminary Server Setup
#### Step 0.a Basics
1. Starting with a plain-vanilla Ubuntu 20.04 LTS Server VPS, complete the following before you are ready to run the scripts. (Instructions for these are not in the scope of this document - Digital Ocean, Linode, and others have great guides.) 
    1. Create a new user account (not root) and add that user to the sudoers. All commands run in this procedure should be run with that user account, not root.
    2. Add your SSH public key to the new user account so you can connect without a password.
    3. I recommend that you disable root login and password login so that only valid non-root SSH access is possible. That's the best way to secure your server.
    4. If your setup instructions include configuring the UFW firewall, I recommend that you enable port 22 (SSH) only at this point. The setup scripts include UFW configuration, so the less you do in advance the better to avoid any conflicts.
    5. Setting the hostname and timezone are good practices, but not essential. 
        1. If you want the hostname to match the certificate name we are generating (which doesn't matter in practice but can avoid confusion for you), you can execute `sudo hostnamectl set-hostname lvpn`. The new hostname will show next time you log in.
2. Clone this git repository locally. It doesn't matter which method you use:
    1. If your SSH private key is on the server and the corresponding public key is added to your Github account: `git clone git@github.com:radshop/raspiblitz_openvpn.git`
    2. Otherwise `git clone https://github.com/radshop/raspiblitz_openvpn.git`
3. Change directories to the root of the git repository (eg. `cd ~/raspiblitz_openvpn` if that's where you cloned it to.) Unless stated otherwise, all commands run on the server assume that you are in the root of the git repo.
#### Step 0.b Setting Configuration Parameters
In this initial release, I have not parameterized the scripts for any local values. I may do that in a later release, but for now you just need to make a couple simple changes to the files for your unique environment.
1. Add your IP address to the base configuration. For this you will need the public IP address of your server (provided by your hosting service).
    1. Edit base.conf (I use vim, but nano is more comfortable for many, especially beginners): `nano files/base.conf`
    2. On line 2, replace the word `my-server` with the IP address of your server and save the file.
2. We need to confirm that your default network interface is `eth0`, which should almost always be the case for a hosted VPS.
    1. Run the command `ip address`, which will list the network interfaces and their IP addresses. You are looking for the IPv4 address, which will be preceded by the word `inet`.
    2. If your public IP address is bound to `eth0`, the you are good to go.
    3. If your public IP is bound to a different interface, then you need to update the UFW before rules:
        1. Edit before.rules: `nano files/before.rules`
        2. In lines 19, 20, and 23 replace all references to `eth0` with the identifier of your default interface. Then save the file.

### Step 1: Server Readiness for Generating Certificates and OpenVPN
This command must be run as sudo:

`sudo ./01_sudo_readyserver.sh`

The script should run from beginning to end without the need for any intervention.

### Step 2: Generate Server Certificates
This command must NOT be run as sudo - just local user privileges:

`./02_servercertificates.sh`

This script will need some interaction:
1. `Enter` to accept the default CA Common Name - there's no reason to change it.
2. `Enter` to accept the Host Common Name - if you change it, you will break subsequent steps of this procedure.
3. Confirm by typing `yes` at the prompt and `Enter`

### Step 3: Configure the VPN Server
This command must be run as sudo:

`sudo ./03_sudo_configurevpn.sh`

The script should run from beginning to end without the need for any intervention. At the end it outputs the status of the VPN server, which should include a line that starts with `Active: active (running)`

### Step 4: Generate the Client Certificate
This command must NOT be run as sudo - just local user privileges:

`./04_client_certificate.sh`

This script will need some interaction:
1. `Enter` to accept the Host Common Name - if you change it, you will break subsequent steps of this procedure.
2. Confirm by typing `yes` at the prompt and `Enter`

### Step 5: Copy the Client Certificate to Raspiblitz
The client certificate is generated on the server at ` ~/client-configs/files/raspiblitz.ovpn`. You need to move this file to your Raspiblitz. The destination for the file is `/home/admin/raspiblitz.ovpn`

Less experienced users might find it surprisingly difficult to move the file using terminal command line utilities. If you know how to use `scp` or the Putty PSFTP, then you can copy the file that way. But one of the most straightforward ways is to just use text copy/paste as follows. It requires having SSH connections to both the VPN server and the Raspiblitz server. (I don't use an LCD on my Raspiblitz, just SSH. I don't know if there's a way to do this without SSH, but I doubt it.)

In any case, the destiantion for the file is /home/admin/raspiblitz.ovpn

1. If your terminal supports right-click to copy/paste, then that's great. If not, you need to find out what key sequence (eg. CTRL-SHIFT-C/CTRL-SHIFT-V or CTRL-INSERT/SHIFT-INSERT or something else). You need to know that before you can proceed.
2. On the VPN server, output the certificate cleanly to the terminal with `clear && cat ~/client-configs/files/raspiblitz.ovpn`. Then select and copy the entire certificate. You must get the whole thing. If scrolling to select for copying is not supported or is difficult on your terminal, you can use `less ~/client-configs/files/raspiblitz.ovpn` and copy it in sections - just be really sure not to miss or duplicate any line.
3. It can be helpful to paste into a desktop text editor and review the contents to make sure everything is right. Or you can go straight to your Raspiblitz.
4. On the Raspiblitz, over ssh as the admin user, use vim or nano to create the empty file: `nano ~/raspiblitz.ovpn`
5. Paste all of the certificate into that file and save.

### Step 6: Configure the VPN on Raspiblitz
There is no packaged script for this part - it's a series of individual steps. All these should be run on your Raspiblitz logged in via SSH as the admin user.

First install OpenVPN on the Raspiblitz: `sudo apt install openvpn`.

Next check your network interfaces so you know what it looks like before you set up your VPN. run `ip address` and look at the result - typically `lo` for the local loopback, `eth0` for the wired network port and `wlan0` for the wifi antenna. Most important - there is no `tun0` interface for the VPN tunnel.

Now we will go through a multi-step process to verify that your VPN connection is working. More advanced users can simplify this, but this is a process that should work for anyone.
#### Verification Step A: Interactive Output
Start the VPN interactively by running `sudo openvpn --config raspiblitz.ovpn`.

1. If the VPN connects successfully, the last line of the output should include `Initialization Sequence Completed` - that's what you want. There might be wome warning messages but should be no error messages in the output.
2. Stop the VPN connection with `CTRL-c`.

#### Verification Step B: Run as a Daemon
Start the the VPN as a background daemon by running `sudo openvpn --config raspiblitz.ovpn --daemon`.

1. Enter `ip address` and confirm that the new `tun0` interface is present with IP address 10.8.0.10.
2. Use an external service to confirm your public IP address: `curl https://ifconfig.me ; echo`. The result should show the IP of your VPN server.

#### Set VPN to Start on Boot
To make sure your VPN connection starts when the Raspiblitz reboots, we need to copy your certificate to the OpenVPN directory and change the extension to .conf.

1. Enter `sudo cp ~/raspiblitz.ovpn /etc/openvpn/raspiblitz.conf`
2. To confirm that everything is working, enter `restart` so the openvpn daemon stops and the auto-connect starts on boot.
3. Reconnect to the Raspiblitz over SSH once it restarts. Wait for all of the Raspiblitz services to start then exit from the main menu to a command prompt.
4. Use `ip address` and `curl https://ifconfig.me ; echo` as you did above to confirm that the VPN is connected

### Step 7: Server Cleanup
If you leave the CA Key in place on your server, any party that gains access will be able to create their own certificates for your VPN. You want to prevent that. 
1. Make an offline copy of your server key.
    1. `cat ~/easy-rsa/pki/private/ca.key` to output the contents of the key.
    2. Copy the output and save it in a safe place off the server.
    3. Delete the file once you have a safe copy. `rm ~/easy-rsa/pki/private/ca.key`
2. If you need to generate any certificates in the future, recreate the CA Key from your offline copy. If you lose it, you will not be able to create additional client certificates for this server - you will need to regenearate all of the server and client certificates.

We also want to get rid of our temporary files just to keep things neat: `sudo rm -r /tmp/raspiblitz_openvpn/`

---

## Administration
### Port Mapping
The mapping of ports for Bitcoin (8333) and Lightning (9735) through the VPN is done by 2 lines in the before.rules file:

`-A PREROUTING -i eth0 -p tcp --dport 8333 -j DNAT --to-destination 10.8.0.10`

`-A PREROUTING -i eth0 -p tcp --dport 9735 -j DNAT --to-destination 10.8.0.10`

If you need to map ports for additional services Raspiblitz offers, just edit the rules `sudo nano /etc/ufw/before.rules`. Add a new line with everything identical except the port number after `--dport`.

When you are done, restart UFW to make the change: `sudo service ufw restart`
