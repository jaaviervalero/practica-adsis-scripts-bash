#!/bin/bash
#927155, Valero Fontana, Javier, M, 5, A
#927819, Muruzábal Laborda, Pablo, M, 5, A

if [ "$#" -ne 1 ]; then
	echo "Sintaxis: practica2_3.sh <nombre_archivo>"
else

	if [ -f "$1" ]; then
		chmod ug+x "$1"
		stat -c "%A" "$1"
	else
		echo "$1 no existe"
	fi
fi
