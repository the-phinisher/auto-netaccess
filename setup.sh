#!/bin/bash

node -v > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Node.js is not installed."
    exit 1
fi

npm -v > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "NPM is not installed."
    exit 1
fi

npm install > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "NPM install failed."
    echo "Check your internet connection."
    exit 1
fi


URL="https://netaccess.iitm.ac.in/account/login"
STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" $URL)

# Check if the status code indicates success (200 OK)
if [ ! $STATUS_CODE -eq 200 ]; then
    echo "Netacess not reachable, check if you are connected to the IITM network."
    exit 1
fi

GEN_ENV_FILE=1

if [ -f ".env" ]; then
    read -p ".env already exists. Do you want to overwrite the credentials? (y/n) " ANSWER
    if [ "$ANSWER" == "n" ] || [ "$ANSWER" == "N" ]; then
        GEN_ENV_FILE=0
    fi
fi

if [[ "$GEN_ENV_FILE" == "1" ]]; then
    echo
    echo "LDAP data stays on your system, stored in the .env file."
    echo "No validation for roll numbers present, if any errors exist, edit the .env file,"
    echo "or delete the .env file and re-run this setup script."
    echo
    read -p "Enter your roll number: " ROLLNO
    read -sp "Enter your password: " PASSWD
    echo

    if [ -f ".env" ]; then
        mv .env .env.bak
        echo "Old .env file moved to .env.bak"
    fi

    if [[ "$ROLLNO" != *\"* ]] && [[ "$PASSWORD" != *\"* ]]; then
        echo "ROLLNO=\"$ROLLNO\"" > .env
        echo "PASSWD=\"$PASSWD\"" >> .env
    else
        echo "ROLLNO='$ROLLNO'" > .env
        echo "PASSWD='$PASSWD'" >> .env
    fi
fi

echo
echo "Checking credentials and running tests..."
echo

node $(pwd)/index.js

if [ ! $? -eq 0 ]; then
    rm -rf .env
    echo "Invalid credentials. Removed .env file. Re-run setup.sh to try again."
    exit $?
fi

NODEJS_PATH=$(which node)
NEW_CRON_JOB_COMMAND="cd $(pwd) && $NODEJS_PATH $(pwd)/index.js"

crontab -l | grep -F "$NEW_CRON_JOB_COMMAND" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Cron job already exists."
    read -p "Do you want to replace it? (y/n) " ANSWER
    if [[ "$ANSWER" == "n" ]] || [[ "$ANSWER" == "N" ]]; then
        echo "Cron job not replaced."
        exit
    fi
fi

DEFAULT_CRON_SCHEDULE="$((RANDOM % 60)) $((RANDOM % 6 + 10)) * * *"

echo
echo "Default cron schedule is set to randomized minute and hour between 10 am to 4 pm"
echo
echo "Note: cron job will not execute if system not active during the specified time."
echo
read -p "Enter cron schedule (default: $DEFAULT_CRON_SCHEDULE): " CRON_SCHEDULE

if [ -z "$CRON_SCHEDULE" ]; then
    CRON_SCHEDULE=$DEFAULT_CRON_SCHEDULE
fi

NEW_CRON_JOB="$CRON_SCHEDULE $NEW_CRON_JOB_COMMAND"

echo "cron job added as:"
echo -e "\t$NEW_CRON_JOB"

echo "Permission might be required to add the cron job."

OTHER_CRON_JOBS=$(crontab -l | grep -v "$NEW_CRON_JOB_COMMAND")
(echo "$OTHER_CRON_JOBS"; echo "$NEW_CRON_JOB") | crontab -

echo "Cron job added successfully."
echo "Current crontab:"
crontab -l

echo
echo "Re-run the setup.sh to update any configuration."
