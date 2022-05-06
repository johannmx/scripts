#!/bin/bash

# Disk parameters
MAX=80
PART=sda1

# Gotify parameters
GOTIFY_URL="https://push.domain.com"
GOTIFY_TOKEN="123456abcd"

# Tag to see in log file
LOGGER_TITLE="disk-space-home"

# Configuration file
FILE_CONF="/etc/gotify-notify.conf"

# Server info
server_name=$(uname -n)
release=$(lsb_release -d | cut -d$'\t' -f2)
USE=$(df -h | grep $PART | awk '{ print $5 }' | cut -d'%' -f1)

# Processing notification content
## Title
title="SSD - $server_name ($release)"

## Message
message="Percent used: $USE"


# Logging to file .log
/bin/echo "`date`:" >> /dir/log/gotify-disk-space.log
/bin/echo "Percent used: $USE" >> /dir/log/gotify-disk-space.log

# Finally cURLing !
if [ $USE -gt $MAX ]; then
	echo "Percent used: $USE" | curl_http_result=$(curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" -F "title=${title}" -F "message=${message}" -F "priority=5" --output /dev/null --silent --write-out %{http_code})
fi

if [[ $? -ne 0 ]]; then
  logger -t $LOGGER_TITLE "FATAL ERROR: cURL command failed !"
  exit 1
fi

# Check HTTP return code ("200" is OK)
if [[ $curl_http_result -ne 200 ]]; then
  logger -t $LOGGER_TITLE "FATAL ERROR: API call failed ! Return code is $curl_http_result instead of 200."
  exit 2
fi

logger -t $LOGGER_TITLE "Notification sent"

exit 0
