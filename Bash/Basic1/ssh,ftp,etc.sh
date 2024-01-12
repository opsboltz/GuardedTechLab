#!/bin/bash

sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

if [ -x "$(command -v vsftpd)" ]; then
    sed -i 's/listen_port=21/listen_port=2121/' /etc/vsftpd.conf
fi

apt update
apt install --only-upgrade firefox

apt purge -y wireshark nmap nc ncat

sed -i 's/Options Indexes FollowSymLinks/Options -Indexes FollowSymLinks/' /etc/apache2/apache2.conf

apt install certbot python3-certbot-apache
a2enmod security2
service apache2 restart

sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/' /etc/login.defs
sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t10/' /etc/login.defs
sed -i 's/PASS_WARN_AGE\t7/PASS_WARN_AGE\t7/' /etc/login.defs

usermod -p '!' nobody

echo "minlen=8 ucredit=1 lcredit=1 dcredit=-1 o" >> /etc/security/pwquality.conf

echo "-:ALL EXCEPT root: deny=5 onerr=fail unlock_time=1800" >> /etc/security/access.conf

sed -i '/pam_unix.so/a auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' /etc/pam.d/common-auth

apt autoremove --purge -y

service ssh restart

echo "Script execution completed."
