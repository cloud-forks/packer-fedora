#!/bin/sh -ex

yum update || true

# Remove unnecessary packages (and their dependencies)
# which can’t be removed until after the installation process
yum --assumeyes autoremove authconfig firewalld linux-firmware

# Clean up old yum repo data & logs
yum clean all || true
yum history new || true
rm --recursive --force /var/lib/yum/yumdb/* || true
rm --recursive --force /var/lib/yum/history/* || true
truncate --no-create --size=0 /var/log/yum.log || true

# Remove random-seed, so it’s not the same in every image
rm --force /var/lib/random-seed

dracut -H --force

# Change any incorrect SELinux context labels
fixfiles -R -a restore

rm -rf /tmp/* /root/anaconda-ks.cfg /root/install.log /root/install.log.syslog /etc/udev/rules.d/70-persistent-net.rules || true

fstrim -v /
