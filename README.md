# GPTcmd

GPTcmd is a Bash script that utilizes the OpenAI API to generate and execute Bash commands based on a user-provided prompt. The script supports dynamic iterations based on the API's output.

## Features

- Automatically generates Bash commands using the OpenAI API.
- Supports dynamic iterations based on the needs of the API's response.
- Easy configuration and automatic creation of a configuration file if not present.
- Colored output for better readability.

## Requirements

- Bash shell
- `curl` for HTTP requests
- `jq` for JSON manipulation

## Installation

### Clone the Repository

```bash
git clone https://github.com/your-username/gptcmd.git
cd gptcmd
