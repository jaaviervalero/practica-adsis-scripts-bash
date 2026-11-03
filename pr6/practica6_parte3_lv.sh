#!/bin/bash
# Práctica 6 parte 3 lv
# 927155, Valero Fontana, Javier, M, 5, A
# 927819, Muruzábal Laborda, Pablo, M, 5, A
#
# Lee de stdin líneas "VG,LV,tamaño,tipoFS,dirMontaje" y crea o extiende el LV.

while IFS=',' read -r VG LV SIZE FSTYPE MOUNT; do
    if [ -n "$VG" ]; then
        LV_PATH="/dev/$VG/$LV"

        if lvs "$LV_PATH" &>/dev/null; then
            lvextend -L "$SIZE" -r "$LV_PATH"
        else
            lvcreate -y -n "$LV" -L "$SIZE" "$VG"
            mkfs -t "$FSTYPE" "$LV_PATH"
            mkdir -p "$MOUNT"
            echo "$LV_PATH $MOUNT $FSTYPE defaults 0 2" >> /etc/fstab
            mount "$LV_PATH"
        fi
    fi
done
