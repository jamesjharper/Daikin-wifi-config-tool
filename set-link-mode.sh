#!/bin/bash
set -e

# Args
DEVICE_NAME=""
DRY_RUN=false
REBOOT=true
LINK_MODE="" # 0: pairing mode, wont connect to wifi, 1: will connect to wifi

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    --skip-reboot)
      REBOOT=false
      ;;
    --set-pairing-mode)
      LINK_MODE=0
      ;;
    --set-wifi-mode)
      LINK_MODE=1
      ;;      
    *)
      DEVICE_NAME="$arg"
      ;;
  esac
done

if [ -z "$LINK_MODE" ]; then
  echo "Required Parameters missing: --set-pairing-mode / --set-wifi-mode"
  echo
  echo "Options:"
  echo "Usage: $0 [--dry-run] [--skip-reboot] [--set-pairing-mode|--set-wifi-mode] <device_name>"
  echo "Example: $0 --set-wifi-mode LivingRoom"
  exit 1
fi

# Load device configuration 
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
if [ "$DRY_RUN" = false ]; then
  curl -k -H "X-Daikin-uuid: $UUID" \
    "https://$DAIKIN_IP/common/register_terminal?key=$DEVICE_KEY"
else 
  echo "  [GET] https://$DAIKIN_IP/common/register_terminal?key=$DEVICE_KEY"
  echo "  Header: X-Daikin-uuid: $UUID" 
fi

echo
echo "Setting Link mode ..."

if [ "$DRY_RUN" = false ]; then
  curl -k -H "X-Daikin-uuid: $UUID" \
    "https://$DAIKIN_IP/common/set_wifi_setting?link=$LINK_MODE"
else 
  echo "  [GET] https://$DAIKIN_IP/common/set_wifi_setting?link=$LINK_MODE"
  echo "  Header: X-Daikin-uuid: $UUID" 
fi

if [ "$REBOOT" = true ]; then
  echo
  echo "Rebooting Daikin unit..."
  if [ "$DRY_RUN" = false ]; then
     curl -k -H "X-Daikin-uuid: $UUID" "https://$DAIKIN_IP/common/reboot"
  else
    echo "  [GET] https://$DAIKIN_IP/common/reboot"
    echo "  Header: X-Daikin-uuid: $UUID"
  fi
fi

