#!/bin/bash
#927155, Valero Fontana, Javier, M, 5, A
#927819, Muruzábal Laborda, Pablo, M, 5, A

echo -n "Introduzca el nombre del fichero: "
read fichero

if [ ! -e "$fichero" ]; then
    echo "$fichero no existe"
else

    permisos=""
    if [ -r "$fichero" ]; then
        permisos="${permisos}r"
    else
        permisos="${permisos}-"
    fi
    
    if [ -w "$fichero" ]; then
        permisos="${permisos}w"
    else
        permisos="${permisos}-"
    fi
    
    if [ -x "$fichero" ]; then
        permisos="${permisos}x"
    else
        permisos="${permisos}-"
    fi
    
    echo "Los permisos del archivo $fichero son: $permisos"
fi
