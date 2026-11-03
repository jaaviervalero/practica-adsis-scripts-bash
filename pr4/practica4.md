# Administración de Sistemas - Memoria Práctica 4

Javier Valero Fontana, 927155
Pablo Muruzábal Laborda, 927819

## 1. Preparación de las Máquinas Virtuales

Para el desarrollo de la práctica, se han desplegado dos máquinas virtuales (`debian-as1` y `debian-as2`). Estas máquinas se han configurado compartiendo el disco duro virtual con la máquina base de la asignatura, optimizando así el espacio de almacenamiento. Además, a la interfaz de red por defecto se le ha añadido un segndo adaptador virtual para una red host only, con las características especificada sen el guión.

## 2. Configuración de Red y Privilegios

En cada una de las máquinas virtuales se han realizado las siguientes configuraciones de sistema:

- **Configuración de Interfaces:** Se ha editado el fichero `/etc/network/interfaces` para levantar automáticamente las tarjetas de red en el arranque. Se han configurado las interfaces conectadas a la red "Host-Only" asignándoles las direcciones IP estáticas `192.168.56.10` y `192.168.56.11`.
- **Elevación de Privilegios:** Accediendo como usuario `root` y utilizando el editor seguro `visudo`, se ha añadido la directiva correspondiente para permitir al usuario `as` ejecutar comandos con privilegios administrativos (`sudo`) sin necesidad de introducir su contraseña.

## 3. Instalación y Securización de SSH

Para asegurar la administración remota desde la máquina host mediante el script automatizado:

- Se instaló el servicio `openssh-server` en ambas máquinas virtuales.
- Editando el fichero de configuración `/etc/ssh/sshd_config` y modificando el parámetro `PermitRootLogin no` se impidió el inicio de sesión remoto directo del superusuario.
- Se configuró la infraestructura de autenticación basada en criptografía de clave pública. Se generó un par de claves de tipo `ed25519` en la máquina host y se transfirió la clave pública al usuario `as` de las máquinas virtuales, permitiendo la conexión remota automática y sin contraseña.

```bash
# Generación del par de claves en el host (tipo ed25519)
ssh-keygen -t ed25519 -f ~/.ssh/id_as_ed25519

# Transferencia de la clave pública a las máquinas virtuales
ssh-copy-id -i ~/.ssh/id_as_ed25519.pub as@192.168.56.10
ssh-copy-id -i ~/.ssh/id_as_ed25519.pub as@192.168.56.11
```

## 4. Desarrollo del Script de Administración Remota (`practica_4.sh`)

El script principal se ha diseñado para automatizar la ejecución de la lógica de gestión de usuarios (desarrollada en la Práctica 3) sobre un conjunto de máquinas remotas. Los aspectos técnicos más relevantes son:

- **Gestión de Parámetros**: El script recibe obligatoriamente tres parámetros: la acción (`-a` o `-s`), el fichero con la lista de usuarios y el fichero con las direcciones IP de las máquinas destino..
- **Uso Avanzado de SSH**:
  - Se emplea el flag `-n` en los comandos `ssh`. Esto es crítico para evitar que el comando remoto consuma la entrada estándar (`stdin`) del bucle `while` principal, lo que interrumpiría la lectura del fichero de máquinas tras la primera iteración.
  - Se utiliza `BatchMode=yes` y `ConnectTimeout=5` para que el script detecte rápidamente máquinas no accesibles sin quedarse bloqueado, cumpliendo con el requisito de mostrar el mensaje "no es accesible".

## 5. Gestión de Logs Centralizada

A diferencia de la práctica anterior, la trazabilidad de las acciones se centraliza en la máquina host donde se ejecuta el script:

- **Formato de Log**: Cada entrada en el fichero de registro sigue el patrón `IP:$IP - mensaje`, permitiendo ver en qué maquina se realizó cada acción.
- **Captura de Salida**: El script captura la salida estándar (`stdout`) generada por la ejecución remota de `practica3.sh` mediante una tubería (`|`), procesando cada línea para escribirla simultáneamente en el log local y mostrarla por pantalla para el administrador.

## 6. Otras consideraciones

Al ejecutar los scripts de prueba desde nuestro host, intentaba acceder a las máquinas remotas usando el usuario del host en vez de el previsto (`as`) en algunos test. También, nos seguía pidiendo contraseña en los test, pues en los ocmandos `ssh` de estos no se incluye la opcion `-i`. Para solventarlo se editó el fichero `~/.ssh/config` añadiendo lo siguiente:

```bash
Host 192.168.56.10 192.168.56.11
    User as
    IdentityFile ~/.ssh/id_as_ed25519
```

## 6. Conclusiones

La realización de esta práctica demuestra la potencia de SSH como herramienta de orquestación. La capacidad de inyectar scripts locales en máquinas remotas y centralizar la gestión de errores y logs permite administrar infraestructuras de forma escalable. Se ha verificado que una correcta gestión de las claves criptográficas y una configuración robusta de los privilegios de `sudo` son pilares fundamentales para la administración segura de sistemas Linux.
