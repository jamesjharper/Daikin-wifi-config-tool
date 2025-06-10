#!/bin/bash
set -e


# Load device configuration 
DEVICE_NAME="$1"
DEVICE_FILE=""

if [[ -n "$DEVICE_NAME" ]]; then
  DEVICE_FILE="devices/$DEVICE_NAME.env"
  if [[ ! -f "$DEVICE_FILE" ]]; then
    echo "Could not setting file $DEVICE_FILE"
    exit 1
  fi
else 
  echo "Enter the number of the device you want to configure:"
  select DEVICE_FILE in devices/*.env; do
    if [[ -f "$DEVICE_FILE" ]]; then
      source "$DEVICE_FILE"
      break
    else
      echo "Invalid selection. Please choose a valid file."
      exit 1
    fi
  done
fi

source "$DEVICE_FILE"

# Script settings
UUID="d53b108a0e5e4fb5ab94a343b7d4b74a" 

echo
echo "Target Device:"
echo "  Device Key: $DEVICE_KEY"
echo "  Daikin IP:  $DAIKIN_IP"
echo "  UUID:       $UUID"

echo
echo "Starting session..."
curl -k -H "X-Daikin-uuid: $UUID" \
  "https://$DAIKIN_IP/common/register_terminal?key=$DEVICE_KEY"

echo
echo
echo "Fetching WiFi settings ..."

RESPONSE=$(curl -ks -H "X-Daikin-uuid: $UUID" \
  "https://$DAIKIN_IP/common/get_wifi_setting")

# Parse response
eval $(echo "$RESPONSE" | tr ',' '\n' | sed -E 's/^([a-zA-Z_]+)=(.*)$/\1="\2"/')

# Decode WiFi key
DECODED_KEY=$(printf '%b' "${key//%/\\x}")

echo
echo "Current WiFi Settings:"
echo "  SSID      : $ssid"
echo "  WiFi Key  : $DECODED_KEY"
echo "  Security  : $security"
echo "  Link Mode : $link"
