#!/bin/bash

# Add cronjob for running wifi_log.sh on reboot
(crontab -l ; echo "@reboot /bin/bash $(pwd)/wifi_log.sh") | crontab -

# Check if Apache is installed
if ! command -v apache2 &> /dev/null
then
    # Install Apache
    sudo apt-get update
    sudo apt-get install apache2
fi

# Give write permissions to all for /var/www/html
sudo chmod -R o+w /var/www/html

# Copy view_log_file.php to /var/www/html
sudo cp $(pwd)/view_log_file.php /var/www/html

echo "Setup completed successfully!"
