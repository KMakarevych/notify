#!/bin/bash

set -e

echo "🔧 Встановлення notify..."

# Створення директорій
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/notify"

mkdir -p "$BIN_DIR"
mkdir -p "$CONFIG_DIR"

# Копіювання скрипту
SCRIPT_PATH="$BIN_DIR/notify"

cat > "$SCRIPT_PATH" << 'EOFSCRIPT'
#!/bin/bash

# notify - виконує команду і надсилає результат в Telegram
# Використання: notify <команда> [аргументи...]

set -o pipefail

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/notify/config"

send_telegram() {
    local message="$1"
    local bot_token="$2"
    local chat_id="$3"
    
    message=$(echo "$message" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
    
    curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{\"chat_id\": \"${chat_id}\", \"text\": \"${message}\", \"parse_mode\": \"HTML\"}" \
        > /dev/null 2>&1
}

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Конфігураційний файл не знайдено: $CONFIG_FILE"
    echo "Створіть файл з наступним вмістом:"
    echo ""
    echo "TELEGRAM_BOT_TOKEN=\"your_bot_token_here\""
    echo "TELEGRAM_CHAT_ID=\"your_chat_id_here\""
    exit 1
fi

source "$CONFIG_FILE"

if [[ -z "$TELEGRAM_BOT_TOKEN" ]] || [[ -z "$TELEGRAM_CHAT_ID" ]]; then
    echo "❌ Не налаштовані TELEGRAM_BOT_TOKEN або TELEGRAM_CHAT_ID у $CONFIG_FILE"
    exit 1
fi

if [[ $# -eq 0 ]]; then
    echo "Використання: notify <команда> [аргументи...]"
    echo "Приклад: notify rsync -av /source /dest"
    exit 1
fi

COMMAND="$*"
HOSTNAME=$(hostname)
START_TIME=$(date +%s)
START_TIME_HUMAN=$(date '+%Y-%m-%d %H:%M:%S')

echo "🚀 Запуск: $COMMAND"
echo "⏰ Час початку: $START_TIME_HUMAN"

TEMP_OUTPUT=$(mktemp)
"$@" 2>&1 | tee "$TEMP_OUTPUT"
EXIT_CODE=${PIPESTATUS[0]}

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
DURATION_HUMAN=$(printf '%02d:%02d:%02d' $((DURATION/3600)) $((DURATION%3600/60)) $((DURATION%60)))

OUTPUT_TAIL=$(tail -n 10 "$TEMP_OUTPUT" | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g')
rm -f "$TEMP_OUTPUT"

if [[ $EXIT_CODE -eq 0 ]]; then
    STATUS="✅ Успішно"
else
    STATUS="❌ Помилка (код: $EXIT_CODE)"
fi

MESSAGE="<b>$STATUS</b>

<b>Хост:</b> $HOSTNAME
<b>Команда:</b> <code>$COMMAND</code>
<b>Час виконання:</b> $DURATION_HUMAN

<b>Останні рядки виводу:</b>
<pre>$OUTPUT_TAIL</pre>"

echo ""
echo "📤 Відправка сповіщення в Telegram..."
send_telegram "$MESSAGE" "$TELEGRAM_BOT_TOKEN" "$TELEGRAM_CHAT_ID"

if [[ $? -eq 0 ]]; then
    echo "✅ Сповіщення надіслано"
else
    echo "⚠️  Помилка відправки сповіщення"
fi

exit $EXIT_CODE
EOFSCRIPT

chmod +x "$SCRIPT_PATH"

# Створення конфігураційного файлу-шаблону
CONFIG_FILE="$CONFIG_DIR/config"

if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" << 'EOFCONFIG'
# Telegram Bot Configuration
# Отримати токен: https://t.me/BotFather
# Отримати chat_id: https://t.me/userinfobot

TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN_HERE"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID_HERE"
EOFCONFIG
    echo "📝 Створено конфігураційний файл: $CONFIG_FILE"
else
    echo "⚠️  Конфігураційний файл вже існує: $CONFIG_FILE"
fi

# Перевірка PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo ""
    echo "⚠️  Директорія $BIN_DIR не в PATH"
    echo "Додайте в ~/.bashrc або ~/.zshrc:"
    echo ""
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

echo ""
echo "✅ Встановлення завершено!"
echo ""
echo "📋 Наступні кроки:"
echo "1. Налаштуйте конфігурацію: nano $CONFIG_FILE"
echo "2. Додайте $BIN_DIR до PATH (якщо потрібно)"
echo "3. Використання: notify rsync -av /source /dest"
