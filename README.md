# GPTcmd

GPTcmd is an advanced Bash script that utilizes the OpenAI API to generate and execute Bash commands based on user-provided prompts. The script supports dynamic iterations, especially for complex tasks that require the output of previous commands to generate subsequent ones. It includes a variety of features to enhance usability, security, and functionality.

## Features

- **Interactive Mode by Default**: GPTcmd starts in interactive mode by default, allowing continuous interaction.
- **Non-Interactive Mode**: Use the `-c` or `--command` option to execute a specific command without entering interactive mode.
- **Prompt Length Verification**: Ensures that all prompts are at least 5 characters long for meaningful interactions.
- **Improved Iteration Handling**: Manages complex requests over multiple iterations, maintaining context between commands.
- **Safety Confirmation**: Prompts for confirmation before executing potentially harmful commands.
- **Advanced Configuration Management**: Supports multiple configuration profiles.
- **Error Handling and Logging**: Improved error reporting and command execution logging.
- **Internationalization (i18n)**: Supports multiple languages based on system settings.
- **Command History and Re-execution**: Maintains a history of executed commands for future reference.
- **Cross-Platform Support**: Compatible with Linux, macOS, and Windows (via WSL).
- **Secure API Key Storage**: Encourages secure storage of API keys.
- **Auto-Update Functionality**: Easily update GPTcmd to the latest version.
- **Optimized API Usage**: Reduces costs by caching responses and optimizing token usage.

## Requirements

- Bash Shell
- `curl` for HTTP requests
- `jq` for JSON manipulation

## Installation

### Quick Installation

You can quickly install GPTcmd using `curl`:

```bash
curl gptcmd.sh | sh
```

### Clone the Repository

Alternatively, you can clone the repository and install manually:

```bash
git clone https://github.com/ciamberlini/gptcmd.git
cd gptcmd
./install.sh
```

## Install Dependencies

Ensure that you have `curl` and `jq` installed. The installation script will attempt to install them for you, but you can also install them manually using your system's package manager.

### For Debian/Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y curl jq
```

### For macOS (using Homebrew):

```bash
brew install curl jq
```

## Configuration

On first run, GPTcmd will prompt you to configure your API key and other parameters. The configuration file is stored in `~/.gptcmd/gptcmd.conf`.

You will be prompted to enter:

- Your OpenAI API key
- The model to use (e.g., `gpt-4`)
- The temperature (default `0.7`)
- The maximum number of tokens (default `150`)

### Multiple Configuration Profiles

GPTcmd supports multiple configuration profiles. Use the `--config` flag to specify a different configuration file.

```bash
gptcmd --config work
```

## Usage

### Interactive Mode (Default)

To start GPTcmd in interactive mode, simply run:

```bash
gptcmd
```

You can then enter your prompts one at a time. Type `exit` to quit the interactive mode.

Example:

```bash
$ gptcmd
Entering interactive mode. Type 'exit' to quit.
> list all running Docker containers
```

### Non-Interactive Mode

Use the `-c` or `--command` option to execute a specific prompt without entering interactive mode:

```bash
gptcmd -c "check disk usage in the home directory"
```

### Prompt Length Verification

GPTcmd requires prompts to be at least 5 characters long to ensure meaningful interactions.

### Dry Run Mode

Use the `-n` or `--dry-run` option to display the commands that would be executed without actually running them:

```bash
gptcmd -n -c "delete temporary files older than 7 days"
```

### Command History

View your command history:

```bash
gptcmd --history
```

### Updating GPTcmd

Update to the latest version:

```bash
gptcmd --update
```

## Parameters

- `-c`, `--command "<prompt>"`: Execute a specific prompt in non-interactive mode.
- `-n`, `--dry-run`: Show the commands that would be executed without actually running them.
- `--history`: Display the command history.
- `--update`: Update GPTcmd to the latest version.

## Examples

**Interactive Mode**:

```bash
$ gptcmd
Entering interactive mode. Type 'exit' to quit.
> find all PDF files in the Documents folder
```

**Non-Interactive Mode**:

```bash
gptcmd -c "list open network ports"
```

**Dry Run**:

```bash
gptcmd -n -c "restart the nginx service"
```

## Safety Features

GPTcmd includes safety confirmations for potentially harmful commands. You will be prompted before executing commands like `rm -rf`.

## Internationalization

GPTcmd detects your system's language and interacts accordingly. It supports multiple languages for prompts and outputs.

## Logging and Error Handling

All command executions and outputs are logged in `~/.gptcmd/gptcmd.log` for your reference.

## Secure API Key Storage

It is recommended to set your OpenAI API key as the `OPENAI_API_KEY` environment variable for increased security.

## Contributions

Feel free to open a pull request or report an issue on the GitHub repository.

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for details.
