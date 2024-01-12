#!/bin/bash

# Install ClamAV and run it
apt-get update && sudo apt-get install -y clamav clamtk
freshclam
clamscan -r /
clear

# Install BUM and run it
apt-get install -y bum
bum
clear

# Install SELinux and AppArmor
apt-get install -y selinux-utils apparmor-utils
clear

# Enable and start SELinux
selinux-activate
systemctl start selinux
clear

# Enable and start AppArmor
aa-enforce /etc/apparmor.d/*
systemctl start apparmor
clear

# All done!
echo "Script execution completed!"
