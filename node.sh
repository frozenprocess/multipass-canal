#!/bin/bash

# Wait for it
while [[ $(curl --write-out '%{http_code}' --silent --output /dev/null control.multipass:6443) != "400" ]]
do
    echo "Waiting for control"
    sleep 1
done


/usr/bin/scp -i "/etc/ssh/ssh_host_rsa_key" -o StrictHostKeyChecking=no root@control.multipass:/root/join.sh /root/join.sh
chmod +x /root/join.sh
/root/join.sh
