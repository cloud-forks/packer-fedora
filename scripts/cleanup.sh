#!/bin/sh -ex

# Remove unnecessary packages (and their dependencies)
# which can’t be removed until after the installation process
yum --assumeyes autoremove authconfig firewalld linux-firmware

# Clean up old yum repo data & logs
yum clean all
yum history new
rm --recursive --force /var/lib/yum/yumdb/*
rm --recursive --force /var/lib/yum/history/*
truncate --no-create --size=0 /var/log/yum.log

sed -i 's|^disable_root:.*|disable_root: 0|g' /etc/cloud/cloud.cfg
sed -i 's|^ssh_pwauth:.*|ssh_pwauth: 1|g' /etc/cloud/cloud.cfg

# Remove random-seed, so it’s not the same in every image
rm --force /var/lib/random-seed

dracut -H --force

# Change any incorrect SELinux context labels
fixfiles -R -a restore


