#!/bin/bash
#927155, Valero Fontana, Javier, M, 5, A
#927819, Muruzábal Laborda, Pablo, M, 5, A

#R1
#$EUID = effective user ID, 0 para root
if [ $EUID -ne 0 ]; then
    echo "Este script necesita privilegios de administracion"
    exit 1
fi

#R4
if [ "$#" -ne 2 ]; then
    echo "Número incorrecto de párametros"
    exit 1
fi

#R3
if [ "$1" != "-a" ] && [ "$1" != "-s" ]; then
    echo "Opción invalida" >&2 #Redirige el mensaje de error a stderr
    exit 1
fi

file="$2"

#R6
fecha=$(date +"%Y_%m_%d")
log_file="$fecha"_user_provisioning.log

if [ "$1" == "-s" ]; then
    #-p para crear el directorio padre si no existe
    mkdir -p /extra/backup 2>/dev/null #Redirige el mensaje de error a /dev/null para evitar que se muestre en la consola
fi

#R5
#extraer usuario, contraseña, nombre completo del fichero
while IFS=, read -r user password fullname; do
    if [ "$1" == "-a" ]; then
        #R9
        # -z verifica si la cadena esta vacia
        if [ -z "$user" ] || [ -z "$password" ] || [ -z "$fullname" ]; then
            echo "Campo invalido"
            continue
        fi
        
        #R8
        if  id "$user" &>/dev/null; then
            echo "El usuario $user ya existe" | tee -a "$log_file"  #Redirige el mensaje de error a stdout 
            continue                                                #y lo añade al log. -a append
            
        fi 
        
        #R12, R13, R14
        #-U crea un grupo con el mismo nombre que el usuario, -m crea el directorio home, 
        #-k especifica el esqueleto de archivos para el nuevo directorio home,
        #-c especifica el comentario (nombre completo) para el usuario. -K modifica el /etc/login.defs para establecer 
        #el UID mínimo a 1815, lo que significa que los usuarios creados con este comando tendrán un UID de al menos 1815.
        useradd -U -m -k /etc/skel -K UID_MIN=1815  -c "$fullname" "$user"
        
        #chpasswd lee el nombre de usuario y la contraseña desde la entrada estándar y actualiza la contraseña del usuario correspondiente.
        echo "$user:$password" | chpasswd 
        #R7
        passwd -x 30 "$user" > /dev/null 2>&1 #Redirige la salida estándar y de error a /dev/null para evitar que se muestre en la consola
        echo "$user ha sido creado"| tee -a "$log_file"

    elif [ "$1" == "-s" ]; then
        
        if ! id "$user" &>/dev/null; then
            continue
        fi
        #antes ee borrar el usuario, se hace una copia de seguridad de su directorio home en /extra/backup con el mismo nombre que el usuario.
        tar -cf "/extra/backup/$user.tar" "/home/$user" 2>/dev/null #Redirige el mensaje de error a /dev/null para evitar que se muestre en la consola
        if [ -e "/extra/backup/$user.tar" ]; then
            #R16, -r elimina el home
            userdel -r "$user" 2>/dev/null #Redirige el mensaje de error a /dev/null para evitar que se muestre en la consola
        fi

    fi
done < "$file" #redireccion al fichero de read


