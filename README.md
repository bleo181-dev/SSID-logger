# SSID-logger

**Wi-Fi SSID Logger**

Script that continuously scans the Wi-Fi in its radius and saves the unique SSIDs encountered in a text file.

**installation**

```
sudo apt update
sudo apt install iw
git clone https://github.com/bleo181-dev/SSID-logger.git
```

after that

```
crontab -e
```

and add at the bottom of the crontab file this (change the path to suit your case)

```
@reboot /bin/bash /path/to/wifi_log.sh
```
