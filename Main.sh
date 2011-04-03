#!/bin/bash

#Variables para algunas cosas estéticas
titleback="Proyecto APR"
#tamano de las inputbox
input="8 50"
while('true')
do

user=$( dialog --stdout --backtitle "$titleback"  --inputbox "Ingrese su nombre de usuario" $input )
if [ $? -ne 0 ]
then
dialog  --backtitle "$titleback" --yesno "Desea salir del programa" $input
	if [ $? -eq 0 ]
	then
(x=0
while [ $x -le 100 ]
do
echo $x
x=$( expr $x + 10 )
sleep 1
done
)| dialog --gauge "...Cerrando el programa..." 0 0
dialog --backtitle "$titleback" --title "Adios" --backtitle "$titleback" --sleep 2 --infobox "Muchas gracias por haber usado nuestro sistema" 0 0
	clear
	exit
	else
	x=1
	fi
else
if [ -z $user ]
then
dialog  --backtitle "$titleback" --sleep 3 --infobox "Completes los datos para poder ingresar" $input
else
contra=$( dialog --stdout --backtitle "$titleback" --inputbox "Ingrese su contraseña" $input )
if [ $? -ne 0 ]
then
dialog  --backtitle "$titleback" --yesno "Desea salir del programa" $input
	if [ $? -eq 0 ]
	then
(x=0
while [ $x -le 100 ]
do
echo $x
x=$( expr $x + 10 )
sleep 1
done
)| dialog --gauge "...Cerrando el programa..." 0 0
dialog --backtitle "$titleback" --title "Adios" --backtitle "$titleback" --sleep 2 --infobox "Muchas gracias por haber usado nuestro sistema" 0 0
	clear
	exit
	else
	x=1
	fi
else
if [ -z $contra ]
then
dialog  --backtitle "$titleback" --sleep 3 --infobox "Completes los datos para poder ingresar" $input
else
base=$(	mysql -u"$user" -p"$contra" <<MFI
select 1+1 as resul
MFI
)
estado=$?
	case $estado in
	0) 
opc1=$( dialog --backtitle "$titleback" --no-cancel --stdout --menu "Bienvenido Usuario $user\n ¿Como desea usar esta interfaz?" 15 40 7 1 "Modo Gráfico" 2 "Modo consola" )

		case $opc1 in
		1)
		./ModoGrafico.sh "$user" "$contra"
		;;
		2)
		./ModoTexto.sh "$user" "$contra"
		;;
		esac

	;;
	1) 
dialog  --backtitle "$titleback" --sleep 3 --infobox "Nombre o Contraseña incorrecta" $input
	;;
	esac
	fi
	fi
fi
fi
done

