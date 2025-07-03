#!/bin/bash

DEVICE="/dev/ttyUSB0"
LOG_DIR="./baudrate_logs"
mkdir -p "$LOG_DIR"

# Full baud rate range including ultra-high
BAUD_RATES=(
  300 600 1200 2400 4800
  9600 14400 19200 28800 31250 38400
  56000 57600 115200 128000 153600
  230400 250000 256000 460800 500000
  576000 625000 768000 921600 1000000
  1152000 1500000 2000000 2500000
  3000000 3500000 4000000 4500000
  5000000 6000000 8000000 10000000 12000000
)

echo "[*] Scanning $DEVICE for working baud rate..."
echo "[*] Logs saved to $LOG_DIR"
echo

# Loop over each baud rate
for BAUD in "${BAUD_RATES[@]}"; do
    echo "[>] Trying baud rate: $BAUD"
    LOG_FILE="$LOG_DIR/${BAUD}.log"

    # Use timeout and redirect stderr to suppress errors
    timeout 3s cat "$DEVICE" > "$LOG_FILE" &
    PID=$!

    # Configure baud rate using stty (no picocom required)
    stty -F "$DEVICE" "$BAUD" cs8 -cstopb -parenb raw

    sleep 3
    kill $PID 2>/dev/null

    if [[ -s "$LOG_FILE" ]]; then
        echo "[✓] Output saved: $LOG_FILE"
    else
        echo "[×] No output"
        rm "$LOG_FILE"
    fi

    echo "---------------------------------------------"
done

echo -e "\n[✓] Scan complete. Check logs in: $LOG_DIR"

# Optional preview
read -p "Preview output? (y/n): " CHOICE
if [[ "$CHOICE" =~ ^[Yy]$ ]]; then
    for BAUD in "${BAUD_RATES[@]}"; do
        LOG_FILE="$LOG_DIR/${BAUD}.log"
        if [[ -f "$LOG_FILE" ]]; then
            echo -e "\n📡 Baud: $BAUD ----------------------------"
            cat "$LOG_FILE"
            read -p "Press Enter for next..."
        fi
    done
fi
