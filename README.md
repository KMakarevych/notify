# Notify - Telegram Command Completion Notifications

A utility for executing commands with automatic result notifications sent to Telegram.

## Features

- Execute any command with automatic Telegram notifications
- Display execution status (success/error)
- Show command execution time
- Output last 10 lines of result
- Support for interactive commands (sudo, ssh, etc.)

## Quick Installation

### Remote Installation (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/KMakarevych/notify/refs/heads/main/install-notify.sh | bash
```

or using wget:

```bash
wget -qO- https://raw.githubusercontent.com/KMakarevych/notify/refs/heads/main/install-notify.sh | bash
```

### Local Installation

```bash
git clone https://github.com/KMakarevych/notify.git
cd notify
./install-notify.sh
```

## Configuration

### 1. Creating a Telegram Bot

1. Open [@BotFather](https://t.me/BotFather) in Telegram
2. Send the `/newbot` command
3. Follow the instructions to create your bot
4. Save the token you receive (looks like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### 2. Getting Your Chat ID

1. Open [@userinfobot](https://t.me/userinfobot) in Telegram
2. Send any message
3. The bot will return your Chat ID (a number, e.g., `123456789`)

### 3. Configuring notify

Edit the configuration file:

```bash
nano ~/.config/notify/config
```

Replace the values with your own:

```bash
TELEGRAM_BOT_TOKEN="your_bot_token"
TELEGRAM_CHAT_ID="your_chat_id"
```

### 4. Adding to PATH (if required)

If you received a PATH warning during installation, add to `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload the configuration:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Usage

### Basic Usage

```bash
notify <command> [arguments...]
```

### Examples

**Simple command:**
```bash
notify ls -la /home
```

**Long-running operation:**
```bash
notify rsync -av /source /destination
```

**Command with sudo:**
```bash
notify sudo apt update && sudo apt upgrade -y
```

**Backup:**
```bash
notify sudo rsync -av --delete /home /mnt/backup
```

**Project compilation:**
```bash
notify make build
```

**Running tests:**
```bash
notify npm test
```

## How It Works

1. `notify` executes the specified command
2. Displays command output in real-time
3. Saves output to a temporary file
4. After completion, sends a Telegram message with:
   - Execution status (success/error)
   - Hostname
   - Full command
   - Execution time
   - Last 10 lines of output

## Features

### Sudo Support

The script works correctly with commands requiring sudo. You can enter the password in the terminal, and the notification will be sent after completion.

### Exit Code

`notify` returns the same exit code as the executed command. This allows you to use it in scripts:

```bash
if notify ./deploy.sh; then
    echo "Deploy successful"
else
    echo "Deploy failed"
fi
```

### Privacy

Command output is saved only locally and deleted after sending the notification. Only the last 10 lines are sent to Telegram.

## Uninstallation

```bash
rm -f ~/.local/bin/notify
rm -rf ~/.config/notify
```

## Requirements

- Bash 4.0+
- curl (for sending messages to Telegram)
- Internet access

## License

MIT

## Support

If you found a bug or have a suggestion, create an issue on GitHub:
https://github.com/KMakarevych/notify/issues
