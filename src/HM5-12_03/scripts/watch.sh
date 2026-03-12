#!/bin/bash

WATCH_DIR="/home/dl/watch"

if [ ! -d "$WATCH_DIR" ]; then
    mkdir -p "$WATCH_DIR"
    echo "Created missing directory: $WATCH_DIR"
fi

inotifywait -m -e create --format '%f' "$WATCH_DIR" | while read NEW_FILE; do
    FULL_PATH="$WATCH_DIR/$NEW_FILE"

    sleep 0.1

    if [ -f "$FULL_PATH" ]; then
        echo "New file detected: $NEW_FILE"
        cat "$FULL_PATH"
        mv "$FULL_PATH" "$FULL_PATH.back"
        echo "Renamed $NEW_FILE to $NEW_FILE.back"
    fi
done
