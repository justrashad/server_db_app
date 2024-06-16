#!/bin/bash

# Define color codes
GREEN_TEXT="\033[0;32m"
RESET_TEXT="\033[0m"
RED_TEXT="\033[0;31m"

# Define log file
LOG_FILE="backup.log"

# Define backup directory
BACKUP_DIR="backup"
MONGO_BACKUP_DIR="$BACKUP_DIR/mongo"
APP_BACKUP_DIR="$BACKUP_DIR/app"

# Function to print debug messages in green
debug_message() {
    echo -e "${GREEN_TEXT}$1${RESET_TEXT}" | tee -a $LOG_FILE
}

# Function to print error messages in red
error_message() {
    echo -e "${RED_TEXT}$1${RESET_TEXT}" | tee -a $LOG_FILE
}

# Function to check the last command status and exit if it failed
check_command_status() {
    if [ $? -ne 0 ]; then
        error_message "Error: $1 failed. Exiting."
        exit 1
    fi
}

# Function to backup MongoDB data
backup_mongo() {
    debug_message "Backing up MongoDB data..."

    mkdir -p $MONGO_BACKUP_DIR

    mongodump --out $MONGO_BACKUP_DIR | tee -a $LOG_FILE
    check_command_status "Backing up MongoDB data"

    debug_message "MongoDB data backup completed."
}

# Function to backup application files
backup_app_files() {
    debug_message "Backing up application files..."

    mkdir -p $APP_BACKUP_DIR

    cp -r server-management-app $APP_BACKUP_DIR | tee -a $LOG_FILE
    check_command_status "Backing up application files"

    debug_message "Application files backup completed."
}

# Main script execution
backup_mongo
backup_app_files

debug_message "Backup completed successfully."
