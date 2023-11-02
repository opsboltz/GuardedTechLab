#!/bin/bash

# Install ClamTk and run it
sudo apt-get update && sudo apt-get install -y clamtk
clamtk
clear

# Install BUM and run it
sudo apt-get install -y bum
bum
clear

# Install SELinux and AppArmor
sudo apt-get install -y selinux-utils apparmor-utils
clear

# Enable and start SELinux
sudo selinux-activate
sudo systemctl start selinux
clear

# Enable and start AppArmor
sudo aa-enforce /etc/apparmor.d/*
sudo systemctl start apparmor
clear

# All done!
echo "Script execution completed!"
