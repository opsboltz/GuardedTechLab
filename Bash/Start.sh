#!/usr/bin/zsh
#Steven.B Cyber Patriot Script to run multiple script that may lead to another script
option=0
echo "1 sec, Updating"
apt update -y
dpkg --configure -a
apt upgrade -y



menu() {
    if [ "$option" -gt 0 ]; then
        option=0
    fi

    echo "Main Menu:
    1. Account Passwords
    2. SSH, FTP, etc.
    3. ClamTK, etc.
    4. OpenVAS
    5. Copy the passwd file
    6. See all commands/applications in /bin
    7. Uninstall apps
    8. Run 1, 2, 3, and 4"
    echo -n "Option:"
    read option
    clear
}

menu

case $option in
    1) bash Accounts/Accounts.sh ;;
    2) bash Basic1/ssh,ftp,etc.sh ;;
    3) bash Basic2/ClamTK,etc.sh ;;
    4) bash Basic3/OpenVAS.sh ;;
    5) cp /etc/passwd . && echo "Passwd File Extracted" ;;
    6) ls /bin > commands_apps ;;
    7) 
        echo "What would you like to delete?"
        read delete
        apt remove "$delete"
        snap remove "$delete"
        echo "You can check if that worked"
        sleep 3
        clear
        ;;
    8) 
        bash Accounts/Accounts.sh
        bash Basic1/ssh,ftp,etc.sh
        bash Basic2/ClamTK,etc.sh
        bash Basic3/OpenVAS.sh
        ;;
    *) ;;
esac

menu
