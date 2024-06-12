#!/bin/bash

# URL to download the updated script
DOWNLOAD_URL="https://gptcmd.sh/gptcmd.sh"
INSTALL_PATH="/usr/local/bin"
SCRIPT_FILE="gptcmd"

# Function to display error messages
error_message() {
    echo -e "\033[1;31m$1\033[0m"
    exit 1
}

# Function to display success messages
success_message() {
    echo -e "\033[1;32m$1\033[0m"
}

# Check the presence of curl
echo "Checking for required dependency (curl)..."
if ! command -v curl >/dev/null 2>&1; then
    error_message "curl is not installed. Please install it before continuing."
fi

# Download the updated script
echo "Downloading the updated script from $DOWNLOAD_URL..."
TEMP_FILE=$(mktemp) || error_message "Unable to create a temporary file."
curl -s -L -o "$TEMP_FILE" "$DOWNLOAD_URL" || error_message "Failed to download the script."

# Check if the downloaded script is valid
if ! grep -q "#!/bin/bash" "$TEMP_FILE"; then
    rm -f "$TEMP_FILE"
    error_message "The downloaded script does not appear to be valid."
fi

# Replace the existing script with the downloaded one
echo "Updating $SCRIPT_FILE in $INSTALL_PATH..."
sudo mv "$TEMP_FILE" "$INSTALL_PATH/$SCRIPT_FILE" || error_message "Failed to move the script to $INSTALL_PATH."
sudo chmod +x "$INSTALL_PATH/$SCRIPT_FILE" || error_message "Failed to make $SCRIPT_FILE executable in $INSTALL_PATH."

success_message "Update completed successfully."
