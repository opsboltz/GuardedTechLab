#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
LOGFILE="/var/log/script.log"

need_ssh="no"
need_ftp="no"
need_samba="no"
need_email="no"

log_message() {
    printf "%s\n" "$1" | tee -a "$LOGFILE"
}

ask() {
    read -rp "$1 (y/n): " answer
    [[ "$answer" == [Yy]* ]]
}

install_package() {
    if dpkg -s "$1" &>/dev/null; then
        log_message "$1 is already installed."
    else
        log_message "Installing $1..."
        apt-get install -y "$1"
    fi
}

remove_package() {
    if dpkg -s "$1" &>/dev/null; then
        log_message "Removing $1..."
        apt-get purge -y "$1"
    fi
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root."
        exit 1
    fi
}

ask_services() {
    echo "Check the README. Only say yes to what is required."
    ask "Is SSH required?" && need_ssh="yes" || need_ssh="no"
    ask "Is FTP required?" && need_ftp="yes" || need_ftp="no"
    ask "Is Samba/SMB required?" && need_samba="yes" || need_samba="no"
    ask "Is email required?" && need_email="yes" || need_email="no"
    log_message "ssh=$need_ssh ftp=$need_ftp samba=$need_samba email=$need_email"
}

update_system() {
    log_message "Updating system..."
    apt-get update -y
    apt-get upgrade -y
    install_package unattended-upgrades
    log_message "Update complete."
}

setup_ssh() {
    if [ "$need_ssh" = "yes" ]; then
        install_package openssh-server
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
        sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
        systemctl restart ssh
        log_message "SSH secured."
    else
        if ask "SSH is not required. Remove it?"; then
            systemctl disable --now ssh
            remove_package openssh-server
        fi
    fi
}

setup_ftp() {
    if [ "$need_ftp" = "yes" ]; then
        install_package vsftpd
        cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
        sed -i 's/^#\?anonymous_enable=.*/anonymous_enable=NO/' /etc/vsftpd.conf
        sed -i 's/^#\?local_enable=.*/local_enable=YES/' /etc/vsftpd.conf
        sed -i 's/^#\?write_enable=.*/write_enable=YES/' /etc/vsftpd.conf
        systemctl restart vsftpd
        log_message "FTP secured."
    else
        if ask "FTP is not required. Remove it?"; then
            systemctl disable --now vsftpd
            remove_package vsftpd
        fi
    fi
}

setup_samba() {
    if [ "$need_samba" = "yes" ]; then
        install_package samba
        log_message "Check these lines in smb.conf for guest access:"
        grep -n "guest" /etc/samba/smb.conf
    else
        if ask "Samba is not required. Remove it?"; then
            systemctl disable --now smbd
            systemctl disable --now nmbd
            remove_package samba
        fi
    fi
}

setup_email() {
    if [ "$need_email" = "yes" ]; then
        install_package postfix
        log_message "Email is installed. Check /etc/postfix/main.cf by hand."
    else
        if ask "Email is not required. Remove it?"; then
            systemctl disable --now postfix
            systemctl disable --now dovecot
            remove_package postfix
            remove_package dovecot-core
            remove_package exim4
            remove_package sendmail
        fi
    fi
}

setup_ufw() {
    install_package ufw
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    [ "$need_ssh" = "yes" ] && ufw limit ssh
    [ "$need_ftp" = "yes" ] && ufw allow 21/tcp
    [ "$need_samba" = "yes" ] && ufw allow samba
    [ "$need_email" = "yes" ] && ufw allow 25/tcp
    if ask "Is a web server required?"; then
        ufw allow 80/tcp
    fi
    ufw --force enable
    ufw status verbose
}

check_users() {
    log_message "Normal users:"
    awk -F: '$3>=1000 && $1!="nobody" {print $1}' /etc/passwd
    log_message "Accounts with UID 0 (should only be root):"
    awk -F: '$3==0 {print $1}' /etc/passwd
    log_message "Admins:"
    getent group sudo
}

delete_user() {
    read -rp "Username to delete: " username
    deluser --remove-home "$username"
}

change_password() {
    read -rp "Username to change password for: " username
    passwd "$username"
}

password_policy() {
    install_package libpam-pwquality
    cp /etc/login.defs /etc/login.defs.bak
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/' /etc/login.defs
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 14/' /etc/login.defs
    log_message "Password policy updated."
}

disable_guest() {
    if [ -d /etc/lightdm ]; then
        mkdir -p /etc/lightdm/lightdm.conf.d
        printf "[Seat:*]\nallow-guest=false\n" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf
        log_message "Guest login disabled. Restart to apply."
    else
        log_message "lightdm not found."
    fi
}

fix_permissions() {
    chmod 644 /etc/passwd
    chmod 644 /etc/group
    chmod 640 /etc/shadow
    chmod 640 /etc/gshadow
    log_message "File permissions fixed."
}

find_media() {
    find /home -type f \( -iname "*.mp3" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.wav" \)
}

show_ports() {
    ss -tulpn
}

run_lynis() {
    install_package lynis
    lynis audit system
}

malware_scan() {
    install_package clamav
    systemctl stop clamav-freshclam
    freshclam
    systemctl start clamav-freshclam
    clamscan -ri /home
}

manage_services() {
    echo "1. View running services"
    echo "2. Disable a service"
    read -r choice
    if [ "$choice" = "1" ]; then
        systemctl --type=service --state=running
    elif [ "$choice" = "2" ]; then
        read -rp "Service name: " service_name
        systemctl disable --now "$service_name"
    fi
}

cleanup() {
    apt-get autoclean
    apt-get autoremove -y
}

show_menu() {
    clear
    cat << MENU
============ Main Menu ============
1.  Update/Upgrade
2.  Answer service questions again
3.  Setup SSH
4.  Setup FTP
5.  Setup Samba
6.  Setup Email
7.  Setup Firewall (UFW)
8.  Check Users
9.  Delete a User
10. Change a User Password
11. Password Policy
12. Disable Guest Login
13. Fix File Permissions
14. Find Media Files
15. Show Open Ports
16. Run Lynis
17. Malware Scan
18. Manage Services
19. Package Cleanup
20. Exit
===================================
MENU
}

main() {
    check_root
    log_message "Script started."
    ask_services

    while true; do
        show_menu
        read -rp "Choose an option: " option
        case "$option" in
            1) update_system ;;
            2) ask_services ;;
            3) setup_ssh ;;
            4) setup_ftp ;;
            5) setup_samba ;;
            6) setup_email ;;
            7) setup_ufw ;;
            8) check_users ;;
            9) delete_user ;;
            10) change_password ;;
            11) password_policy ;;
            12) disable_guest ;;
            13) fix_permissions ;;
            14) find_media ;;
            15) show_ports ;;
            16) run_lynis ;;
            17) malware_scan ;;
            18) manage_services ;;
            19) cleanup ;;
            20) log_message "Exiting..."; exit 0 ;;
            *) log_message "Invalid option." ;;
        esac
        read -rp "Press Enter to continue..." pause
    done
}

main
