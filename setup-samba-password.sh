#!/usr/bin/env bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

echo "Setting Samba password for user 'alek'..."
echo "You will be prompted to enter the new password."

smbpasswd -a alek

if [ $? -eq 0 ]; then
  echo "Samba password set successfully."
else
  echo "Failed to set Samba password."
fi
