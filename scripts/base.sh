#!/usr/bin/env bash

# Remove MAC address and UUID from non-loopback interface configuration files
sed --in-place '/^HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth*
sed --in-place '/^UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth*

# Tell udev to disable the assignment of fixed network interface names
# http://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
ln --symbolic /dev/null /etc/udev/rules.d/80-net-name-slot.rules
echo "==> Configuring sshd_config options"

echo "==> Turning off sshd DNS lookup to prevent timeout delay"
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "==> Disabling GSSAPI authentication to prevent timeout delay"
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config

yum -y install cloud-init
