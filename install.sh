#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'

PAM_CONFIG="session optional pam_exec.so seteuid /root/discord.sh"

if [ -z $SUDO_USER ]; then
  echo -e "🧨 ${RED}Must be run using sudo!${NC}"
  exit 1
fi

if [ -f .env ]; then
  source ./.env
else
  echo "Enter your Discord Webhook URL (https://discord.com/api/webhooks/...):"
  read WEBHOOK_URL
fi

if [ -z $WEBHOOK_URL ]; then
  echo -e "🧨 ${RED}No URL specified!${NC}"
  exit 1
fi

echo -e "🍉 ${ORANGE}Installing SSH tattletale...${NC}"
echo "WEBHOOK_URL=\"$WEBHOOK_URL\"" > .env && chmod 600 .env
echo "WEBHOOK_URL=\"$WEBHOOK_URL\"" > /root/discord.env && chmod 600 /root/discord.env

cp discord.sh /root/discord.sh
chmod 700 /root/discord.sh

grep -qxF "$PAM_CONFIG" /etc/pam.d/sshd || echo $PAM_CONFIG >> /etc/pam.d/sshd

echo -e "🎉 ${GREEN}Done! Test it out by doing a quick 'ssh localhost'!${NC}"