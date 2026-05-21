#!/bin/bash

MODE="${1:-area}"

SCREENSHOTS_DIR="${XDG_SCREENSHOTS_DIR:-$HOME/pictures/screenshots}"
TEMP_FILE=$(mktemp /tmp/screenshot_XXXXX.png)
trap 'rm -f "$TEMP_FILE"' EXIT

case "$MODE" in
    area)
        grimblast save area "$TEMP_FILE" || exit 1
        ;;
    output)
        grimblast save output "$TEMP_FILE" || exit 1
        wl-copy < "$TEMP_FILE" || exit 1
        notify-send "Screenshot" "Output copied to clipboard"
        exit 0
        ;;
    screen)
        grimblast save screen "$TEMP_FILE" || exit 1
        wl-copy < "$TEMP_FILE" || exit 1
        notify-send "Screenshot" "Screen copied to clipboard"
        exit 0
        ;;
    *)
        echo "Usage: $0 {area|output|screen}"
        exit 1
        ;;
esac

[ ! -s "$TEMP_FILE" ] && exit 1

CHOICE=$(echo -e "Save to screenshots\nChoose location\nCopy to clipboard" | rofi -dmenu -p "Screenshot" || echo "")

case "$CHOICE" in
    "Save to screenshots")
        mkdir -p "$SCREENSHOTS_DIR"
        FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
        cp "$TEMP_FILE" "$SCREENSHOTS_DIR/$FILENAME"
        notify-send "Screenshot" "Saved to $SCREENSHOTS_DIR/$FILENAME"
        ;;
    "Choose location")
        mkdir -p "$SCREENSHOTS_DIR"
        FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
        cp "$TEMP_FILE" "$SCREENSHOTS_DIR/$FILENAME"
        if command -v thunar &>/dev/null; then
            thunar "$SCREENSHOTS_DIR"
        else
            xdg-open "$SCREENSHOTS_DIR"
        fi
        notify-send "Screenshot" "Saved to $SCREENSHOTS_DIR/$FILENAME"
        ;;
    "Copy to clipboard")
        wl-copy < "$TEMP_FILE"
        notify-send "Screenshot" "Area copied to clipboard"
        ;;
esac
