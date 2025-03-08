#!/bin/bash

CONFIG_FILE="/etc/ufw/before.rules"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "File $CONFIG_FILE not found."
  exit 1
fi

cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
echo "Backup created: ${CONFIG_FILE}.bak"

sed -i '/# ok icmp codes for INPUT/,/# ok icmp code for FORWARD/ {
  s/-j ACCEPT/-j DROP/
  s/--icmp-type parameter-problem -j AfCCEPT/--icmp-type parameter-problem -j DROP/
}' "$CONFIG_FILE"

if ! grep -q "source-quench" "$CONFIG_FILE"; then
  sed -i '/# ok icmp codes for INPUT/a -A ufw-before-input -p icmp --icmp-type source-quench -j DROP' "$CONFIG_FILE"
fi

ufw disable && ufw enable

cat "$CONFIG_FILE"
