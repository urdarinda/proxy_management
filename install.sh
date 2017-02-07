su
ip route del default gw 172.31.100.1
ip route del default
ip route
yum -y update
yum -y install mlocate net-tools firefox vim
yum -y groupinstall Development Tools
yum -y groupinstall "X Window System"
yum -y install gnome-classic-session gnome-terminal control-center liberation-mono-fonts
unlink /etc/systemd/system/default.target
ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
yum -y install squid
mkdir /logs/squid
chown squid:squid /logs/squid
mkdir /cache/squid
chown squid:squid /cache/squid
firewall-cmd --add-port=3128/tcp --permanent
firewall-cmd --add-port=3128/udp --permanent
#make sure that the following is done to cache and logs
#mount options noatime data=writeback noatime
#/etc/sysconfig/selinux disable
echo "* - nofile 65535">>/etc/security/limits.conf 