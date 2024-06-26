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
curl gptcmd.sh | sh
```
### Clone the Repository
Alternatively, you can clone the repository and install manually:

```bash
git clone https://github.com/ciamberlini/gptcmd.git
cd gptcmd
sh install.sh
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

## Update
To update the GPTcmd script to the latest version, run the following command:
```bash
curl gptcmd.sh/update | sh
```

## Configuration
Run the script for the first time to configure the API key and other parameters:

```bash
gptcmd
```
You will be prompted to choose the configuration file location and enter:

- Global (`/etc`) or User (`~/.config/gptcmd`) configuration
- Your OpenAI API key
- The model to use (default gpt-4o)
- The temperature (default 0.7)
- The max tokens (default 150)

These parameters will be saved in a configuration file (`gptcmd.conf`) either in your home directory (`~/.config/gptcmd`) or in `/etc`, depending on your choice.

### Usage
## Running the Command
To use GPTcmd, run the script with the desired command:

```bash
gptcmd "check if Apache is running"
```
## Parameters
- `<prompt>`: The command or description of the action you want to perform. GPTcmd will generate Bash commands to fulfill this request.

## Optional Parameters
- `-n`, `--dry-run`: Use this option to display the generated commands without actually executing them. This can be helpful for previewing the actions GPTcmd will take based on your prompt.
  
## Example:

```bash
gptcmd "list all files larger than 100MB"
```
### Configuration File
The configuration file (`gptcmd.conf`) includes:

- OPENAI_API_KEY: [Your OpenAI API key](https://platform.openai.com/api-keys).
- MODEL: The OpenAI model to use (default gpt-4o).
- TEMPERATURE: The temperature for text generation (default 0.7).
- MAX_TOKENS: The maximum number of tokens for the response (default 150).

## Uninstallation
To uninstall GPTcmd, you can use the following command:

```bash
curl gptcmd.sh/uninstall | sh
```
This will:

- Remove the gptcmd script from `/usr/local/bin`.
- Remove the configuration file from either `/etc` or `$HOME/.gptcmd/`, depending on where it was saved.

## Contributing
Feel free to open a pull request or report an issue on the GitHub repository.

## Donations
If you find GPTcmd useful, consider making a donation to support the project: [Paypal Donation](https://www.paypal.com/donate/?hosted_button_id=JDHXJHNW3P4MA)


## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
