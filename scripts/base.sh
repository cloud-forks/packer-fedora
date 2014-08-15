#!/bin/sh -ex

cat <<EOF >  /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE="eth0"
BOOTPROTO=dhcp
NM_CONTROLLED="no"
PERSISTENT_DHCLIENT=1
ONBOOT="yes"
TYPE=Ethernet
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPV6_FAILURE_FATAL=yes
NAME="eth0"
EOF

# Tell udev to disable the assignment of fixed network interface names
# http://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
ln --symbolic /dev/null /etc/udev/rules.d/80-net-name-slot.rules
echo "==> Configuring sshd_config options"
sed -i 's|^disable_root:.*|disable_root: 0|g' /etc/cloud/cloud.cfg
sed -i 's|^ssh_pwauth:.*|ssh_pwauth: 1|g' /etc/cloud/cloud.cfg
sed -i 's|UseDNS no|UseDNS yes|g' /etc/ssh/sshd_config
sed -i 's|GSSAPIAuthentication yes|GSSAPIAuthentication no|g'  /etc/ssh/sshd_config
sed -i 's|PasswordAuthentication no|PasswordAuthentication yes|g' /etc/ssh/sshd_config
sed -i 's|#PermitRootLogin yes|PermitRootLogin yes|g' /etc/ssh/sshd_config

cat <<EOF > /etc/fstab
/dev/sda1            /          ext4             defaults,discard,relatime     1    1
EOF
yum -y install cloud-init qemu-guest-agent

cat <<EOF > /etc/cloud/cloud.cfg.d/50_allow_root.cfg
users: []
disable_root: 0
ssh_pwauth: 1
EOF

if ! grep -q growpart /etc/cloud/cloud.cfg; then
  sed -i 's/ - resizefs/ - growpart\n - resizefs/' /etc/cloud/cloud.cfg
fi

if [ ! -e /etc/sysconfig/kernel ]; then
cat <<EOF > /etc/sysconfig/kernel
# UPDATEDEFAULT specifies if new-kernel-pkg should make
# new kernels the default
UPDATEDEFAULT=yes

# DEFAULTKERNEL specifies the default kernel package type
DEFAULTKERNEL=kernel
EOF
fi

if [ ! -e /etc/sysconfig/network ];then
cat > /etc/sysconfig/network <<EOF
NETWORKING=yes
NOZEROCONF=yes
EOF
fi



