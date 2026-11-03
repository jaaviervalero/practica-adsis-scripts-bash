#!/bin/bash
#927155, Valero Fontana, Javier, M, 5, A
#927819, Muruzábal Laborda, Pablo, M, 5, A

directorios=$(ls -d "$HOME"/bin??? 2>/dev/null)

if [ -z "$directorios" ]; then
    dest_dir=$(mktemp -d "$HOME"/binXXX)
    echo "Se ha creado el directorio $dest_dir"
else
    dest_dir=$(stat -c "%Y %n" "$HOME"/bin??? 2>/dev/null | sort -n | head -n 1 | cut -d ' ' -f 2-)
fi

echo "Directorio destino de copia: $dest_dir"

contador=0

for fichero in ./*; do
    if [ -e "$fichero" ] && [ -f "$fichero" ] && [ -x "$fichero" ]; then
        cp "$fichero" "$dest_dir"
        echo "$fichero ha sido copiado a $dest_dir"
        ((contador++))
    fi
done

# 4. Resumen final según la cantidad de ficheros copiados
if [ "$contador" -eq 0 ]; then
    echo "No se ha copiado ningun archivo"
else
    echo "Se han copiado $contador archivos"
fi