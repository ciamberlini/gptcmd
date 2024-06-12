#!/bin/bash

# Name of the script and config files
SCRIPT_NAME="gptcmd"
CONFIG_FILE_NAME="gptcmd.conf"
INSTALL_PATH="/usr/local/bin/$SCRIPT_NAME"
GLOBAL_CONFIG_FILE="/etc/$CONFIG_FILE_NAME"
USER_CONFIG_DIR="$HOME/.gptcmd"
USER_CONFIG_FILE="$USER_CONFIG_DIR/$CONFIG_FILE_NAME"

# Function to print colored messages
print_message() {
    local message="$1"
    local color="$2"
    echo -e "\033[${color}m${message}\033[0m"
}

# Function to remove the main script
remove_script() {
    if [ -f "$INSTALL_PATH" ]; then
        print_message "Removing $INSTALL_PATH..." "1;32"
        sudo rm -f "$INSTALL_PATH"
    else
        print_message "$INSTALL_PATH not found. Skipping removal of script." "1;33"
    fi
}

# Function to remove the global configuration file
remove_global_config() {
    if [ -f "$GLOBAL_CONFIG_FILE" ]; then
        print_message "Removing $GLOBAL_CONFIG_FILE..." "1;32"
        sudo rm -f "$GLOBAL_CONFIG_FILE"
    else
        print_message "$GLOBAL_CONFIG_FILE not found. Skipping removal of global configuration file." "1;33"
    fi
}

# Function to remove the user configuration file
remove_user_config() {
    if [ -f "$USER_CONFIG_FILE" ]; then
        print_message "Removing $USER_CONFIG_FILE..." "1;32"
        rm -f "$USER_CONFIG_FILE"
    else
        print_message "$USER_CONFIG_FILE not found. Skipping removal of user configuration file." "1;33"
    fi

    # Remove the user configuration directory if empty
    if [ -d "$USER_CONFIG_DIR" ] && [ ! "$(ls -A "$USER_CONFIG_DIR")" ]; then
        print_message "Removing empty directory $USER_CONFIG_DIR..." "1;32"
        rmdir "$USER_CONFIG_DIR"
    fi
}

# Main function to perform uninstallation
uninstall() {
    print_message "Starting uninstallation of $SCRIPT_NAME..." "1;34"

    remove_script
    remove_global_config
    remove_user_config

    print_message "Uninstallation complete." "1;32"
}

# Execute the uninstallation process
uninstall
