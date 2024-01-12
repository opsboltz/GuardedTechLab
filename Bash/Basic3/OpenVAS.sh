#!/bin/bash

# Update package information
apt update
apt upgrade -y

# Install OpenVAS and Lynis
sudo apt install -y openvas

echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list
wget -O - https://packages.cisofy.com/keys/cisofy-software-public.key | sudo apt-key add -
apt update
apt install lynis -y

lynis show version
sleep 1
clear

# Start OpenVAS
sudo openvas-setup

# Run Lynis system audit and save the results to a file
lynis audit system --quick | tee lynis_results.txt

# Run OpenVAS scan and get the scanner's ID
openvas-start
scanner_id=$(openvasmd --create-scanner="My Scanner" --scanner-host=/var/run/openvassd.sock --scanner-type=OpenVAS)

# Launch the scan
openvasmd --start-task $scanner_id

# Wait for the scan to complete (you may adjust the time accordingly)
sleep 600

# Export OpenVAS report to a file
openvasmd --get-report $scanner_id --format pdf > openvas_results.pdf

# Clean up temporary files
openvasmd --delete-scanner=$scanner_id
rm -f /var/run/openvassd.sock

# All done!
echo "Script execution completed!"
