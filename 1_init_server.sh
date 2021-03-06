#!/bin/bash
set -o xtrace

#
# Configure GlusterFS
#
SERVER=`hostname -s`
if [ "$SERVER" == vmi536198  ]; then
  gluster peer probe vmi522170.contaboserver.net
  gluster peer probe vmi576145.contaboserver.net
  gluster peer status
  gluster volume create dockervols replica 3 vmi536198.contaboserver.net:/gluster-storage vmi522170.contaboserver.net:/gluster-storage vmi576145.contaboserver.net:/gluster-storage force
  gluster volume start dockervols
  gluster volume status
  gluster volume profile dockervols start
  gluster volume profile dockervols info
fi

#
# Install docker
#
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
sudo apt update -y
sudo apt install docker-ce -y
sudo systemctl status docker
sudo usermod -aG docker onebuck

#
# Install Docker Plugin GlusterFS
#
docker plugin install --alias gfs1 mikebarkmin/glusterfs SERVERS=vmi536198.contaboserver.net,vmi522170.contaboserver.neti,vmi576145.contaboserver.net VOLNAME=dockervols DEBUG=1
docker plugin install --alias gfs2 originnexus/glusterfs-plugin SERVERS=vmi536198.contaboserver.net,vmi522170.contaboserver.net,vmi576145.contaboserver.net VOLUME_NAME=dockervols

#
# Set Firewall
#
#cp iptables.conf /etc/iptables.conf
#iptables-restore -n /etc/iptables.conf
#cp iptables.service /etc/systemd/system/iptables.service
#systemctl enable --now iptables

#
# Install Net Tools & Fail2Ban
#
apt install net-tools iftop -y
apt install fail2ban -y
fail2ban-client status 
fail2ban-client status sshd

