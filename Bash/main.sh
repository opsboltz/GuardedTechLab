#!/bin/bash

# Function to install packages if they are not already installed
install_package() {
  dpkg -l | grep -qw "$1" || sudo apt-get install -y "$1"
}

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Check and install essential packages
packages=(
  boxes openssh-server neofetch clamav snort fail2ban arp-scan nmap ufw 
)

for pkg in "${packages[@]}"; do
  install_package "$pkg"
done

while true; do
  # Display the Main Menu
  clear
  neofetch
  echo 'Ｍａｉｎ Ｍｅｎｕ' | boxes -d stone -p a2v1

  # Present options to the user in three columns
  echo "
1.  Update/Upgrade             2.  Install Applications      3.  Configure SSH
4.  Configure vsftpd           5.  UFW Setup                 6.  Security Enhancements
7.  Package Cleanup             8.  Service Management        9.  Log Management
10. Advanced Firewall Config   11. User Management           12. Backup System
13. System Info & Health Check  14. System Performance       15. File System Management
16. Security Audits            17. Automated Updates        18. Disk Usage Monitoring
19. Process Management         20. Network Traffic Analysis 21. Custom Script Execution
22. Intrusion Detection        23. Malware Scanning         24. ARP Scan
25. Nmap Scan                  26. Exit
"

  read -r option

  case "$option" in
    1)
      echo "Updating and upgrading system..."
      sudo apt-get update -y && sudo apt-get upgrade -y
      sudo apt-get install -y unattended-upgrades neofetch
      echo "Update and Upgrade Complete"
      sleep 2
      ;;
    2)
      echo "Installing applications..."
      applications=(
        nmap gobuster dirbuster hydra tilix neofetch sqlmap wpscan
        wireshark openvpn proxychains vscode docker.io docker-compose
        snapd git terminator gufw tor torbrowser-launcher htop
      )

      for app in "${applications[@]}"; do
        install_package "$app"
      done

      sudo systemctl start snapd
      sudo /usr/lib/snapd/snapd &
      sudo snap install snap-store discord spotify

      echo "Applications installed."
      sleep 2
      ;;
    3)
      echo "Editing SSH config..."
      sleep 1
      sudo nano /etc/ssh/sshd_config
      ;;
    4)
      echo "Editing FTP config..."
      sleep 1
      sudo nano /etc/vsftpd.conf
      ;;
    5)
      echo "Setting up UFW..."
      sudo ufw default allow outgoing 
      sudo ufw default deny incoming
      sudo ufw allow http
      sudo ufw allow 80/tcp
      sudo ufw allow 21/udp
      sudo ufw limit ssh
      sudo ufw enable
      clear
      sudo systemctl status ufw.service
      echo "Complete"
      sleep 2

      clear
      echo "Would you like to disable ICMP pings? (y/n)"

      read -r answer

      if [[ $answer == "y" ]]; then
        echo "Disabling ICMP pings..."

        # Backup the original before.rules file
        sudo cp /etc/ufw/before.rules /etc/ufw/before.rules.bak
        # Add rules to /etc/ufw/before.rules to block ICMP echo-request (ping) packets
        sudo bash -c 'echo "
        # Block ICMP echo-request (ping) packets
        -A ufw-before-input -p icmp --icmp-type echo-request -j DROP
        " >> /etc/ufw/before.rules'

        # Reload UFW to apply the new rules
        sudo ufw reload

        echo "ICMP pings disabled."
        sleep 2
      fi
      ;;
    6)
      echo "Enhancing system security..."
      # For Later Development
      echo "Nothing here, for later security."
      sleep 1
      echo "Security enhancements applied."
      sleep 2
      ;;
    7)
      echo "Cleaning up packages..."
      sudo apt autoremove -y
      sudo apt autoclean -y
      echo "Package cleanup complete."
      sleep 2
      ;;
    8)
      echo "Managing services..."
      echo "1. Start a service"
      echo "2. Stop a service"
      echo "3. Restart a service"
      read -r service_option
      case "$service_option" in
        1)
          read -p "Enter the service name to start: " service_name
          sudo systemctl start "$service_name"
          ;;
        2)
          read -p "Enter the service name to stop: " service_name
          sudo systemctl stop "$service_name"
          ;;
        3)
          read -p "Enter the service name to restart: " service_name
          sudo systemctl restart "$service_name"
          ;;
        *)
          echo "Invalid option."
          ;;
      esac
      sleep 2
      ;;
    9)
      echo "Managing logs..."
      echo "Log files:"
      sudo ls /var/log
      sleep 2
      echo "1. View a log file"
      echo "2. Clear a log file"
      echo "3. Send log file via mail"
      read -r log_option
      case "$log_option" in
        1)
          read -p "Enter the log file name to view: " log_file
          sudo cat /var/log/"$log_file"
          sleep 3
          ;;
        2)
          read -p "Enter the log file name to clear: " log_file
          sudo truncate -s 0 /var/log/"$log_file"
          ;;
        3)
          read -p "Enter the log file name to send via mail: " log_file
          read -p "Enter the recipient email address: " email_address
          sudo mail -s "Log file: $log_file" "$email_address" < /var/log/"$log_file"
          ;;
        *)
          echo "Invalid option."
          ;;
      esac
      sleep 2
      ;;
    10)
      echo "Advanced firewall configuration..."
      # Add advanced firewall configuration commands here
      echo "Advanced firewall configuration complete."
      sleep 2
      ;;
    11)
      echo "User management..."
      echo "1. Add a user"
      echo "2. Delete a user"
      read -r user_option
      case "$user_option" in
        1)
          read -p "Enter the username to add: " username
          sudo adduser "$username"
          ;;
        2)
          read -p "Enter the username to delete: " username
          sudo deluser --remove-home "$username"
          ;;
        *)
          echo "Invalid option."
          ;;
      esac
      sleep 2
      ;;
    12)
      echo "Backup system..."
      echo "Placeholder for backup tool"
      sleep 2
      ;;
    13)
      echo "System info and health check..."
      neofetch
      sleep 3
      echo "System info and health check complete."
      sleep 2
      ;;
    14)
      echo "System performance..."
      # Add system performance commands here
      echo "System performance complete."
      sleep 2
      ;;
    15)
      echo "File system management..."
      # Add file system management commands here
      echo "File system management complete."
      sleep 2
      ;;
    16)
      echo "Security audits..."
      echo "1. Would you like to view wireshark"
      echo "2. Would you like to view your newest ufw file"
      read -r anw
      if [[ $awn == 1 ]]; then
        sudo add-apt-repository ppa:wireshark-dev/stable
        sudo apt update
        sudo apt install wireshark
        wireshark
      else
        # Get the list of ufw log files
        log_files=($(ls /var/log/ufw*))

        # Sort the log files by modification time
        log_files=($(printf "%s\n" "${log_files[@]}" | sort -rn --field-separator=- --key=2))

        # Get the latest log file
        latest_log=${log_files[0]}

        # Check if the latest log file is a tarball
        if [[ $latest_log == *.tar.xz ]]; then
          tar -xvf $latest_log
          latest_log=${latest_log%.tar.xz}
        fi

        nano $latest_log
      fi

      echo "Security audits complete."
      sleep 2
      ;;
    17)
      echo "Automated updates..."
      # Add automated updates commands here
      echo "Automated updates complete."
      sleep 2
      ;;
    18)
      echo "Disk usage monitoring..."
      df -h
      sleep 3
      echo "Disk usage monitoring complete."
      sleep 2
      ;;
    19)
      echo "Process management..."
      top
      sleep 5
      echo "Process management complete."
      sleep 2
      ;;
    20)
      echo "Network traffic analysis..."
      sudo iftop
      sleep 5
      echo "Network traffic analysis complete."
      sleep 2
      ;;
    21)
      echo "Custom script execution..."
      read -p "Enter the path to the script: " script_path
      bash "$script_path"
      echo "Custom script execution complete."
      sleep 2
      ;;
    22)
      echo "Intrusion detection..."
      sudo snort
      sleep 3
      echo "Intrusion detection complete."
      sleep 2
      ;;
    23)
      echo "Malware scanning..."
      sudo clamscan -r /
      sleep 3
      echo "Malware scanning complete."
      sleep 2
      ;;
    24)
      echo "ARP scan..."
      sudo arp-scan --localnet
      sleep 3
      echo "ARP scan complete."
      sleep 2
      ;;
    25)
      echo "Nmap scan..."
      read -p "Enter the IP range to scan: " ip_range
      sudo nmap -sP "$ip_range"
      sleep 3
      echo "Nmap scan complete."
      sleep 2
      ;;
    26)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option. Please select a valid number."
      sleep 2
      ;;
  esac

  read -p "Press enter to return to the main menu..."
done
