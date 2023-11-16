#!/usr/bin/zsh
option=0

menu() {
    if [ "$option" -gt 0 ]; then
        option=0
    fi

echo "1.Account Passwords
2.ssh,ftp,etc 
3.Clamtk,etc 
4.OpenVAS 
5.copy the passwd file 
6.see all commands/applications in /bin 
7.uninstall apps
8.run 1,2,3 and 4"
	echo -n "
Option:"
    read option
    clear
}

menu

if [ "$option" = 1 ]; then
    bash Accounts/Accounts.sh
    menu
fi

if [ "$option" = 2 ]; then
    bash Basic1/ssh,ftp,etc.sh
    menu
fi

if [ "$option" = 3 ]; then
    bash Basic2/ClamTK,etc.sh
    menu
fi

if [ "$option" = 4 ]; then
    bash Basic3/OpenVAS.sh
    menu
fi

if [ "$option" = 5 ]; then
    cp /etc/passwd .
    echo "Passwd File Extracted"
    menu
fi

if [ "$option" = 6 ]; then
    ls /bin >> commands_apps
    menu
fi

if [ "$option" = 7 ]; then
    echo "what would you like to delete"
    read delete
    apt remove "$delete"
    snap remove "$delete"
    echo "you can check if that worked"
    sleep 3
    clear
    menu
fi

if [ "$option" = 8 ]; then
    bash Accounts/Accounts.sh
    bash Basic1/ssh,ftp,etc.sh
    bash Basic2/ClamTK,etc.sh
    bash Basic3/OpenVAS.sh
    menu
fi
