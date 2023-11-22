#!/bin/bash

# Change SSH port to 2222
sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config

# Disable root login in SSH
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Change FTP port to 2121 if installed
if [ -x "$(command -v vsftpd)" ]; then
    sed -i 's/listen_port=21/listen_port=2121/' /etc/vsftpd.conf
fi

# Update Firefox
sudo apt update
sudo apt install --only-upgrade firefox

# Remove known hacking tools (Wireshark, Nmap, and more)
sudo apt purge -y wireshark nmap nc ncat 

# Secure Apache with =indexes and security headers
sed -i 's/Options Indexes FollowSymLinks/Options -Indexes FollowSymLinks/' /etc/apache2/apache2.conf

# Install and secure Apache with Certbot
sudo apt install certbot python3-certbot-apache
sudo a2enmod security2
sudo service apache2 restart

# Configure PAM (security)
sudo sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/' /etc/login.defs
sudo sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t10/' /etc/login.defs
sudo sed -i 's/PASS_WARN_AGE\t7/PASS_WARN_AGE\t7/' /etc/login.defs

# Turn off the guest account
sudo usermod -p '!' nobody

# Configure libpam-cracklib for password complexity
echo "minlen=8 ucredit=1 lcredit=1 dcredit=-1 o" >> /etc/security/pwquality.conf

# Configure account lockout with pam_tally2
echo "-:ALL EXCEPT root: deny=5 onerr=fail unlock_time=1800" >> /etc/security/access.conf

# Add pam_tally2 to common-auth
sed -i '/pam_unix.so/a auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800' /etc/pam.d/common-auth

# Clean up unused packages
sudo apt autoremove --purge -y

# Restart SSH for changes to take effect
sudo service ssh restart

# Print a message indicating the script has completed
echo "Script execution completed."
