#!/usr/bin/env bash

#### this script will list users and detect user without password

set -euo pipefail

#### The funtion lists users with a password except the root user.
#users_list () {
#  awk -F: '{ $2 != "" && $3 != 0 { printf "%-25s | %s\n", $1, $3 } }' /etc/passwd
#}

#### The function lists system users (Service Accounts). ####
system_users () {
  grep -E '(/sbin/nologin|/bin/false)' /etc/passwd | awk -F: '{ printf "%-25s | %s\n", $1, $3 }'
}

####  The function lists standard users (UID >= 1000). ####
standard_users () {
  awk -F: '$3 >= 1000 && $3 < 65534 { printf "%-25s | %s\n", $1, $3 }' /etc/passwd
}

#### The function lists users without a password. ####
users_without_password () {
  awk -F: '($2 == "") { printf "%-25s | %s\n", $1, $3 }' /etc/passwd
}

#### Users display function ####
display_users () {
  echo -e "\n--- System Users (Service Accounts) ---"
  if ! system_users | grep -q .; then
    echo "No system users found."
  else
    system_users
  fi

  echo -e "\n--- Standard Users (UID >= 1000) ---"
  if ! standard_users | grep -q .; then
    echo "No standard users found."
  else
    standard_users
  fi

  echo -e "\n--- Users without Password ---"
  if ! users_without_password | grep -q .; then
    echo "No users without password found."
  else
    users_without_password
  fi
}

display_users