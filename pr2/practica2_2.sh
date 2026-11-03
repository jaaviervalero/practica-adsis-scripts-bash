#!/bin/bash
#927155, Valero Fontana, Javier, M, 5, A
#927819, Muruzábal Laborda, Pablo, M, 5, A

for file in "$@"
do
	if  [ -f "$file" ]; then
		more "$file"
	else
		echo "$file no es un fichero"
	fi
done

