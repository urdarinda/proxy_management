systemctl status squid
if [ $? -ne 0 ]
then 
    systemctl start squid
fi
