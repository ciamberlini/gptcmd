#!/bin/bash

# Name of the script
SCRIPT_NAME="gptcmd"
CONFIG_FILE_NAME="gptcmd.conf"
INSTALL_PATH="/usr/local/bin"
CONFIG_PATH="/etc"

# Function to detect the package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PACKAGE_MANAGER="apt-get"
    elif command -v yum &> /dev/null; then
        PACKAGE_MANAGER="yum"
    elif command -v dnf &> /dev/null; then
        PACKAGE_MANAGER="dnf"
    elif command -v pacman &> /dev/null; then
        PACKAGE_MANAGER="pacman"
    elif command -v zypper &> /dev/null; then
        PACKAGE_MANAGER="zypper"
    else
        echo "Unsupported package manager. Install 'curl' and 'jq' manually."
        exit 1
    fi
}

# Function to install dependencies
install_dependencies() {
    echo "Installing dependencies..."
    case $PACKAGE_MANAGER in
        apt-get) sudo apt-get update && sudo apt-get install -y curl jq ;;
        yum) sudo yum install -y curl jq ;;
        dnf) sudo dnf install -y curl jq ;;
        pacman) sudo pacman -Syu --noconfirm curl jq ;;
        zypper) sudo zypper install -y curl jq ;;
    esac
}

# Download the main script
download_script() {
    echo "Downloading $SCRIPT_NAME..."
    sudo curl -s -o "$INSTALL_PATH/$SCRIPT_NAME" "https://gptcmd.sh/gptcmd.sh"
    sudo chmod +x "$INSTALL_PATH/$SCRIPT_NAME"
    echo "Script downloaded to $INSTALL_PATH/$SCRIPT_NAME"
}

# Setup the configuration file
setup_config() {
    CONFIG_FILE="$CONFIG_PATH/$CONFIG_FILE_NAME"
    LOCAL_CONFIG_FILE="./$CONFIG_FILE_NAME"

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Creating configuration file at $CONFIG_FILE"
        exec < /dev/tty
        echo -e "\033[1;34mEnter your OpenAI API key:\033[0m"
        read -s API_KEY
        exec < /dev/tty
        echo -e "\033[1;34mEnter the model to use (e.g., gpt-4):\033[0m"
        read MODEL
        exec < /dev/tty
        echo -e "\033[1;34mEnter the temperature (default 0.7):\033[0m"
        read TEMPERATURE
        if [ -z "$TEMPERATURE" ]; then
            TEMPERATURE=0.7
        fi
        sudo bash -c "cat << EOF > $CONFIG_FILE
OPENAI_API_KEY=$API_KEY
MODEL=$MODEL
TEMPERATURE=$TEMPERATURE
EOF"
        sudo chmod 600 "$CONFIG_FILE"
    else
        echo "Configuration file already exists at $CONFIG_FILE"
    fi

    # Link the local config file to the global config if needed
    if [ ! -f "$LOCAL_CONFIG_FILE" ]; then
        ln -s "$CONFIG_FILE" "$LOCAL_CONFIG_FILE"
    fi
}

# Main function
main() {
    detect_package_manager
    install_dependencies
    download_script
    setup_config
    echo "Installation complete. You can now use '$SCRIPT_NAME' from anywhere in your terminal."
}

main
