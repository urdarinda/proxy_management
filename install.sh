echo -e "Installing System\n\n"
yum -y update
yum -y groupinstall "Development Tools" "X Window System" "Fonts" 
yum -y install mlocate net-tools firefox vim gedit nmap nano wget httpd deltarpm bind-utils gd gd-devel perl-GD squid \
       gnome-classic-session gnome-terminal control-center epel-release

unlink /etc/systemd/system/default.target
ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target


echo -e "Creating Squid directories\n\n"
mkdir /logs/squid
chown squid:squid /logs/squid
mkdir /cache/squid
chown squid:squid /cache/squid
mkdir /cache/squid/swap
chown squid:squid /cache/squid/swap
systemctl enable squid

echo -e "Setting up ports\n\n"
firewall-cmd --add-port=3128/tcp --permanent
firewall-cmd --add-port=3128/udp --permanent
firewall-cmd --add-port=3130/tcp --permanent
firewall-cmd --add-port=3130/udp --permanent
#make sure that the following is done to cache and logs
#mount options noatime data=writeback

echo -e "Setting up Date\n\n"
date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"

echo -e "Setting file limits\n\n"
echo "* - nofile 65535">>/etc/security/limits.conf 

#echo -e "Disabling SELINUX\n\n"
#sed  -i 's/enforcing/disabled/' /etc/sysconfig/selinux
#TODO GRUB DEFAULT ABOVE IS BUGGED

echo -e "Installing latest kernel\n\n"
#rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
#rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel -y install kernel-ml

