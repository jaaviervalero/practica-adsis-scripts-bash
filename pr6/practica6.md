# Memoria de la Práctica 6: Administración de Sistemas

**Autores (NIP):** 927155, Valero Fontana, Javier; 927819, Muruzábal Laborda, Pablo.

## PARTE I: Discos, Particiones y Montaje

Se trabajó con máquinas virtuales conectadas en una red "Only-Host" de VirtualBox. Se añadió un disco de 32 MiB a través del controlador SATA. Con `parted` se inicializó el disco con una tabla de particiones **GUID** (GPT) y se crearon dos particiones de 16 MiB asegurando el alineamiento óptimo (parted avisa con *"is the partition not optimally aligned"* en caso de problema; bastó con dejarle elegir los sectores). A continuación, con `mkfs.ext3` y `mkfs.ext4` se formatearon las particiones con los tipos de sistema de ficheros pedidos.

**Comprobación del montaje:** primero se montaron manualmente con `mount /dev/sdb1 /mnt/p1` y análogo para la segunda, y se inspeccionó `/etc/mtab`, que listaba ambas entradas con el tipo correcto. Después se añadieron en `/etc/fstab` mediante UUID (`blkid` para obtenerlos) con opciones `defaults 0 2`. Tras reiniciar la máquina, `df -h` mostraba las dos particiones automáticamente montadas, confirmando la persistencia.

## PARTE II: Script de Información Remota

`practica6_parte2.sh` recibe la IP de la máquina remota como parámetro. Tras validar el argumento, abre una conexión SSH como `root` con la opción **`-T`** (deshabilita la asignación de pseudo-terminal, innecesaria al no haber interacción) y envía los comandos mediante un *here-document* cuyas comillas simples `'EOF'` evitan que el shell local expanda variables: los comandos llegan literalmente al equipo remoto. Se imprimen:

1. Discos disponibles con `sfdisk -s` (tamaños en bloques de 1 KiB).
2. Tabla detallada de particiones con `sfdisk -l`.
3. Información de montaje con `df -hT` filtrando `tmpfs` mediante `grep -v` (`-h` legible, `-T` añade el tipo de FS).

Para automatizar la práctica conviene tener configurada autenticación por clave pública y permitir el login `root` por SSH.

## PARTE III: Gestión de Volúmenes Lógicos (LVM)

Se instaló `lvm2` y se verificó con `systemctl list-units` que `lvm2-monitor.service` y `lvm2-lvmpolld.socket` estaban activos. Se añadió un nuevo disco a la VM y con `parted` se creó una partición que ocupa todo el espacio con el flag *Linux LVM* activado (`set 1 lvm on`). Sobre ella se inicializó el VG `vg_p6` con `pvcreate` + `vgcreate`.

### `practica6_parte3_vg.sh`

Recibe como primer parámetro el nombre del VG y como restantes las particiones a añadir. Tras validar que hay al menos 2 argumentos, ejecuta `shift` para que `"$@"` contenga sólo particiones, llama a `pvcreate -y "$@"` (la opción `-y` confirma cualquier aviso y `2>/dev/null` permite reejecuciones idempotentes si los PV ya existían) y finalmente `vgextend "$VG" "$@"`, mostrando el estado con `vgdisplay`.

- **¿Por qué desmontar antes?** `pvcreate` reescribe los metadatos al inicio de la partición, destruyendo el superbloque del FS. Si la partición está montada, el kernel impide la operación para evitar corrupción de datos en uso. Por eso se desmontan las particiones de la Parte I antes de incorporarlas al VG.
- **Número de PVs resultante:** `vg_p6` partía con 1 PV (el disco LVM). Al añadir las 2 particiones de la Parte I el VG queda con **3 volúmenes físicos**.

### `practica6_parte3_lv.sh`

Lee de stdin líneas con formato `VG,LV,tamaño,FS,montaje`. Para cada línea: separa campos con `IFS=','` y `read -r`, limpia espacios con `xargs`, descarta líneas incompletas y comprueba con `lvdisplay` si el LV ya existe.

- **Existe** → `lvextend -L <tam> -r` ajusta el tamaño y redimensiona el FS online.
- **No existe** → `lvcreate -n <LV> -L <tam>` crea el LV, `mkfs -t <FS>` lo formatea, `mkdir -p` crea el punto de montaje, se añade `"/dev/VG/LV  <montaje>  <FS>  defaults  0  2"` a `/etc/fstab` (campos idénticos al resto de líneas con LVs) y se monta con `mount <LV_PATH>` (toma las opciones de fstab).

**Invocación de prueba:** se envió la especificación por entrada estándar mediante un *pipe*:

```
echo "vg_p6,lv_prueba,10M,ext4,/mnt/prueba" | ./practica6_parte3_lv.sh
```

Se comprobó con `lvdisplay /dev/vg_p6/lv_prueba`, `grep lv_prueba /etc/fstab` y `df -hT` que el LV se creó, se persistió en fstab y quedó montado. Una segunda invocación con tamaño `20M` activó la rama de extensión: `lvextend -r` redimensionó LV y FS sin desmontar.
