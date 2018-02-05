if [[ $# -eq 1 ]];
then
       if [[ $1 =~ ^(([0-9]|[1-9][0-9])|(1[0-9]{2}|2([0-4][0-9]|5[0-5])))\.(([0-9]|[1-9][0-9])|(1[0-9]{2}|2([0-4][0-9]|5[0-5])))$ ]]
       then

              echo -e "Installing System\n\n"
              yum -y install deltarpm
              yum -y update
              yum -y groupinstall "Development Tools" "X Window System" "Fonts"
              yum install -y epel-release centos-release-scl
              yum install -y devtoolset-7-gcc* cmake3 hwloc-devel libmicrohttpd-devel \
                     openssl-devel tmux libuv libuv-devel htop mlocate net-tools traceroute \
                     libcurl-devel libstdc++-static \
                     firefox vim gedit nmap nano wget httpd bind-utils gd gd-devel perl-GD squid \
                     gnome-classic-session gnome-terminal control-center telnet unzip

              unlink /etc/systemd/system/default.target
              ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target

              #enable hugepages support
              echo "vm.nr_hugepages=128" >> /etc/sysctl.conf

              echo -e "Creating Squid directories\n\n"
              mkdir /logs/squid
              chown squid:squid /logs/squid
              mkdir /cache/squid
              chown squid:squid /cache/squid
              mkdir /cache/squid/swap
              chown squid:squid /cache/squid/swap
              cp proxy_list passwd update.sh squid.conf /etc/squid/
              systemctl enable squid
              ./update.sh $1
              squid -z


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
              #yum --enablerepo=elrepo-kernel -y install kernel-ml
              
              
              # AUTO-CONFIGURE MOUNT OPTIONS
              echo "Auto-Configuring mount options..."
              # Stores name of partitions(space seperated) on which caches,logs,data are present
              cache_prt=$(cat /etc/fstab | grep -E '[[:blank:]]/cache[[:blank:]]|/cache[[:digit:]]+' | awk '{print $2}')
              log_prt=$(cat /etc/fstab   | grep -E '[[:blank:]]/log[[:blank:]]|/log[[:digit:]]+'     | awk '{print $2}')
              data_prt=$(cat /etc/fstab  | grep -E '[[:blank:]]/data[[:blank:]]|/data[[:digit:]]+'   | awk '{print $2}')
              
              config_dirs=$(echo $cache_prt $data_prt $log_prt)
              echo -e "Partitions selected are :$(tput bold)\n\n$config_dirs\n$(tput sgr0)"
              
              # escaping the "/" with "\/"
              config_dirs=$(echo $config_dirs | sed 's:/:\\/:g')
              options="defaults,noatime"
              
              for i in $config_dirs; do
                     sed -i '/'"[[:blank:]]$i[[:blank:]]"'/ s/defaults/'"$options"'/' /etc/fstab
              done
              echo "Mount options succesfully configured with \"$options\"..."

       else
              echo "IP not valid"
       fi
else
       echo "Usage $0 [last 2 octects of ip]"
fi

