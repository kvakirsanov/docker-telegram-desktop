#!/bin/bash

/home/user/Telegram & TELEGRAM_PID=$!
sleep 5

echo "Monitoring Telegram process with PID $TELEGRAM_PID..."

check_windows() {
    wmctrl -lp | awk -v pid="$TELEGRAM_PID" '$3 == pid {found=1} END {exit !found}'
}

while true; do
    if ! check_windows; then
        echo "Telegram window closed, terminating process..."
        kill -TERM $TELEGRAM_PID
        break
    fi
    sleep 1
done