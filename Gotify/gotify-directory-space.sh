#!/bin/bash

# Disk parameters
PART=/path/to/disk

# Gotify parameters
GOTIFY_URL="https://push.domain.com"
GOTIFY_TOKEN="12345"

# Tag to see in log file
LOGGER_TITLE="directory-space-home"

# Configuration file
FILE_CONF="$PART/gotify-notify.conf"

# Handling configuration file (if present)
if [[ -f "${FILE_CONF}" ]]; then
  GOTIFY_URL=$(grep "server-url=" $FILE_CONF | cut -d'=' -f2)
  GOTIFY_TOKEN=$(grep "access-token=" $FILE_CONF | cut -d'=' -f2)
fi

# Server info
server_name=$(uname -n)
release=$(lsb_release -d | cut -d$'\t' -f2)
USE=$(sudo du -shx -- $PART/* | sort -h | tail)
USE_TOTAL=$(sudo du -shx -- $PART | sort -h | tail)

# Processing notification content
## Title
title="SSD - $server_name ($release)"

## Message
message1="Total Used: $USE_TOTAL"
message2="Used: $USE"
message="$message1 $message2"


# Logging to file .log
/bin/echo "`date`:" >> "$PART/gotify-directory-space.log"
/bin/echo "TOTAL: $USE_TOTAL" >> "$PART/gotify-directory-space.log"
/bin/echo "DETAIL: $USE" >> "$PART/gotify-directory-space.log"

# Finally cURLing !
curl_http_result=$(curl "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}" -F "title=${title}" -F "message=${message}" -F "priority=5" --output /dev/null --silent --write-out %{http_code})

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

