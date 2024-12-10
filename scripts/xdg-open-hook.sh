#!/bin/bash

set +ex

SCRIPT_NAME=$(basename "$0")
CURRENT_PID=$$

terminate_previous_instances() {
    pgrep -f "$SCRIPT_NAME" | grep -v "$CURRENT_PID" | xargs -r kill
}

cleanup() {
    echo "Cleaning up..."
    rm -f "$XDG_OPEN_HOOK_PIPE"
    exit 0
}

start_pipe_listener() {

    trap cleanup SIGINT SIGTERM EXIT
    . .config

    while true; do
        echo "Starting xdg-open listener..."

        rm -f "$XDG_OPEN_HOOK_PIPE"
        mkfifo "$XDG_OPEN_HOOK_PIPE"

        echo "Listening for URLs on $XDG_OPEN_HOOK_PIPE..."
        while read -r url <"$XDG_OPEN_HOOK_PIPE"; do
            if [[ -n "$url" && "$url" =~ ^https?://.* ]]; then
                echo "VALID URL: $url"
                xdg-open "$url"

            elif [[ -n "$url" && "$url" =~ ^file://\/home\/user\/Downloads\/Telegram%20Desktop\/.* ]]; then
                echo "VALID FILE: $url"

                filename=$(basename "$url")
                xdg-open "file://${home}/Downloads/Telegram Desktop/${filename}"

            else
                echo "ERROR: Invalid or disallowed URL '$url'"
            fi
        done

        echo "Restarting listener due to failure..."
        sleep 1
    done
}

if [[ "$1" == "--host" ]]; then

    terminate_previous_instances
    start_pipe_listener

else
    if [[ ! -p "$XDG_OPEN_HOOK_PIPE" ]]; then
        echo "ERROR: Pipe $XDG_OPEN_HOOK_PIPE does not exist. Start script with '--host' first."
        exit 1
    fi

    echo "URL: $@"
    echo "$@" >"$XDG_OPEN_HOOK_PIPE"
fi
