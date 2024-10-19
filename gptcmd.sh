#!/bin/bash

# Ensure the script is executed with Bash
if [ -z "$BASH_VERSION" ]; then
    # Find Bash in common locations and re-execute the script
    if [ -x /bin/bash ]; then
        exec /bin/bash "$0" "$@"
    elif [ -x /usr/bin/bash ]; then
        exec /usr/bin/bash "$0" "$@"
    else
        echo "Bash not found. Please install Bash or specify the correct path."
        exit 1
    fi
else
    # Actual script content starts here

    # Set configuration file names and paths
    CONFIG_FILE_NAME="gptcmd.conf"
    GLOBAL_CONFIG_FILE="/etc/$CONFIG_FILE_NAME"
    USER_CONFIG_DIR="$HOME/.gptcmd"
    USER_CONFIG_FILE="$USER_CONFIG_DIR/$CONFIG_FILE_NAME"
    LOG_FILE="$USER_CONFIG_DIR/gptcmd.log"
    HISTORY_FILE="$USER_CONFIG_DIR/history.log"
    CACHE_DIR="$USER_CONFIG_DIR/cache"
    DRY_RUN=false  # Default to false
    INTERACTIVE_MODE=true  # Default to true

    # Create necessary directories
    mkdir -p "$USER_CONFIG_DIR" "$CACHE_DIR"

    # Function to prompt for the API key
    prompt_api_key() {
        echo -e "\033[1;34mEnter your OpenAI API key:\033[0m"
        read -s API_KEY
        echo
    }

    # Function to prompt for configuration parameters
    prompt_config_params() {
        echo -e "\033[1;34mEnter the model to use (default gpt-4):\033[0m"
        read MODEL
        if [ -z "$MODEL" ]; then
            MODEL="gpt-4"
        fi
        echo -e "\033[1;34mEnter the temperature (default 0.7):\033[0m"
        read TEMPERATURE
        if [ -z "$TEMPERATURE" ]; then
            TEMPERATURE=0.7
        fi
        echo -e "\033[1;34mEnter the max tokens (default 150):\033[0m"
        read MAX_TOKENS
        if [ -z "$MAX_TOKENS" ]; then
            MAX_TOKENS=150
        fi
    }

    # Function to call OpenAI API
    call_openai_completion() {
        local prompt="$1"
        local temperature="$2"
        local max_tokens="$3"
        local model="$4"
        local openai_api_key="$5"
        local functions="$6"
        
        local url="https://api.openai.com/v1/chat/completions"
        local headers=(
            "Content-Type: application/json"
            "Authorization: Bearer $openai_api_key"
        )
        
        # Prepare JSON request data
        local request_data
        request_data=$(jq -n \
            --arg model "$model" \
            --arg temperature "$temperature" \
            --arg max_tokens "$max_tokens" \
            --argjson messages "$prompt" \
            --argjson functions "$functions" \
            '{
                model: $model,
                temperature: ($temperature | tonumber),
                max_tokens: ($max_tokens | tonumber),
                messages: $messages,
                functions: $functions
            }')

        # Send the request
        response=$(curl -s -S -L -X POST "$url" \
            -H "${headers[0]}" \
            -H "${headers[1]}" \
            -d "$request_data")

        echo "$response"
    }

    # Function to print section headers with colors
    print_section_header() {
        echo -e "\033[1;32m\n$1\033[0m"
        echo -e "\033[1;32m-----------------------------------------------------------\033[0m"
    }

    # Function to print commands with colors
    print_command() {
        echo -e "\033[1;33m$1\033[0m"
    }

    # Function to print command output with colors
    print_output() {
        echo -e "\033[1;36m$1\033[0m"
    }

    # Function to gather system information
    gather_system_info() {
        OS_INFO=$(uname -a)
        LANGUAGE=${LANG%_*}
    }

    # Function to create the user configuration directory if it doesn't exist
    create_user_config_dir() {
        if [ ! -d "$USER_CONFIG_DIR" ]; then
            mkdir -p "$USER_CONFIG_DIR"
        fi
    }

    # Function to load the configuration
    load_config() {
        if [ -f "$USER_CONFIG_FILE" ]; then
            source "$USER_CONFIG_FILE"
        elif [ -f "$GLOBAL_CONFIG_FILE" ]; then
            source "$GLOBAL_CONFIG_FILE"
        else
            echo -e "\033[1;34mConfiguration file not found. Creating a new one...\033[0m"
            prompt_api_key
            prompt_config_params
            create_user_config_dir
            cat << EOF > "$USER_CONFIG_FILE"
OPENAI_API_KEY=$API_KEY
MODEL=$MODEL
TEMPERATURE=$TEMPERATURE
MAX_TOKENS=$MAX_TOKENS
EOF
            echo -e "\033[1;34mConfiguration file created in $USER_CONFIG_FILE.\033[0m"
            source "$USER_CONFIG_FILE"
        fi

        # Check if API key is set in environment variable
        if [ -z "$OPENAI_API_KEY" ]; then
            echo -e "\033[1;31mAPI key not found. Please set the OPENAI_API_KEY environment variable.\033[0m"
            exit 1
        fi
    }

    # Function to check for dangerous commands
    is_dangerous_command() {
        local cmd="$1"
        local dangerous_patterns=("rm -rf" "mkfs" ">:0" "dd if=" "shutdown" "reboot" "init 0" ":(){ :|: & };:")
        for pattern in "${dangerous_patterns[@]}"; do
            if [[ "$cmd" == *"$pattern"* ]]; then
                return 0
            fi
        done
        return 1
    }

    # Function to add messages safely
    add_message() {
        local role="$1"
        local content="$2"
        local name="$3"
        if [ "$role" == "function" ]; then
            local message=$(jq -n --arg role "$role" --arg content "$content" --arg name "$name" '{role: $role, name: $name, content: $content}')
        else
            local message=$(jq -n --arg role "$role" --arg content "$content" '{role: $role, content: $content}')
        fi
        MESSAGES+=("$message")
    }

    # Function to handle user prompt
    prompt_user() {
        if $INTERACTIVE_MODE; then
            echo -e "\033[1;34mEntering interactive mode. Type 'exit' to quit.\033[0m"
            while true; do
                read -p "> " USER_PROMPT
                if [[ "$USER_PROMPT" == "exit" ]]; then
                    break
                fi
                # Check if prompt has at least 5 characters
                if [ ${#USER_PROMPT} -lt 5 ]; then
                    echo -e "\033[1;31mPrompt must be at least 5 characters long.\033[0m"
                    continue
                fi
                process_prompt "$USER_PROMPT"
            done
        else
            # Check if prompt has at least 5 characters
            if [ -z "$USER_PROMPT" ] || [ ${#USER_PROMPT} -lt 5 ]; then
                echo -e "\033[1;31mPrompt must be at least 5 characters long.\033[0m"
                exit 1
            fi
            process_prompt "$USER_PROMPT"
        fi
    }

    # Function to process the user prompt
    process_prompt() {
        local USER_PROMPT="$1"

        # Append to history
        echo "$USER_PROMPT" >> "$HISTORY_FILE"

        # Initialize message history
        MESSAGES=()

        # Gather system information
        gather_system_info

        # Add initial messages
        add_message "system" "Operating System: $OS_INFO"
        add_message "system" "Language: $LANGUAGE"
        add_message "system" "You will help execute a series of Bash commands to achieve the following goal: $USER_PROMPT. After each command, wait for the output before providing the next command. If you require additional information, ask for it."
        add_message "user" "$USER_PROMPT"

        # Functions for OpenAI API
        FUNCTIONS='[
            {
                "name": "execute_command",
                "description": "Executes a Bash command and returns the output.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "command": { "type": "string", "description": "The command to execute." }
                    },
                    "required": ["command"]
                }
            }
        ]'

        # Convert FUNCTIONS to JSON
        FUNCTIONS_JSON=$(echo "$FUNCTIONS" | jq '.')

        NEED_ANOTHER_ITERATION=true
        ITERATION=1

        while $NEED_ANOTHER_ITERATION; do
            print_section_header "Iteration $ITERATION: Processing..."

            # Prepare the prompt for the API
            PROMPT=$(printf '%s\n' "${MESSAGES[@]}" | jq -s '.')

            # Check cache
            CACHE_FILE="$CACHE_DIR/$(echo -n "$PROMPT" | md5sum | awk '{print $1}').json"
            if [ -f "$CACHE_FILE" ]; then
                RESPONSE=$(cat "$CACHE_FILE")
            else
                RESPONSE=$(call_openai_completion "$PROMPT" "$TEMPERATURE" "$MAX_TOKENS" "$MODEL" "$OPENAI_API_KEY" "$FUNCTIONS_JSON")
                echo "$RESPONSE" > "$CACHE_FILE"
            fi

            # Append assistant's message to message history
            ASSISTANT_MESSAGE=$(echo "$RESPONSE" | jq '.choices[0].message')
            MESSAGES+=("$(echo "$ASSISTANT_MESSAGE" | jq -c '.')")

            # Check if the assistant requested a function call
            FUNCTION_CALL=$(echo "$ASSISTANT_MESSAGE" | jq -r '.function_call.name // empty')

            if [ "$FUNCTION_CALL" == "execute_command" ]; then
                # Extract and parse the arguments JSON string
                COMMAND_TO_EXECUTE=$(echo "$ASSISTANT_MESSAGE" | jq -r '.function_call.arguments | fromjson | .command')

                # Display the command
                print_command "$COMMAND_TO_EXECUTE"

                # Append command to history
                echo "$COMMAND_TO_EXECUTE" >> "$HISTORY_FILE"

                # Check for dangerous commands
                if is_dangerous_command "$COMMAND_TO_EXECUTE"; then
                    echo -e "\033[1;31mDangerous command detected: $COMMAND_TO_EXECUTE\033[0m"
                    read -p "Are you sure you want to execute this command? (y/N): " CONFIRM
                    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
                        echo -e "\033[1;33mSkipping command: $COMMAND_TO_EXECUTE\033[0m"
                        CMD_OUTPUT="Command skipped by user."
                    else
                        # Execute command and log output
                        if $DRY_RUN; then
                            print_output "Dry run: Command not executed."
                            CMD_OUTPUT="Dry run: Command not executed."
                        else
                            CMD_OUTPUT=$(eval "$COMMAND_TO_EXECUTE" 2>&1 | tee -a "$LOG_FILE")
                        fi
                    fi
                else
                    # Execute command and log output
                    if $DRY_RUN; then
                        print_output "Dry run: Command not executed."
                        CMD_OUTPUT="Dry run: Command not executed."
                    else
                        CMD_OUTPUT=$(eval "$COMMAND_TO_EXECUTE" 2>&1 | tee -a "$LOG_FILE")
                    fi
                fi

                # Display command output
                print_output "Output for command: $COMMAND_TO_EXECUTE\n$CMD_OUTPUT"

                # Add function response to messages
                add_message "function" "$CMD_OUTPUT" "execute_command"

                # Indicate that another iteration may be needed
                NEED_ANOTHER_ITERATION=true

            else
                # No function call, consider the conversation over
                NEED_ANOTHER_ITERATION=false
            fi

            ITERATION=$((ITERATION + 1))
        done

        print_section_header "Finished processing after $((ITERATION - 1)) iterations."
    }

    # Function to update the script
    update_script() {
        echo -e "\033[1;34mUpdating GPTcmd...\033[0m"
        SCRIPT_PATH=$(realpath "$0")
        curl -s -o "$SCRIPT_PATH" "https://gptcmd.sh/gptcmd.sh"
        chmod +x "$SCRIPT_PATH"
        echo -e "\033[1;32mGPTcmd has been updated to the latest version.\033[0m"
    }

    # Parse command line options
    while [ "$1" != "" ]; do
        case $1 in
            -n | --dry-run )
                DRY_RUN=true
                ;;
            -c | --command )
                INTERACTIVE_MODE=false
                shift
                USER_PROMPT="$1"
                ;;
            --history )
                cat "$HISTORY_FILE"
                exit 0
                ;;
            --update )
                update_script
                exit 0
                ;;
            * )
                echo -e "\033[1;31mInvalid option: $1\033[0m"
                echo "Usage: $0 [-n|--dry-run] [-c|--command \"your prompt\"]"
                exit 1
                ;;
        esac
        shift
    done

    # Load the configuration
    load_config

    # Handle user prompt
    prompt_user

fi
