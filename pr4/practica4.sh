#!/bin/bash
#927155, Valero Fontana, Javier, M, 5, A
#927819, Muruzábal Laborda, Pablo, M, 5, A

# IPs de las maqinas configradas: 192.168.56.10, 192.168.56.11

# R1 y R4: Comprobación de parámetros
if [ "$#" -ne 3 ]; then
    echo "Número incorrecto de parámetros"
    echo "Uso: $0 [-a|-s] <fichero_usuarios> <fichero_máquinas>"
    exit 1
fi

# R3: Validar acción
if [ "$1" != "-a" ] && [ "$1" != "-s" ]; then
    echo "Opción inválida" >&2
    exit 1
fi

# Calculamos la ruta absoluta del script P3 para que sea independiente de donde se lance
SCRIPT_P3="/mnt/windows/uni/UZ_Practicas_AS/src/Pr3/practica3.sh"

ACCION=$1
FILE_USUARIOS=$2
FILE_MAQUINAS=$3
SSH_KEY="$HOME/.ssh/id_as_ed25519"

# Verificar que los ficheros existen
if [ ! -f "$FILE_USUARIOS" ] || [ ! -f "$FILE_MAQUINAS" ]; then
    echo "Error: Uno o ambos ficheros no existen." >&2
    exit 1
fi

FICH_USERS="$(basename "$FILE_USUARIOS")"

# R6: Preparación del log único y local
fecha=$(date +"%Y_%m_%d")
LOG_LOCAL="${fecha}_practica_4.log"


while IFS= read -r IP || [ -n "$IP" ]; do
    [ -z "$IP" ] && continue
    
    # comprobamos si la maqina es accesible. -n para no leer de la entrada estándar, 
    # -o BatchMode=yes para evitar que ssh pida contraseña, -o ConnectTimeout=5 para limitar el tiempo de conexión.
    # -i para especificar la clave SSH, salida de error redirigida parta ocultar mensajes.
    if ! ssh -n -o BatchMode=yes -o ConnectTimeout=5 -i "$SSH_KEY" "as@$IP" exit 2>/dev/null; then
        echo "$IP no es accesible" >&2
        continue
    fi

    if [ "$ACCION" == "-s" ]; then
        ssh -n -i "$SSH_KEY" "as@$IP" "sudo mkdir -p /extra/backup 2>/dev/null"
    fi

    # Subimos el script y el fichero de usuarios
    scp -q -i "$SSH_KEY" "$SCRIPT_P3" "$FILE_USUARIOS" "as@$IP:/tmp/"

    # Ejecutamos y procesamos la salida
    ssh -n -i "$SSH_KEY" "as@$IP" "sudo bash /tmp/practica3.sh $ACCION /tmp/$FICH_USERS" | while read -r linea; do
        if [ -n "$linea" ]; then
            
            ## para que el test vea la salida.
            echo "$linea"
            # Guardar en el log local
            echo "IP:$IP - $linea" >> "$LOG_LOCAL"
        fi
    done
    
    # Limpieza
    ssh -n -i "$SSH_KEY" "as@$IP" "rm -f /tmp/practica3.sh /tmp/$FICH_USERS"
    
done < "$FILE_MAQUINAS"