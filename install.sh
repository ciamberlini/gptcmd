#!/bin/bash

# Name of the script
SCRIPT_NAME="gptcmd"
CONFIG_FILE_NAME="gptcmd.conf"
INSTALL_PATH="/usr/local/bin"
GLOBAL_CONFIG_PATH="/etc"
USER_CONFIG_PATH="$HOME/.gptcmd"

# Function to detect the operating system
detect_os() {
    OS_TYPE=$(uname)
    case "$OS_TYPE" in
        Linux*)     OS_NAME="Linux";;
        Darwin*)    OS_NAME="macOS";;
        *)          OS_NAME="Unknown";;
    esac
}

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
    elif command -v brew &> /dev/null; then
        PACKAGE_MANAGER="brew"
    else
        echo "Unsupported package manager. Please install 'curl' and 'jq' manually."
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
        brew) brew install curl jq ;;
    esac
}

# Download the main script
download_script() {
    echo "Downloading $SCRIPT_NAME..."
    sudo curl -s -o "$INSTALL_PATH/$SCRIPT_NAME" "https://gptcmd.sh/gptcmd.sh"
    sudo chmod +x "$INSTALL_PATH/$SCRIPT_NAME"
    echo "Script downloaded to $INSTALL_PATH/$SCRIPT_NAME"
}

# Prompt for configuration location
prompt_config_location() {
    exec < /dev/tty
    echo -e "\033[1;34mWhere do you want to save the configuration?\033[0m"
    echo -e "1) Global ($GLOBAL_CONFIG_PATH)"
    echo -e "2) User ($USER_CONFIG_PATH)"
    read -p "Choose 1 or 2: " CONFIG_LOCATION_CHOICE

    case $CONFIG_LOCATION_CHOICE in
        1)
            CONFIG_PATH="$GLOBAL_CONFIG_PATH"
            ;;
        2)
            CONFIG_PATH="$USER_CONFIG_PATH"
            ;;
        *)
            echo "Invalid choice. Defaulting to user configuration."
            CONFIG_PATH="$USER_CONFIG_PATH"
            ;;
    esac
}

# Setup the configuration file
setup_config() {
    CONFIG_FILE="$CONFIG_PATH/$CONFIG_FILE_NAME"

    # Ensure the configuration directory exists
    if [ ! -d "$CONFIG_PATH" ]; then
        mkdir -p "$CONFIG_PATH"
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Creating configuration file at $CONFIG_FILE"
        exec < /dev/tty
        echo -e "\033[1;34mEnter your OpenAI API key:\033[0m"
        read -s API_KEY
        echo
        exec < /dev/tty
        echo -e "\033[1;34mEnter the model to use (default gpt-4):\033[0m"
        read MODEL
        if [ -z "$MODEL" ]; then
            MODEL="gpt-4"
        fi
        exec < /dev/tty
        echo -e "\033[1;34mEnter the temperature (default 0.7):\033[0m"
        read TEMPERATURE
        if [ -z "$TEMPERATURE" ]; then
            TEMPERATURE=0.7
        fi
        exec < /dev/tty
        echo -e "\033[1;34mEnter the max tokens (default 150):\033[0m"
        read MAX_TOKENS
        if [ -z "$MAX_TOKENS" ]; then
            MAX_TOKENS=150
        fi
        cat << EOF > "$CONFIG_FILE"
OPENAI_API_KEY=$API_KEY
MODEL=$MODEL
TEMPERATURE=$TEMPERATURE
MAX_TOKENS=$MAX_TOKENS
EOF
        chmod 600 "$CONFIG_FILE"
    else
        echo "Configuration file already exists at $CONFIG_FILE"
    fi
}

# Main function
main() {
    detect_os
    detect_package_manager
    install_dependencies
    download_script
    prompt_config_location
    setup_config
    echo "Installation complete. You can now use '$SCRIPT_NAME' from anywhere in your terminal."
}

main
