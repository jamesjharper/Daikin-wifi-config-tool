#!/bin/bash
set -e

# ==== PARSE ARGUMENTS ====
DRY_RUN=false
REBOOT=true
DUMP_WIFI=false
LINK_MODE="1" # 0: pairing mode, wont connect to wifi, 1: will connect to wifi

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

# Load device configuration 
DEVICE_FILE=""

if [[ -n "$DEVICE_NAME" ]]; then
  DEVICE_FILE="devices/$DEVICE_NAME.env"
  if [[ ! -f "$DEVICE_FILE" ]]; then
    echo "Missing device settings file: $DEVICE_FILE"
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

# Load wifi configuration
WIFI_SETTINGS_FILE="wifi.env"
if [[ ! -f "$WIFI_SETTINGS_FILE" ]]; then
  echo "Missing WiFi settings file: $WIFI_SETTINGS_FILE"
  exit 1
fi

source "$WIFI_SETTINGS_FILE"

# Load script settings
UUID="d53b108a0e5e4fb5ab94a343b7d4b74a" 

echo
echo "Configuration:"
echo "  Device Key: $DEVICE_KEY"
echo "  Daikin IP:  $DAIKIN_IP"
echo "  UUID:       $UUID"
echo "  SSID:       $SSID"
echo "  WiFi Key:   $WIFI_KEY"
echo "  Link Mode:  $LINK_MODE"
echo "  Reboot:     $REBOOT"
echo "  Dry Run:    $DRY_RUN"

encode_password() {
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    printf '%%%02X' "'$c"
  done
}

echo
echo "Starting session..."
if [ "$DRY_RUN" = false ]; then
  curl -k -H "X-Daikin-uuid: $UUID" \
    "https://$DAIKIN_IP/common/register_terminal?key=$DEVICE_KEY" -w "\nResponse Code: %{http_code}\n"
else
  echo "  [GET] https://$DAIKIN_IP/common/register_terminal?key=$DEVICE_KEY"
  echo "  Header: X-Daikin-uuid: $UUID"
fi

ENCODED_KEY=$(encode_password "$WIFI_KEY")
echo
echo "Setting WiFi SSID and key ..."

if [ "$DRY_RUN" = false ]; then
  curl -k -H "X-Daikin-uuid: $UUID" \
    "https://$DAIKIN_IP/common/set_wifi_setting?ssid=$SSID&key=$ENCODED_KEY&security=mixed&link=$LINK_MODE"
else
  echo "  [GET] https://$DAIKIN_IP/common/set_wifi_setting?ssid=$SSID&key=$ENCODED_KEY&security=mixed&link=$LINK_MODE"
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

