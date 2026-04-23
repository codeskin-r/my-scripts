#!/bin/bash

ISO="$1"

# Validación básica
[ -z "$ISO" ] && echo "Uso: iso-toggle.sh archivo.iso" && exit 1

# Buscar loop asociado
LOOP=$(losetup -j "$ISO" | cut -d: -f1)

if [ -n "$LOOP" ]; then
  # Ya existe → desmontar
  MOUNTPOINT=$(lsblk -no MOUNTPOINT "$LOOP")

  if [ -n "$MOUNTPOINT" ]; then
    sudo umount "$MOUNTPOINT" && notify-send "ISO desmontada" "$MOUNTPOINT"
    sudo losetup -d "$LOOP"
    [ -d "$MOUNTPOINT" ] && sudo rmdir "$MOUNTPOINT"
  else
    notify-send "ISO" "Loop existe pero no está montado"
  fi

else
  # No existe → montar
  LOOP=$(sudo losetup --find --show "$ISO")

  NAME=$(basename "$ISO" .iso)
  MNT="/mnt/$NAME"

  sudo mkdir -p "$MNT"

  if sudo mount "$LOOP" "$MNT"; then
    notify-send "ISO montada" "$MNT"

    # Abrir en Dolphin
    if command -v dolphin >/dev/null 2>&1; then
      dolphin "$MNT" >/dev/null 2>&1 &
    else
      xdg-open "$MNT"
    fi
  else
    notify-send "Error" "No se pudo montar"
    sudo losetup -d "$LOOP"
  fi
fi
