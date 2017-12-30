if [[ $# -eq 1 ]];
then
       if [[ $1 =~ ^(([0-9]|[1-9][0-9])|(1[0-9]{2}|2([0-4][0-9]|5[0-5])))\.(([0-9]|[1-9][0-9])|(1[0-9]{2}|2([0-4][0-9]|5[0-5])))$ ]]
       then
			squiddir=/etc/squid
			giturl=https://raw.githubusercontent.com/urdarinda/proxy_management/master
			mv $squiddir/squid.conf $squiddir/squid.conf.bak
			wget $giturl/squid.conf -O $squiddir/squid.conf
			wget $giturl/proxy_list -O $squiddir/proxy_list
			wget $giturl/porndomain -O $squiddir/porndomain
			echo "$1"
			tmp=`echo "$1" | cut -d. -f1``echo "$1" | cut -d. -f2`
			echo $tmp
			sed -i s/XXXXXX/$tmp/g $squiddir/squid.conf
			sed -i s/XXX\.XXX/$1/g $squiddir/squid.conf
			systemctl restart squid

		else
              echo "IP not valid"
       fi
else
       echo "Usage $0 [last 2 octects of ip]"
fi
