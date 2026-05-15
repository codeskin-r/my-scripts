#!/usr/bin/env bash

PID_FILE="/tmp/gpu_rec.pid"
SAVE_DIR="$HOME/Videos/Recordings"
mkdir -p "$SAVE_DIR"

# --- TOGGLE: DETENER SI YA EXISTE ---
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null; then
        kill -INT "$PID"
        rm "$PID_FILE"
        notify-send "Grabador" "Grabación finalizada correctamente." -a "System"
        exit 0
    else
        rm "$PID_FILE"
    fi
fi

# --- PREPARACIÓN ---
FILENAME="$SAVE_DIR/rec_$(date +%Y%m%d_%H%M%S).mp4"
AUDIO_DEV=$(pactl get-default-sink).monitor

notify-send "Grabador" "Selecciona el área para grabar" -a "System"

# Capturamos la región con slurp
RAW_REGION=$(slurp)

if [ -z "$RAW_REGION" ]; then
    exit 1
fi

# TRADUCTOR: Convierte "X,Y WxH" a "WxH+X+Y"
REGION=$(echo "$RAW_REGION" | sed -r 's/([0-9]+),([0-9]+) ([0-9]+x[0-9]+)/\3+\1+\2/')

# --- EJECUCIÓN (Ajuste de flags según el error) ---
# Cambiamos -w "screen" por -w "region"
gpu-screen-recorder -w "region" \
                    -region "$REGION" \
                    -f 60 \
                    -a "$AUDIO_DEV" \
                    -o "$FILENAME" &

echo $! > "$PID_FILE"
