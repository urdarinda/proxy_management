echo -e "Installing System\n\n\n\n"
yum -y update
yum -y install mlocate net-tools firefox vim gedit nmap nano wget httpd
yum -y install bind-utils
yum -y groupinstall Development Tools
yum -y groupinstall "X Window System"
yum -y install gnome-classic-session gnome-terminal control-center liberation-mono-fonts
unlink /etc/systemd/system/default.target
ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
yum -y install squid

echo -e "Creating Squid directories\n\n\n\n"
mkdir /logs/squid
chown squid:squid /logs/squid
mkdir /cache/squid
chown squid:squid /cache/squid
mkdir /cache/squid/swap
chown squid:squid /cache/squid/swap
systemctl enable squid

echo -e "Allowing firewall\n\n\n\n"
firewall-cmd --add-port=3128/tcp --permanent
firewall-cmd --add-port=3128/udp --permanent
#make sure that the following is done to cache and logs
#mount options noatime data=writeback

echo -e "Setting file limits\n\n\n\n"
echo "* - nofile 65535">>/etc/security/limits.conf 

echo -e "Disabling SELINUX\n\n\n\n"
sed  -i 's/enforcing/disabled/' /etc/sysconfig/selinux
#TODO GRUB DEFAULT

echo -e "Installing latest kernel\n\n\n\n"
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-ml

