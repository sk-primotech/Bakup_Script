#!/bin/bash

# Set the current timestamp
NOW=$(date +"%m-%d-%Y-%H-%M")

# Define the backup directory
BACKUP_DIR="/home/script/Daily-Bck"

# Change to the backup directory and clear all old backups
cd /home/script/
if [ -d "$BACKUP_DIR" ]; then
    rm -rf $BACKUP_DIR/*
else
    mkdir -p $BACKUP_DIR
fi

# Create a new backup directory
cd $BACKUP_DIR
mkdir $NOW
cd $NOW
pwd
echo "############### $NOW Directory Created DataBase Backup Started ####################"

# Database backup
mysqldump -u dogexpress '-pP@ssssw0rd' dogexpress | gzip -9 > dogexpress.sql.gz

# Create a zip file of the /var/www/html/public_html directory
zip -r public_html_backup_$NOW.zip /var/www/html/public_html/

# Get the current hour
H=$(date +%H)
echo $H

# Check the time and upload backups to S3
if (( $H >= 00 && $H <= 20 )); then
    echo "between 01:00AM and 10:00AM"
    currenttime=$(date +"%T")  # Assign the current time to currenttime
    echo "Current time: $currenttime"
    aws s3 cp --recursive $NOW s3://dogexpress-backups/production/$NOW/
else
    echo "other time"
    currenttime=$(date +"%T")  # Assign the current time to currenttime
    echo "Current time: $currenttime"
fi

# Upload the public_html backup zip file to S3
aws s3 cp $BACKUP_DIR/$NOW/public_html_backup_$NOW.zip s3://dogexpress-backups/production/$NOW/
