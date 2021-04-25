#!/bin/bash

if [ -f /root/discord.env ]; then
  source /root/discord.env
fi

if [ -z $WEBHOOK_URL ]; then
  echo "No URL specified!"
  exit 1
fi

user=$PAM_USER
ip=$PAM_RHOST

# Stores environment in a JSON-formatted var
env=`printenv | awk '
BEGIN { printf "\"Environment: " }
{sub(/\x22/,"\x5C\x22")}1
END {  printf "\"" }' ORS='\\\\n'`

WEBHOOK_DATA=$(cat << EOF
{
  "content": null,
  "username": "Tattletail",
  "avatar_url": "https://raw.githubusercontent.com/aliask/tattletale/main/tattletail.png",
  "embeds": [
    {
      "title": "New SSH login on $HOSTNAME",
      "color": 5814783,
      "fields": [
        {
          "name": "Username",
          "value": "👤 $user",
          "inline": true
        },
        {
          "name": "From",
          "value": "🌎 $ip",
          "inline": true
        }
      ],
      "footer": {
          "text": $env
      }
    }
  ]
}
EOF
)

if [ "$PAM_TYPE" != "close_session" ]; then
  echo "$WEBHOOK_DATA" > /tmp/testfile
  curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "@/tmp/testfile" "$WEBHOOK_URL"
  rm /tmp/testfile
fi
