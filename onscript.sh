#script to check whether squid is off, if it is it turns on squid

systemctl status squid
if [ $? -ne 0 ]
then 
    systemctl start squid
fi
