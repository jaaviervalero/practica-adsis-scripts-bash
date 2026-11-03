#!/bin/bash
# Práctica 6 parte 3 vg
# 927155, Valero Fontana, Javier, M, 5, A
# 927819, Muruzábal Laborda, Pablo, M, 5, A
#
# Añade una o más particiones a un VG existente.
# Uso: $0 <nombre_VG> <particion1> [particion2 ...]

if [ "$#" -lt 2 ]; then
    echo "Error. Uso: $0 <nombre_GrupoVolumen> <particion1> [particion2 ...]"
    exit 1
fi

VG_NAME=$1
shift   # dejamos en $@ solo las particiones

pvcreate -y "$@" 2>/dev/null   # 2>/dev/null por si alguna ya estaba inicializada

vgextend "$VG_NAME" "$@"

vgs "$VG_NAME"
