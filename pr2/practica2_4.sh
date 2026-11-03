#!/bin/bash
#927155, Valero Fontana, Javier, M, 5, A
#927819, Muruzábal Laborda, Pablo, M, 5, A

read -p "Introduzca una tecla: " linea

tecla="${linea:0:1}"

case "$tecla" in
	[a-zA-Z])
		echo "$tecla es una letra"
        ;;
	[0-9])
                echo "$tecla es un numero"
        ;;
	*)
                echo "$tecla es un caracter especial"
	;;
esac
