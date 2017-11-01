if [[ $# -eq 1 ]];
then
       if [[ $1 =~ ^(([0-9]|[1-9][0-9])|(1[0-9]{2}|2([0-4][0-9]|5[0-5])))\.(([0-9]|[1-9][0-9])|(1[0-9]{2}|2([0-4][0-9]|5[0-5])))$ ]]
       then
			mv /etc/squid/squid.conf /etc/squid/squid.conf.bak
			#wget https://raw.githubusercontent.com/urdarinda/proxy_management/master/squid.conf -O /tmp/squid.conf
			echo "$1"
			tmp=`echo "$1" | cut -d. -f1``echo "$1" | cut -d. -f2`
			echo $tmp

		else
              echo "IP not valid"
       fi
else
       echo "Usage $0 [last 2 octects of ip]"
fi