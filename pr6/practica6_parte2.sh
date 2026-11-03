#!/bin/bash
# Práctica 6 parte 2
# 927155, Valero Fontana, Javier, M, 5, A
# 927819, Muruzábal Laborda, Pablo, M, 5, A
#
# Muestra info de discos, particiones y montaje de una máquina remota por SSH.

if [ -z "$1" ]; then
    echo "Uso: $0 <IP_maquina_remota>"
    exit 1
fi

# -T para no abrir terminal interactiva; 'EOF' sin expandir variables locales
ssh -T root@$1 << 'EOF'
    echo "--- Discos duros disponibles (sfdisk -s) ----"
    sfdisk -s

    echo "--- Información de particiones (sfdisk -l) ---"
    sfdisk -l

    echo "--- Información de montaje (df -hT) ---"
    df -hT | grep -v "tmpfs"   # quitamos los sistemas de ficheros en memoria
EOF
