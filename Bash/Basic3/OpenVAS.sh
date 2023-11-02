#!/bin/bash

# Update package information
sudo apt update

# Install OpenVAS
sudo apt install -y openvas

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
sudo openvasmd --delete-scanner=$scanner_id
rm -f /var/run/openvassd.sock

# All done!
echo "Script execution completed!"
