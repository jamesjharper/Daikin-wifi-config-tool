# Daikin WiFi Configuration Scripts

This repository contains Bash scripts for configuring and managing WiFi settings on Daikin air conditioners via their local HTTP API.

This scripts are necessary due to breaking changes to Daikin's configuration app preventing older wifi enabled units to be configured. 

## Scripts Overview

### `config-wifi.sh`
Sets the SSID and password for a Daikin unit and optionally reboots the device.

#### Usage

```bash
./config-wifi.sh [options] <device_name>
```

#### Options
- `--dry-run`	         - Print actions without making any API requests
- `--skip-reboot`	     - Skip rebooting the unit after config is applied
- `--set-pairing-mode` - Set link mode to 0 (pairing mode; no WiFi join)
- `--set-wifi-mode`	 - Set link mode to 1 (normal operation with WiFi)

### `dump-wifi.sh`
Fetches and displays the current WiFi settings from the unit (SSID, encoded password, link mode).

#### Usage
```bash
./dump-wifi.sh <device_name>
```

### `set-link-mode.sh`
Sets the unit’s link mode (whether it should attempt to join WiFi or stay in pairing mode) and optionally reboots.

```bash
./set-link-mode.sh [options] <device_name>
```

#### Options
- `--dry-run`	         - Print actions without making any API requests
- `--skip-reboot`      - Skip rebooting the device
- `--set-pairing-mode` - Set link mode to 0 (will not join WiFi)
- `--set-wifi-mode`    - Set link mode to 1 (attempts WiFi connection)

## Environment Files
### `wifi.env`
Holds shared WiFi settings:

```ini
SSID=YourWiFiName
WIFI_KEY=YourSecretPassword
```

### `devices/<device_name>.env`
Each file represents a Daikin unit. Example:

```ini
DEVICE_KEY=0000000000000 # Change to device ID found on the wifi module of device
DAIKIN_IP=192.168.1.1    # Change to IP address of device. When in pairing mode it should be 192.168.1.
```

## Dependencies
These scripts use:

- `bash`
- `curl`