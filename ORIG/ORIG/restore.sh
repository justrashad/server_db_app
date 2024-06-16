#!/bin/bash

# Define color codes
GREEN_TEXT="\033[0;32m"
RESET_TEXT="\033[0m"
RED_TEXT="\033[0;31m"

# Define log file
LOG_FILE="restore.log"

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

# Function to restore MongoDB data
restore_mongo() {
    debug_message "Restoring MongoDB data..."

    mongorestore $MONGO_BACKUP_DIR | tee -a $LOG_FILE
    check_command_status "Restoring MongoDB data"

    debug_message "MongoDB data restore completed."
}

# Function to restore application files
restore_app_files() {
    debug_message "Restoring application files..."

    cp -r $APP_BACKUP_DIR/server-management-app . | tee -a $LOG_FILE
    check_command_status "Restoring application files"

    debug_message "Application files restore completed."
}

# Main script execution
restore_mongo
restore_app_files

debug_message "Restore completed successfully."
