#!/bin/bash

# Check for the correct Bash binary
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
    CONFIG_FILE_NAME="gptcmd.conf"
    GLOBAL_CONFIG_FILE="/etc/$CONFIG_FILE_NAME"
    USER_CONFIG_DIR="$HOME/.gptcmd"
    USER_CONFIG_FILE="$USER_CONFIG_DIR/$CONFIG_FILE_NAME"

    # Function to prompt for the API key
    prompt_api_key() {
        echo -e "\033[1;34mEnter your OpenAI API key:\033[0m"
        read -s API_KEY
        echo
    }

    # Function to prompt for configuration parameters
    prompt_config_params() {
        echo -e "\033[1;34mEnter the model to use (default gpt-4o):\033[0m"
        read MODEL
        if [ -z "$MODEL" ]; then
            MODEL=gpt-4o
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
            '{
                model: $model,
                temperature: ($temperature | tonumber),
                max_tokens: ($max_tokens | tonumber),
                messages: $messages
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
    }

    # Function to create the user configuration directory if it doesn't exist
    create_user_config_dir() {
        if [ ! -d "$USER_CONFIG_DIR" ]; then
            mkdir -p "$USER_CONFIG_DIR"
        fi
    }

    # Check if the configuration file exists and load it
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
    }

    # Verify that the user has provided a command input
    if [ -z "$1" ]; then
        echo -e "\033[1;31mUsage: $0 <prompt>\033[0m"
        exit 1
    fi

    # Define the desired command
    USER_PROMPT="$@"

    # Load the configuration
    load_config

    # Gather system information
    gather_system_info

    # Prepare the initial prompt
    PROMPT=$(jq -n --arg os_info "$OS_INFO" --arg prompt "$USER_PROMPT" \
        '[{"role": "system", "content": "Generate a JSON array of Bash commands for the following user prompt."},
          {"role": "system", "content": "Operating System: \($os_info)"},
          {"role": "system", "content": "Return the commands in JSON format using the following structure: {\"need_another_iteration\": true, \"commands\": [{ \"cmd\": \"command\" }]}"},
          {"role": "user", "content": $prompt}]')

    NEED_ANOTHER_ITERATION=true
    ITERATION=1
    EXECUTED_COMMANDS=()

    while $NEED_ANOTHER_ITERATION; do
        print_section_header "Iteration $ITERATION: Processing..."

        # Call OpenAI completion API
        RESPONSE=$(call_openai_completion "$PROMPT" "$TEMPERATURE" "$MAX_TOKENS" "$MODEL" "$OPENAI_API_KEY")

        # Extract the JSON commands string from the response
        JSON_COMMANDS=$(echo "$RESPONSE" | jq -r '.choices[0].message.content' | sed -n '/```json/,/```/p' | sed 's/```json//g' | sed 's/```//g')

        if [ -z "$JSON_COMMANDS" ]; then
            echo -e "\033[1;31mNo commands generated. Please check the input or the API response.\033[0m"
            exit 1
        fi

        # Parse JSON to get need_another_iteration flag and commands
        NEED_ANOTHER_ITERATION=$(echo "$JSON_COMMANDS" | jq -r '.need_another_iteration')
        COMMANDS=$(echo "$JSON_COMMANDS" | jq -r '.commands[].cmd')

        # Display and execute each command, avoiding repetitions
        OUTPUT=""
        while IFS= read -r CMD; do
            # Skip if the command is empty or already executed
            if [[ -n "$CMD" && ! " ${EXECUTED_COMMANDS[@]} " =~ " ${CMD} " ]]; then
                EXECUTED_COMMANDS+=("$CMD")
                print_command "$CMD"
                CMD_OUTPUT=$(eval "$CMD" 2>&1)
                print_output "Output for command: $CMD\n$CMD_OUTPUT"
                OUTPUT+="Command: $CMD\nOutput: $CMD_OUTPUT\n"
            fi
        done <<< "$COMMANDS"

        # Update the prompt with the output of the executed commands
        PROMPT=$(jq -n --arg os_info "$OS_INFO" --arg prompt "$USER_PROMPT" --arg output "$OUTPUT" --argjson executed_commands "$(printf '%s\n' "${EXECUTED_COMMANDS[@]}" | jq -R . | jq -s .)" \
            '[{"role": "system", "content": "Generate a JSON array of Bash commands for the following user prompt."},
              {"role": "system", "content": "Operating System: \($os_info)"},
              {"role": "system", "content": "Return the commands in JSON format using the following structure: {\"need_another_iteration\": true, \"commands\": [{ \"cmd\": \"command\" }]}"},
              {"role": "user", "content": $prompt},
              {"role": "assistant", "content": $output},
              {"role": "assistant", "content": "Previously executed commands: \($executed_commands)"}]')

        ITERATION=$((ITERATION + 1))
    done

    print_section_header "Finished processing after $((ITERATION - 1)) iterations."
fi
