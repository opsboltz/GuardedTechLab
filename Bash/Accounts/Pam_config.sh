#!/bin/bash

# Set path to PAM configuration files
pwquality_conf="/etc/security/pwquality.conf"
login_defs="/etc/login.defs"

# Function to update pwquality.conf
update_pwquality_conf() {
    echo "minlen=8 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1" | sudo tee $pwquality_conf
    echo "Updated $pwquality_conf"
}

# Function to update login.defs for password aging
update_login_defs() {
    sudo sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/' $login_defs
    sudo sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t10/' $login_defs
    sudo sed -i 's/PASS_WARN_AGE\t7/PASS_WARN_AGE\t7/' $login_defs
    echo "Updated $login_defs"
}

# Function to set password expiry for a user
set_password_expiry() {
    read -p "Enter the username: " username
    read -p "Enter maximum days before password expiration: " max_days
    read -p "Enter minimum days before password change: " min_days
    read -p "Enter days of warning before password expires: " warn_days

    sudo chage -M $max_days -m $min_days -W $warn_days $username
    echo "Password expiry set for $username"
}

# Main menu
echo "Password Policy Configuration Script"
echo "1. Update pwquality.conf"
echo "2. Update login.defs for password aging"
echo "3. Set password expiry for a user"
echo "4. Exit"

read -p "Choose an option (1/2/3/4): " option

case $option in
    1) update_pwquality_conf ;;
    2) update_login_defs ;;
    3) set_password_expiry ;;
    4) echo "Exiting script." ;;
    *) echo "Invalid option. Exiting script." ;;
esac
