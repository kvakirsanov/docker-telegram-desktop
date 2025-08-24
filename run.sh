#!/bin/bash

# Enable debugging mode and immediate exit on error
set -euo pipefail
#set -x

# Load configuration
source .config


cleanup() {
    echo "Cleaning up..."
    rm -f "$XDG_OPEN_HOOK_PIPE"
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

# Directories that must exist
DIRS=(
    "$HOME/.TelegramDesktop"
    "$HOME/Downloads/Telegram Desktop"
)

# Check and create directories if they do not exist
for DIR in "${DIRS[@]}"; do
    if [ ! -d "$DIR" ]; then
        mkdir -p "$DIR"
        echo "Created directory: $DIR"
    fi
done

# Check if the Telegram version file exists
if [[ -f ".telegram_version" ]]; then
    # Read the version from the file
    VERSION=$(cat ".telegram_version")

    # Start the xdg-open hook
#    bash -c "./scripts/xdg-open-hook.sh --host >> xdg-open-host.log 2>&1 &"
    bash -c "./scripts/xdg-open-hook.sh --host &"
    sleep 1

    # Allow X session access for the container
    xhost +local:docker

    # Generate container name
    container_name="${TAG//\//_}-$VERSION"

    # Run the Docker container with Telegram
    docker run --rm --platform linux/amd64 -it --name "$container_name" \
        --network=host \
        --user "$UID:1000" \
        -e DISPLAY="unix$DISPLAY" \
        -e XDG_OPEN_HOOK_PIPE="$XDG_OPEN_HOOK_PIPE" \
        -e PULSE_SERVER="unix:$XDG_RUNTIME_DIR/pulse/native" \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ~/.Xauthority:/home/user/.Xauthority \
        -v "$XDG_RUNTIME_DIR/pulse:$XDG_RUNTIME_DIR/pulse" \
        -v "$PWD/scripts/xdg-open-hook.sh:/bin/x-www-browser" \
        -v "$PWD/.config:/home/user/.config" \
        -v "$PWD/.cache:/home/user/.cache" \
        -v "$PWD/.local:/home/user/.local" \
        -v "$PWD/scripts/telegram.sh:/home/user/telegram.sh" \
        -v "$XDG_OPEN_HOOK_PIPE:$XDG_OPEN_HOOK_PIPE" \
        -v /etc/localtime:/etc/localtime:ro \
        -v "$HOME/.TelegramDesktop:/home/user/.local/share/TelegramDesktop/" \
        -v "$HOME/Downloads/Telegram Desktop/:/home/user/Downloads/Telegram Desktop/" \
        "$TAG:$VERSION"
else
    # Display an error if the version file is missing
    echo "ERROR: '.telegram_version' not found! Please run build.sh first."
    exit 1
fi
