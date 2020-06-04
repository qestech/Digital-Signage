#!/bin/bash

# Print some ASCII art
clear
echo "  ____    ____ ____"
echo " / __ \  / __// __/"
echo "/ /_/ / / _/ _\ \  "
echo "\___\_\/___//___/  "
echo "QES Digital Signage"
echo

#######################
# Run package updates #
#######################
echo "Installing required packages..."
sudo apt update -q -y
sudo apt upgrade -q -y

if ! dpkg -l unclutter >/dev/null; then
        sudo apt install unclutter -q -y
else
        echo -e "unclutter already installed!\n"
fi

if ! dpkg -l xscreensaver >/dev/null; then
        sudo apt install xscreensaver -q -y
else
        echo -e "xscreensaver already installed!\n"
fi

# Clean up after ourselves
sudo apt autoremove -y
echo "Done!"

###########################
# Disable screen blanking #
###########################
if ! test -f ~/.xscreensaver; then
        echo "No xscreensaver config, creating..."
        cp .xscreensaver ~/.xscreensaver
        echo "Done!"
fi


####################
# Set up cron jobs #
####################
if crontab -l | grep -q 'Kiosk Mode'; then
        echo -e "Cron jobs already exist!\n"
else
        echo "Creating cron jobs..."
        crontab -l -u pi | cat - displayOnOff | crontab -u pi -
        echo "Done!"
fi


###############
# Copy script #
###############
echo "Updating kiosk script..."

# Ensure scripts are executable
if ! test -x kiosk.sh; then
        echo "kiosk.sh not executable, updating..."
        chmod +x kiosk.sh
        echo "Execute permission set!"
fi

cp kiosk.sh /home/pi
echo -e "Done!\n"

##########################
# Enable systemd Service #
##########################
if test -f /lib/systemd/system/kiosk.service; then
        echo "Kiosk service already exists, restarting..."
        sudo systemctl stop kiosk
        sudo systemctl start kiosk
        echo -e "Done!\n"
else
        echo "Creating systemd service for kiosk mode..."
        chmod 664 kiosk.service
        sudo cp kiosk.service /lib/systemd/system
        sudo systemctl daemon-reload
        sudo systemctl enable kiosk
        echo "Starting kiosk mode..."
        sudo systemctl start kiosk
        echo -e "Done!\n"
fi

echo "Install finished."
exit 0