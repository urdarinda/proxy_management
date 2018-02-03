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
              
              echo "Auto-Configure mount options? (Y/n)"
              read -r option
              if ! [[ $option =~ N|n ]]; then     
                     while [[ true ]]; do
                            echo -n "Enter absolute cache directory (eg: /cache) "
                            read -r cache_dir
                            if [[ -z $cache_dir  ]]; then
                                   cache_dir="/cache"
                                   echo "$(tput bold)WARNING$(tput sgr0): Using /cache as cache directory"
                                   echo -n "Continue (Y/n)"
                                   read -r confirm
                                   if ! [[ $confirm =~ N|n ]] ; then
                                          break;
                                   fi
                            fi
                     done
                     # Partition on which cache is mounted, sed pipe replaces "/" with "\/"
                     cache_prt=$(mount | grep $cache_dir | awk '{print $1}' | sed 's:/:\\/:g')
                     # search for line containing cache_prt in  /etc/fstab, replace defaults with default,noatime
                     options="defaults,noatime"
                     sed -i '/'"$cache_prt"'/ s/defaults/'"$options"'/' /etc/fstab
              fi
       else
              echo "IP not valid"
       fi
else
       echo "Usage $0 [last 2 octects of ip]"
fi

