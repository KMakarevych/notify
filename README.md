# Notify - Telegram уведомления о завершении команд

Утилита для выполнения команд с автоматической отправкой уведомлений о результате в Telegram.

## Возможности

- Выполнение любых команд с автоматическим уведомлением в Telegram
- Отображение статуса выполнения (успешно/ошибка)
- Показ времени выполнения команды
- Вывод последних 10 строк результата
- Поддержка интерактивных команд (sudo, ssh и т.д.)

## Быстрая установка

### Удаленная установка (рекомендуется)

```bash
curl -fsSL https://raw.githubusercontent.com/KMakarevych/notify/refs/heads/main/install-notify.sh | bash
```

или с использованием wget:

```bash
wget -qO- https://raw.githubusercontent.com/KMakarevych/notify/refs/heads/main/install-notify.sh | bash
```

### Локальная установка

```bash
git clone https://github.com/KMakarevych/notify.git
cd notify
./install-notify.sh
```

## Настройка

### 1. Создание Telegram бота

1. Откройте [@BotFather](https://t.me/BotFather) в Telegram
2. Отправьте команду `/newbot`
3. Следуйте инструкциям для создания бота
4. Сохраните полученный токен (выглядит как `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### 2. Получение Chat ID

1. Откройте [@userinfobot](https://t.me/userinfobot) в Telegram
2. Отправьте любое сообщение
3. Бот вернет ваш Chat ID (число, например `123456789`)

### 3. Конфигурация notify

Отредактируйте конфигурационный файл:

```bash
nano ~/.config/notify/config
```

Замените значения на свои:

```bash
TELEGRAM_BOT_TOKEN="ваш_токен_бота"
TELEGRAM_CHAT_ID="ваш_chat_id"
```

### 4. Добавление в PATH (если требуется)

Если при установке было предупреждение о PATH, добавьте в `~/.bashrc` или `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Затем перезагрузите конфигурацию:

```bash
source ~/.bashrc  # или source ~/.zshrc
```

## Использование

### Базовое использование

```bash
notify <команда> [аргументы...]
```

### Примеры

**Простая команда:**
```bash
notify ls -la /home
```

**Длительная операция:**
```bash
notify rsync -av /source /destination
```

**Команда с sudo:**
```bash
notify sudo apt update && sudo apt upgrade -y
```

**Резервное копирование:**
```bash
notify sudo rsync -av --delete /home /mnt/backup
```

**Компиляция проекта:**
```bash
notify make build
```

**Запуск тестов:**
```bash
notify npm test
```

## Как это работает

1. `notify` запускает указанную команду
2. Отображает вывод команды в реальном времени
3. Сохраняет вывод во временный файл
4. После завершения отправляет в Telegram сообщение с:
   - Статусом выполнения (успех/ошибка)
   - Именем хоста
   - Полной командой
   - Временем выполнения
   - Последними 10 строками вывода

## Особенности

### Поддержка sudo

Скрипт корректно работает с командами, требующими sudo. Вы сможете ввести пароль в терминале, и уведомление будет отправлено после завершения.

### Код возврата

`notify` возвращает тот же код завершения, что и выполненная команда. Это позволяет использовать его в скриптах:

```bash
if notify ./deploy.sh; then
    echo "Деплой успешен"
else
    echo "Деплой провалился"
fi
```

### Конфиденциальность

Вывод команды сохраняется только локально и удаляется после отправки уведомления. В Telegram отправляются только последние 10 строк.

## Удаление

```bash
rm -f ~/.local/bin/notify
rm -rf ~/.config/notify
```

## Требования

- Bash 4.0+
- curl (для отправки сообщений в Telegram)
- Доступ к интернету

## Лицензия

MIT

## Поддержка

Если вы нашли баг или у вас есть предложение, создайте issue на GitHub:
https://github.com/KMakarevych/notify/issues
