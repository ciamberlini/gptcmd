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

### Quick Installation

You can install GPTcmd quickly using `curl`:

```bash
curl https://gptcmd.sh/gptcmd.sh | sh
```
### Clone the Repository
Alternatively, you can clone the repository and install manually:

```bash
git clone https://github.com/ciamberlini/gptcmd.git
cd gptcmd
```
## Install Dependencies
Make sure you have curl and jq installed. You can install them using your system's package manager:

### For Debian/Ubuntu:
```bash
sudo apt-get update
sudo apt-get install -y curl jq
```
### For RHEL/CentOS:
```bash
sudo yum install -y curl jq
```
### For Fedora:
```bash
sudo dnf install -y curl jq
```
### For Arch Linux:
```bash
sudo pacman -Syu --noconfirm curl jq
```
### For openSUSE:
```bash
sudo zypper install -y curl jq
```
## Configuration
Run the script for the first time to configure the API key and other parameters:

```bash
./gptcmd.sh
```
You will be prompted to enter:

- Your OpenAI API key
- The model to use (e.g., gpt-4)
- The temperature (default 0.7)

These parameters will be saved in a configuration file (gptcmd.conf) in your current directory or in /etc if executed with administrator permissions.

### Usage
## Running the Command
To use GPTcmd, run the script with the desired command:

```bash
./gptcmd.sh "check if Apache is running"
```
## Parameters
- <desired-command>: The command or description of the action you want to perform. GPTcmd will generate Bash commands to fulfill this request.

## Example:

```bash
./gptcmd.sh "list all files larger than 100MB"
```
### Configuration File
The configuration file (gptcmd.conf) includes:

- OPENAI_API_KEY: Your OpenAI API key.
- MODEL: The OpenAI model to use (e.g., gpt-4).
- TEMPERATURE: The temperature for text generation (default 0.7).

## Contributing
Feel free to open a pull request or report an issue on the GitHub repository.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
