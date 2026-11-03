# Memoria de Práctica 3: Administración de Sistemas

**Autores:** Javier Valero Fontana (927155) y Pablo Muruzábal Laborda (927819)  
**Asignatura:** Administración de Sistemas  

## Introducción
El script `practica3.sh` automatiza la creación y el borrado de usuarios locales en un sistema Linux a partir de un fichero CSV especificado como parámetro. A continuación, se detallan las decisiones de diseño tomadas para cumplir con todos los requisitos del enunciado.

## Cumplimiento de Requisitos

### 1. Requisitos Generales y Entorno
* **Privilegios de administración (R1):** Se verifica la variable `$EUID`. Si es distinto de 0 (root), el script termina con estado 1 mostrando: *"Este script necesita privilegios de administracion"*.
* **Configuración del entorno (R2):** Se asume que en la máquina virtual el usuario `as` tiene permisos de `sudo` sin contraseña, lo cual permite ejecutar el script ágilmente con `sudo ./practica3.sh`.
* **Automatización total (R15):** El script está diseñado para ejecutarse de forma completamente desatendida, sin requerir confirmaciones.

### 2. Parámetros y Sintaxis
* **Validación de la opción (R3):** Se exige que el primer parámetro sea `-a` o `-s`. Cualquier otra opción redirige el mensaje *"Opción invalida"* a la salida de error estándar (`>&2`).
* **Número de parámetros (R4):** Se comprueba con `"$#"` que haya exactamente 2 argumentos. Si no, muestra *"Número incorrecto de párametros"*.
* **Comandos obligatorios (R11):** Se utilizan los comandos exigidos en el enunciado: `useradd`, `userdel` y `chpasswd`.

### 3. Procesamiento del Fichero y Logs
* **Lectura flexible (R5):** El bucle `while IFS=, read -r user password fullname` está diseñado para leer hasta 3 campos. Para el borrado (`-s`), funciona correctamente aunque la línea solo contenga el nombre de usuario.
* **Fichero de log (R6):** Se define un log dinámico con el formato `YYYY_MM_DD_user_provisioning.log` utilizando `date +"%Y_%m_%d"`. Los nuevos eventos se añaden al final del fichero (`append`) usando `tee -a`.

### 4. Alta de Usuarios (`-a`)
* **Campos vacíos (R9):** Se usa `[ -z ... ]` para verificar que los 3 campos no estén vacíos. Si falta alguno, muestra *"Campo invalido"* y salta a la siguiente línea.
* **Usuario existente (R8):** Se comprueba con `id "$user"`. Si el usuario ya existe, se muestra *"El usuario <nombre de usuario> ya existe"* (registrado también en el log) y se ignora la línea.
* **Creación del usuario (R12, R13, R14):** Se emplea `useradd` con las siguientes banderas:
    * `-U` **(R13):** Crea un grupo con el mismo nombre que el usuario.
    * `-m -k /etc/skel` **(R14):** Crea el directorio home copiando el contenido de `/etc/skel`.
    * `-K UID_MIN=1815` **(R12):** Asegura que el usuario se cree con un UID mayor o igual a 1815.
    * `-c "$fullname"`: Asigna el nombre completo.
* **Contraseña y caducidad (R7):** Se asigna la clave con `echo "$user:$password" | chpasswd`. Posteriormente, `passwd -x 30` establece su caducidad en 30 días. Finalmente se notifica la creación del usuario guardándolo en el log.

### 5. Baja de Usuarios (`-s`)
* **Creación del directorio de backup (R18):** Antes de entrar al bucle, si la opción es `-s`, se ejecuta `mkdir -p /extra/backup` para garantizar que el directorio exista, incluso si luego no se borra a nadie.
* **Usuario inexistente (R10):** Si `id "$user"` indica que el usuario no existe, el script usa `continue` para seguir procesando el fichero sin mostrar nada por pantalla.
* **Copia de seguridad (R17):** Antes de borrar al usuario, se empaqueta su directorio home con `tar -cf /extra/backup/$user.tar /home/$user`, redirigiendo errores a `/dev/null`.
* **Borrado condicional (R19):** Se comprueba la existencia del backup con `[ -e "/extra/backup/$user.tar" ]`. Si el backup no se completó, no se ejecuta el borrado.
* **Borrado completo (R16):** Si el backup es exitoso, se ejecuta `userdel -r "$user"`, lo que elimina tanto al usuario como su directorio home del sistema.

