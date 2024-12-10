#!/bin/bash

# Включение режима отладки и немедленного завершения при ошибке
set -euo pipefail
#set -x

# Загрузка конфигурации
source .config

# Директории, которые должны существовать
DIRS=(
    "$HOME/.TelegramDesktop"
    "$HOME/Downloads/Telegram Desktop"
)

# Проверка и создание директорий, если их нет
for DIR in "${DIRS[@]}"; do
    if [ ! -d "$DIR" ]; then
        mkdir -p "$DIR"
        echo "Created directory: $DIR"
    fi
done

# Проверяем наличие версии Telegram
if [[ -f ".telegram_version" ]]; then
    # Считываем версию из файла
    VERSION=$(cat ".telegram_version")

    # Запуск xdg-open хука
#    bash -c "./scripts/xdg-open-hook.sh --host >> xdg-open-host.log 2>&1 &"
    bash -c "./scripts/xdg-open-hook.sh --host &"
    sleep 1

    # Разрешаем доступ X-сессии для контейнера
    xhost +local:docker

    # Формируем имя контейнера
    container_name="${TAG//\//_}-$VERSION"

    # Запуск Docker-контейнера с Telegram
    docker run --rm -it --name "$container_name" \
        --user "$UID:1000" \
        -e DISPLAY="unix$DISPLAY" \
        -e XDG_OPEN_HOOK_PIPE="$XDG_OPEN_HOOK_PIPE" \
        -e PULSE_SERVER="unix:$XDG_RUNTIME_DIR/pulse/native" \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ~/.Xauthority:/home/user/.Xauthority \
        -v "$XDG_RUNTIME_DIR/pulse:$XDG_RUNTIME_DIR/pulse" \
        -v "$PWD/scripts/xdg-open-hook.sh:/bin/x-www-browser" \
        -v "$PWD/.config:/home/user/.config" \
        -v "$PWD/scripts/telegram.sh:/home/user/telegram.sh" \
        -v "$XDG_OPEN_HOOK_PIPE:$XDG_OPEN_HOOK_PIPE" \
        -v /etc/localtime:/etc/localtime:ro \
        -v "$HOME/.TelegramDesktop:/home/user/.local/share/TelegramDesktop/" \
        -v "$HOME/Downloads/Telegram Desktop/:/home/user/Downloads/Telegram Desktop/" \
        "$TAG:$VERSION"
else
    # Сообщаем об ошибке, если файл с версией отсутствует
    echo "ERROR: '.telegram_version' not found! Please run build.sh first."
    exit 1
fi
