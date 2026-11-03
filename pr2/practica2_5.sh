#!/bin/bash
#927155, Valero Fontana, Javier, M, 5, A
#927819, Muruzábal Laborda, Pablo, M, 5, A

read -p "Inroduzca el nombre de un directorio: " dir

if [ ! -d "$dir" ]; then
	echo "$dir no es un directorio"
else
	num_files=$(ls -lA "$dir" 2>/dev/null | grep  "^-" | wc  -l)
	num_dirs=$(ls -lA "$dir" 2>/dev/null | grep "^d" | wc -l)
	echo "El numero de ficheros y directorios en $dir es de $num_files y $num_dirs, respectivamente"
fi
