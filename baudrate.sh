#!/bin/bash

DEVICE="/dev/ttyUSB0"
LOG_DIR="./baudrate_logs"
mkdir -p "$LOG_DIR"

BAUD_RATES=(
  300 600 1200 2400 4800
  9600 14400 19200 28800 31250 38400
  56000 57600 115200 128000 153600
  230400 250000 256000 460800 500000
  576000 625000 768000 921600 1000000
  1152000 1500000 2000000 2500000
  3000000 3500000 4000000 4500000
  5000000 6000000
)

echo " Scanning $DEVICE for correct baud rate..."
echo "Saving results in $LOG_DIR"

for BAUD in "${BAUD_RATES[@]}"; do
    echo " Trying baud rate: $BAUD"
    LOG_FILE="$LOG_DIR/${BAUD}.log"
    
    # kill any old picocom
    pkill -f "picocom -b" &> /dev/null

    # Use timeout to capture 2 seconds of output
    timeout 2s picocom -b "$BAUD" "$DEVICE" --quiet --nolock --echo --exit-after - > "$LOG_FILE" 2>/dev/null
    
    echo "Saved output to $LOG_FILE"
done

echo -e "\n Done scanning. Logs saved in $LOG_DIR"

read -p "Do you want to preview each result now? (y/n): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    for BAUD in "${BAUD_RATES[@]}"; do
        LOG_FILE="$LOG_DIR/${BAUD}.log"
        echo -e "\n📡 Baud: $BAUD ----------------------------"
        cat "$LOG_FILE"
        read -p "Press Enter for next..."
    done
fi
