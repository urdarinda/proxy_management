if [[ $# -eq 1 ]];
then
       if [[ $1 =~ ^(([0-9]|[1-9][0-9])|(1[0-9]{2}|2([0-4][0-9]|5[0-5])))\.(([0-9]|[1-9][0-9])|(1[0-9]{2}|2([0-4][0-9]|5[0-5])))$ ]]
       then
       		squidfile=/etc/squid/squid.conf
			mv $squidfile $squidfile.bak
			wget https://raw.githubusercontent.com/urdarinda/proxy_management/master/squid.conf -O $squidfile
			echo "$1"
			tmp=`echo "$1" | cut -d. -f1``echo "$1" | cut -d. -f2`
			echo $tmp
			sed -i s/XXXXXX/$tmp/g $squidfile
			sed -i s/XXX\.XXX/$1/g $squidfile
			systemctl restart squid

		else
              echo "IP not valid"
       fi
else
       echo "Usage $0 [last 2 octects of ip]"
fi