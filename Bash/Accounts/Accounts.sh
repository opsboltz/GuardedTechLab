#!/bin/bash

# Function to generate a complex and challenging password
generate_password() {
  # Define character sets
  lowercase="abcdefghijklmnopqrstuvwxyz"
  uppercase="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  numbers="0123456789"
  special_chars="!@#$%^&*()-_=+[]{}|;:'\",.<>/?"
  all_chars="${lowercase}${uppercase}${numbers}${special_chars}"
  
  # Generate a password of 16 characters with at least one character from each set
  while true; do
    password=$(head /dev/urandom | tr -dc "$all_chars" | head -c16)
    if [[ "$password" =~ [A-Z] && "$password" =~ [a-z] && "$password" =~ [0-9] && "$password" =~ [$special_chars] ]]; then
      echo "$password"
      break
    fi
  done
}

# Function to log password changes
log_password_change() {
  echo "$1:$2" >> password_changes.txt
}

# Function to log account deletions
log_account_deletion() {
  echo "$1" >> account_deletions.txt
}

# Function to display the main menu
main_menu() {
  echo "Main Menu:"
  echo "1. Change Password"
  echo "2. Delete Account"
  echo "3. Exit"
}

while true; do
  main_menu
  read -p "Choose an option (1/2/3): " option

  case $option in
    1) # Change Password
      # Initialize an array to store user information
      user_list=()

      # Read the /etc/passwd file to gather user data
      while IFS=: read -r username _ uid gid gecos home shell; do
        # Get the user's primary group
        primary_group=$(id -gn "$username")

        # Append the user information to the array
        user_list+=("$username: primary group: $primary_group")
      done < /etc/passwd

      # Display the list of users with their primary groups
      echo "Users and their primary groups on the system:"
      for ((i = 0; i < ${#user_list[@]}; i++)); do
        echo "($i) ${user_list[i]}"
      done

      # Prompt for user input to select a user by number
      read -p "Enter the number of the user you want to modify or delete: " user_number

      # Get the selected user from the array
      selected_user="${user_list[user_number]}"

      # Ensure a valid user was selected
      if [ -z "$selected_user" ]; then
        echo "Invalid user number. Returning to the main menu."
        continue
      fi

      # Display the selected user's information
      echo "Selected user: $selected_user"

      # Generate a complex and challenging password
      new_password=$(generate_password)

      # Change Password
      echo "New Password for $selected_user: $new_password"
      echo "$selected_user:$new_password" | sudo chpasswd
      log_password_change "$selected_user" "$new_password"
      echo "Password changed successfully."
      ;;
    2) # Delete Account
      # Initialize an array to store user information
      user_list=()

      # Read the /etc/passwd file to gather user data
      while IFS=: read -r username _ uid gid gecos home shell; do
        # Get the user's primary group
        primary_group=$(id -gn "$username")

        # Append the user information to the array
        user_list+=("$username: primary group: $primary_group")
      done < /etc/passwd

      # Display the list of users with their primary groups
      echo "Users and their primary groups on the system:"
      for ((i = 0; i < ${#user_list[@]}; i++)); do
        echo "($i) ${user_list[i]}"
      done

      # Prompt for user input to select a user by number
      read -p "Enter the number of the user you want to modify or delete: " user_number

      # Get the selected user from the array
      selected_user="${user_list[user_number]}"

      # Ensure a valid user was selected
      if [ -z "$selected_user" ]; then
        echo "Invalid user number. Returning to the main menu."
        continue
      fi

      # Display the selected user's information
      echo "Selected user: $selected_user"

      # Delete Account
      sudo userdel -r "$selected_user"
      log_account_deletion "$selected_user"
      echo "Account $selected_user deleted."
      ;;
    3) # Exit
      echo "Exiting the script."
      exit 0
      ;;
    *)
      echo "Invalid option. Please choose 1, 2, or 3."
      ;;
  esac
done
