#!/bin/bash

generate_password() {
  lowercase="abcdefghijklmnopqrstuvwxyz"
  uppercase="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  numbers="0123456789"
  special_chars="!@#$%^&*()-_=+[]{}|;:'\",.<>/?"
  all_chars="${lowercase}${uppercase}${numbers}${special_chars}"
  
  while true; do
    password=$(head /dev/urandom | tr -dc "$all_chars" | head -c16)
    if [[ "$password" =~ [A-Z] && "$password" =~ [a-z] && "$password" =~ [0-9] && "$password" =~ [$special_chars] ]]; then
      echo "$password"
      break
    fi
  done
}

log_password_change() {
  echo "$1:$2" >> /path/to/password_changes.txt
}

log_account_deletion() {
  echo "$1" >> /path/to/account_deletions.txt
}

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
    1)
      user_list=()
      while IFS=: read -r username _ uid gid gecos home shell; do
        primary_group=$(id -gn "$username")
        user_list+=("$username: primary group: $primary_group")
      done < /etc/passwd

      echo "Users and their primary groups on the system:"
      for ((i = 0; i < ${#user_list[@]}; i++)); do
        echo "($i) ${user_list[i]}"
      done

      read -p "Enter the number of the user you want to modify or delete: " user_number
      selected_user="${user_list[user_number]}"

      if [ -z "$selected_user" ]; then
        echo "Invalid user number. Returning to the main menu."
        continue
      fi

      echo "Selected user: $selected_user"

      new_password=$(generate_password)

      echo "New Password for $selected_user: $new_password"
      echo "$selected_user:$new_password" | sudo chpasswd
      log_password_change "$selected_user" "$new_password"
      echo "Password changed successfully."
      ;;
    2)
      user_list=()
      while IFS=: read -r username _ uid gid gecos home shell; do
        primary_group=$(id -gn "$username")
        user_list+=("$username: primary group: $primary_group")
      done < /etc/passwd

      echo "Users and their primary groups on the system:"
      for ((i = 0; i < ${#user_list[@]}; i++)); do
        echo "($i) ${user_list[i]}"
      done

      read -p "Enter the number of the user you want to modify or delete: " user_number
      selected_user="${user_list[user_number]}"

      if [ -z "$selected_user" ]; then
        echo "Invalid user number. Returning to the main menu."
        continue
      fi

      echo "Selected user: $selected_user"

      sudo userdel -r "$selected_user"
      log_account_deletion "$selected_user"
      echo "Account $selected_user deleted."
      ;;
    3)
      echo "Exiting the script."
      exit 0
      ;;
    *)
      echo "Invalid option. Please choose 1, 2, or 3."
      ;;
  esac
done
