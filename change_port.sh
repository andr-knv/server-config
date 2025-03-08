#!/bin/bash

read -p "Enter a new port for SSH: " new_port

if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
  echo "Error: The port must be a number between 1 and 65535."
  exit 1
fi


sed -i "s/^#Port .*/Port $new_port/" /etc/ssh/sshd_config
if ! grep -q "^Port $new_port" /etc/ssh/sshd_config; then
  echo "Port $new_port" >> /etc/ssh/sshd_config
fi

systemctl daemon-reload && systemctl restart sshd

if systemctl is-active --quiet sshd; then
  echo "SSH port successfully changed to $new_port."
else
  echo "Error: SSH service is not running. Check the configuration."
  exit 1
fi


if command -v ufw &> /dev/null; then
  ufw enable && ufw allow "$new_port"/tcp
  echo "Port $new_port UFW rule added."
fi

echo "The configuration is complete. SSH is now available on port $new_port."