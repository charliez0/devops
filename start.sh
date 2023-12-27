#!/usr/bin/bash

if [ ! -f /home/container/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 4096 -f /home/container/ssh_host_rsa_key -N ""
fi
if [ ! -f /home/container/ssh_host_ecdsa_key ]; then
    ssh-keygen -t ecdsa -b 521 -f /home/container/ssh_host_ecdsa_key -N ""
fi
if [ ! -f /home/container/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /home/container/ssh_host_ed25519_key -N ""
fi

if [ ! -f /run/utmp ]; then
    sudo touch /run/utmp
fi
if [ ! -d /run/sshd ]; then
    sudo mkdir /run/sshd
fi

sudo /usr/sbin/sshd -Def /home/container/sshd_config -p 2222 2>>/home/container/sshd.log &
/usr/bin/websockify 8022 127.0.0.1:2222 2>>/home/container/websockify.log &

echo "/home/container/.ssh/authorized_keys content:" && cat /home/container/.ssh/authorized_keys && echo "# END"
if [ ! -s /home/container/.ssh/authorized_keys ]; then
    read -p "authorized_key:" -r AUTHORIZED_KEYS && echo "$AUTHORIZED_KEYS" | tee /home/container/.ssh/authorized_keys
fi

exec /usr/bin/bash --login
