#!/bin/bash

# Function to run the Pam_config.sh script
run_pam_config_script() {
    # Specify the path to Pam_config.sh
    pam_config_script="/home/ubuntu/Desktop/GuardedTechLab-bash/Bash/Accounts/Pam_config.sh"

    # Check if the script exists before running
    if [ -f "$pam_config_script" ]; then
        # Run Pam_config.sh script
        source "$pam_config_script"
        echo "Executed Pam_config.sh script"
    else
        echo "Error: Pam_config.sh script not found at $pam_config_script"
    fi
}

# Function to delete suspicious users
delete_suspicious_users() {
    # Get a list of all users
    all_users=($(getent passwd | cut -d: -f1))

    # Authorized and unauthorized users from user input
    IFS=',' read -ra authUsersArray <<< "$Authusers"
    IFS=',' read -ra unauthUsersArray <<< "$UnauthedUsers"

    # Combine authorized and unauthorized users
    all_auth_unauth_users=("${authUsersArray[@]}" "${unauthUsersArray[@]}")

    # Loop through all users and delete suspicious ones
    for user in "${all_users[@]}"; do
        # Check if the user is not in the authorized or unauthorized list
        if [[ ! " ${all_auth_unauth_users[@]} " =~ " $user " ]]; then
            # Check if the user's name is common (modify as needed)
            if [[ "$user" =~ ^(john|mary|jane)$ ]]; then
                # Add any additional criteria to identify suspicious users
                # For now, just print a message (replace with deletion logic)
                echo "Deleting suspicious user: $user"
                # Uncomment the following line to delete the user (be cautious!)
                # sudo deluser "$user" --remove-home
            fi
        fi
    done
}

echo "Welcome"
sleep 1

echo "Separate account names with commas in questions"
sleep 5
clear

echo "What are all the authorized users (comma-separated)"
read Authusers

echo "What are all the unauthorized users (comma-separated)"
read UnauthedUsers

# Convert the comma-separated lists into arrays
IFS=',' read -ra authUsersArray <<< "$Authusers"
IFS=',' read -ra unauthUsersArray <<< "$UnauthedUsers"

# Loop through the array of authorized users and make them root
for authUser in "${authUsersArray[@]}"; do
    # Add your command to make authUser root here
    usermod -aG sudo "$authUser"
    echo "Making $authUser a root user"
    
    # Change the password for authUser
    new_password="password"
    echo "$authUser:$new_password" | chpasswd
    echo "Changing password for $authUser"
done

# Loop through the array of unauthorized users and revoke root access
for unauthUser in "${unauthUsersArray[@]}"; do
    # Add your command to revoke root access from unauthUser here
    deluser "$unauthUser" sudo
    echo "Revoking root access from $unauthUser"
    
    # Change the password for unauthUser
    new_password="password"
    echo "$unauthUser:$new_password" | chpasswd
    echo "Changing password for $unauthUser"
done

# Run the Pam_config.sh script
run_pam_config_script

# Delete suspicious users
delete_suspicious_users

