#!/bin/bash

while (true)
do
#Variables para algunas cosas estéticas
titleback="Proyecto APR"
title="Mysql"
#tamano de las inputbox
input="8 50"
#########################################################################################################
###################################Función mostrarEntidad: Permite escoger de un elemento de toda el gestor mysql
###################################Básicamente, el truco es guardar el contenido de una sentencia sql en una variabe
###################################Y dicho consulta se la podemos pasar por parametro a la funcion
function mostrarEntidad {
while(true)
do
mysql -u$1 -p$2 <<MFI| awk 'NR>1{print $1}'>.tmp.01  
$3
MFI
#crear lista de bases de datos o tablas segun necesidad
lista=$(cat .tmp.01 | awk '{print NR,$0,"OFF"}' )
item=$(dialog --stdout --no-cancel --radiolist "$4" 0 0 0 $lista)
if [ -z $item ];then
dialog --backtitle "$titleback" --title "Seleccion" --sleep 3 --infobox "Por favor seleccione una opcion" 5 30
break
else
#mostrar la seleccion del usuario..
lit=$(cat .tmp.01|awk -v item=$item 'NR==item {print $0}')
break
fi
done
}
 
function mostrarEntidad2 {
while(true)
do
mysql -u$1 -p$2 <<MFI| awk 'NR>1{print $1}'>.tmp.01  
$3
MFI
#crear lista de bases de datos o tablas segun necesidad
lista2=$(cat .tmp.01 | awk '{print NR,$0,"OFF"}' )
item2=$(dialog --stdout --no-cancel --radiolist "$4" 0 0 0 $lista2)
if [ -z $item2 ];then
dialog --backtitle "$titleback" --title "Seleccion" --sleep 3 --infobox "Por favor seleccione una opcion" 5 30
break
else
#mostrar la seleccion del usuario..
lit2=$(cat .tmp.01|awk -v item=$item2 'NR==item {print $0}')
break
fi
done
}
#########################################################################################################
#########################################################################################################

#########################################################################################################
###################################Función hacerSeleccion: Permite hacer una consulta sql a una tabla
###################################seleccionando los campos a usar
function hacerSeleccion {
mysql -u$1 -p$2 <<MFI| awk 'NR>1{print $1}'>.tmp.01  
$3
MFI
lista=$(cat .tmp.01 | awk '{print NR,$0,"OFF"}' )
dialog --separate-output --no-cancel --checklist "Escoga los item a usar en la operación" 0 0 0 $lista 2>.tmp.02
item=1
fin=$(cat .tmp.02|awk 'END {print NR}')
sentencia=$(while(true)
do
lit=$(cat .tmp.02|awk -v item=$item 'NR==item {print $0}')
if [ $item -lt $fin ];then
sentencia=$(cat .tmp.01|awk -v item=$lit 'NR==item {print $0","}')
echo $sentencia
else
sentencia=$(cat .tmp.01|awk -v item=$lit 'NR==item {print $0}')
echo $sentencia
break
fi
item=$(expr $item + 1)
done)
if [ -z "$sentencia" ]
then
sentencia="*"
fi
}
#########################################################################################################
#########################################################################################################

#########################################################################################################
##############################Función hacerConsulta: Permite ejectutar sentencias sql en cualquier parte
function hacerConsulta {
mysql --user="$1" --password="$2" <<MFI
$3
MFI
}
#########################################################################################################
#########################################################################################################

#########################################################################################################
#########################################################################################################
###################################Comienzo de todas las implementaciones

opc=$(dialog --backtitle "$titleback"  --stdout --menu "Bienvenido Usuario $1\n ¿Que desea hacer?" 20 50 12 1 "Crear nueva base de datos:" 2 "Eliminar una base de datos" 3 "Crear nueva tabla" 4 "Eliminar una tabla" 5 "Mostrar bases de datos existentes" 6 "Mostrar tablas de una base de datos" 7 "Realizar consultas de una tabla" 8 "Insertar datos en una tabla" 9 "Salir del sistema") 
case $? in
0)
	case $opc in

########################################### Crear base de dato ###################################################################
#########################################################################################################
	1)
#Evitar que este vacío
while(true);do
temp=$( dialog --stdout --backtitle "$titleback" --no-cancel --inputbox "Ingrese el nombre de la base de datos a crear: " $input )
if [ -z $temp ];then
dialog --backtitle "$titleback" --title "Titulo" --backtitle "$titleback" --sleep 2 --infobox "No escribio nada " 5 30
else
crearba=$temp
break
fi
done
#Llamado a la funcion "Hacer consulta"
base=$(hacerConsulta $1 $2 "show databases;")
if echo $base | grep $crearba 2>/dev/null
then
dialog --backtitle "$titleback" --title "ERROR" --backtitle "$titleback" --sleep 2 --infobox "Ya existe una base de datos con ese nombre" 5 30
else
#Llamado a la funcion "Hacer consulta"
hacerConsulta $1 $2 "create database $crearba;"
dialog --backtitle "$titleback" --title "Felicidades" --backtitle "$titleback" --sleep 2 --infobox "Base de datos creada con exito" 5 30
fi
	;;
########################################### Borrar base de dato ###################################################################
#########################################################################################################
	2)
#Comprobar que haya seleccionado algo
#Llamado a la funcion mostrarEntidad que muestra las tablas existentes
mostrarEntidad $1 $2 "show databases;" "Seleccione la base de datos"
#llamado a la funcion hacer consulta
tablas=$(hacerConsulta $1 $2 "use $lit;show tables;")
if [ -z "$tablas" ];then
hacerConsulta $1 $2 "drop database $lit"
dialog --backtitle "$titleback" --title "Titulo" --backtitle "$titleback" --sleep 2 --infobox "Base de datos borrada con exito" 5 30
else
dialog --backtitle "$titleback" --title "Titulo" --backtitle "$titleback" --sleep 2 --infobox "La Base BDD no se puede borrar poque no esta vacía" 5 30
fi
	;;
########################################### Crear tabla ############################################################################
	3)
a=1
while [ $a -eq 1 ]
do
rm -f creartab.sql
touch creartab.sql
#Llamado a la funcion mostrarEntidad que muestra las tablas existentes
mostrarEntidad $1 $2 "show databases;" "Seleccione la base de datos"
if [ -z $item ]  
then
dialog --backtitle "$titleback" --title "$title" --sleep 3 --infobox "Debe seleccionar una BDD" 0 0
else		   

tabla=$(dialog --stdout --backtitle "$titleback" --title "$title" --no-cancel --inputbox "Ingrese un nombre para la tabla" 0 0)
#verificando que el usuario ingres un nombre para la tabla
if [ -z $tabla ]  #primer if
then
dialog --backtitle "$titleback" --title "$title" --sleep 3 --infobox "Ingrese un nombre para la tabla" 0 0
else

#verificamos si la tabla existe o no
#llamando a la funcion para hacer consulta
tablas=$(hacerConsulta $1 $2 "use $lit;show tables;")
echo $tablas | grep $tabla

			if [ $? -ne 0 ] > /dev/null #apertura del segundo if-------------------------
		   	then

			    cant=$(dialog --stdout --backtitle "$titleback" --title "$title"--no-cancel --inputbox  "cuantos campos tendra" 0 0)
	#validando que ingres datos
	if [ -z $cant ]  #tercer if
	then
	dialog --backtitle "$titleback" --title "$title" --sleep 3 --infobox "No ingreso datos" 0 0
	else
			    echo "create table $tabla (" >> creartab.sql
		          e=1
			  i=1
			    while [ $cant -ge $e ] > /dev/null #apertura del while para campos'''''''''''''''''''
			    do
			    nomcamp=$(dialog --stdout --backtitle "$titleback" --title "$title" --no-cancel --inputbox "Nombre del campo $e: " 0 0)
		if [ -z $nomcamp ]  #if para validar nombre de campo
		then
		dialog --backtitle "$titleback" --title "$title" --sleep 3 --infobox "Debe ingresar un nombre para el campo $e" 0 0
		else
			    lista=$(echo -e "varchar\nint\nchar\ndatetime\nfloat\nstring\ndecimal" | awk '{print NR,$0,"off"}')	
			    tipo=$(dialog --stdout --backtitle "$titleback" --title "$title" --no-cancel --radiolist "tipo de dato: " 0 0 0  $lista)
			    
#verificar que el usuario seleccione una opcion
if [ -z $tipo ]
then
dialog --backtitle "$titleback" --title "$title" --no-cancel --msgbox "Debe seleccionar el tipo de dato" 0 0
e=$(expr $e - 1)				
else
resul=$(echo -e "varchar\nint\nchar\ndatetime\nfloat\nstring\ndecimal" | awk '{print NR,$0,"off"}' | awk -v tip=$tipo 'NR==tip {print $2}')
			#comparar la opcion que selecciono el usuariio
				
			case $resul in
			    "int")
				 if [ $i -eq 1 ] #apertura del tercer if
		        	    then
			            dialog --backtitle "$titleback" --title "$title" --yesno "Sera este campo su llave primaria s/n: " 0 0
			            
				      if [ $? = 0 ] #apertura del cuaro if
				      then
				      echo "$nomcamp $resul Primary key" >> creartab.sql
				      i=2
				      else #else del cuarto if
				      echo "$nomcamp $resul"  >> creartab.sql
				      fi #cierre del cuarto if
			            else #else del tercer if
				    echo "$nomcamp $resul" >> creartab.sql
			            fi	#cierre del tercer if
			     ;;
			     "decimal")
				 tam=$(dialog --stdout --backtitle "$titleback" --title "$title" --no-cancel --inputbox "Tamano1: " 0 0)
				 tam1=$(dialog --stdout --backtitle "$titelback" --title "$title" --no-cancel --inputbox "Tamano2: " 0 0)
				
				    if [ $i -eq 1 ] #apertura del tercer if
		        	    then
			            dialog  --backtitle "$titleback" --title "$title" --yesno "Sera este campo su llave primaria s/n: " 0 0
			            
				      if [ $? = 0 ] #apertura del cuaro if
				      then
				      echo "$nomcamp $resul($tam,$tam1) Primary key" >> creartab.sql
				      i=2
				      else #else del cuarto if
				      echo "$nomcamp $resul($tam,$tam1)"  >> creartab.sql
				      fi #cierre del cuarto if
			            else #else del tercer if
				    echo "$nomcamp $resul($tam,$tam1)" >> creartab.sql
			            fi	#cierre del tercer if
			     ;;
			     *)
			    tam=$(dialog --stdout --backtitle "$titleback" --title "$title" --no-cancel --inputbox "Tamano: " 0 0)
			
			            #Para obtener llave primaria 	
				    	
			            if [ $i -eq 1 ] #apertura del tercer if
		        	    then
			            dialog --backtitle "$titleback" --title "$title" --yesno "Sera este campo su llave primaria s/n: " 0 0
			            
				      if [ $? = 0 ] #apertura del cuaro if
				      then
				      echo "$nomcamp $resul($tam) Primary key" >> creartab.sql
				      i=2
				      else #else del cuarto if
				      echo "$nomcamp $resul($tam)"  >> creartab.sql
				      fi #cierre del cuarto if
			            else #else del tercer if
				    echo "$nomcamp $resul($tam)" >> creartab.sql
			            fi	#cierre del tercer if
				;;
				esac

fi
					#Cierre o separacion de campos en la creacion de tablas
					if [ $e -eq $cant ] #apertura del if quinto
					then
					echo ")" >> creartab.sql
					else #else del quinto if
					echo "," >> creartab.sql
					fi # cierre del quinto if	
				o=2
		   	    	e=$(expr $e + 1 ) #contador
				
			     fi  #cierre if para validar nombre de campo
			    done  #cierre del while de campos'''''''''''''''''''''''''''''''''''''
mysql -u$1 -p$2 $lit < creartab.sql
		if [ $? -eq 0 ]
		then	
			 dialog --backtitle "$titleback" --title "$title" --no-cancel --msgbox "Tabla creada con Exito" 0 0
			a=2
		else
			dialog --backtitle "$titleback" --title "$title" --no-cancel --msgbox "Error parametros no permitidos o campos con el mismo nombre"
			a=2
		fi
		
	fi #cierre tercer if			
			else #else del segundo if----------------------------------------
			 dialog --backtitle "$titleback" --title "$title" --no-cancel --msgbox "Imposible crear, ya existe una tabla con ese nombre" 0 0
			fi #cierre del segundo if----------------------------------------
fi  #cierre primer if
fi 
done
	;;
########################################### Borrar tabla ###########################################################################
#########################################################################################################
	4)
#Inicio Ingresamos datos
dialog --backtitle "$titleback" --title "Por favor" --msgbox "Seleccione la base de datos donde esta la tabla" 5 25
while(true);do
mostrarEntidad $1 $2 "show databases;" "Seleccione base de datos"
temp=$lit
if [ -z $temp ];then
x=1 #solo por poner algo dentro de if
else
base=$lit
dialog --backtitle "$titleback" --title "Por favor" --msgbox "Seleccione la tabla a borrar" 5 25
while(true);do
temp=""
mostrarEntidad2 $1 $2 "use $base;show tables;" "Seleccione una tabla"
temp2=$lit2
if [ -z $temp2 ];then
x=1 #solo por poner algo dentro de if
else
tabla=$lit2
contenido=$(hacerConsulta $1 $2 "use $base;select * from $tabla"|awk 'NR>1 {print $0}')
echo -e "Este es el contenido\n$contenido"
if [ -z $contenido ];then
hacerConsulta $1 $2 "use $base;drop table $tabla"
dialog --backtitle "$titleback" --title "Titulo" --backtitle "$titleback" --sleep 2 --infobox "La tabla fue borrada con exito" 0 0
else
dialog --backtitle "$titleback" --title "Titulo" --backtitle "$titleback" --sleep 2 --infobox "Imposible borrar. La tabla contiene datos" 0 0
fi

break
fi
done

break
fi
done



#Fin Ingresamos datos


	;;
	5)
########################################### Mostrar todas las bases de datos ###########################################################################
#########################################################################################################
hacerConsulta $1 $2 "show databases;"|awk 'NR>1 {print $0}' >.tmp.01
dialog --backtitle "$titleback" --textbox .tmp.01 0 0
	;;
	6)
########################################### Mostrar todas las tablas de una base de datos ###############################################################
#########################################################################################################
#Inicio Ingresamos datos
a=1
while [ $a -eq 1 ]
do
mostrarEntidad $1 $2 "show databases;" "Escoja una base de datos"
if [ -z $item ]
then
a=1
else
hacerConsulta $1 $2 "use $lit;show tables"|awk 'NR>1 {print $0}' >.tmp.01
dialog --backtitle "$titleback" --textbox .tmp.01 0 0
a=2
fi
done
	;;
########################################### Hacer consultas ###############################################################
#########################################################################################################
	7)
#Hacemos que seleccione la base de datos
a=1
while [ $a -eq 1 ]
do
mostrarEntidad $1 $2 "show databases;" "Seleccione la base de datos"
base="$lit"
if [ -z $item ]
then
a=1
else
#Hago que elija tablas, si es que las hay
mostrarEntidad2 $1 $2 "use $base;show tables;" "Base de Datos" tablas
tabla="$lit2"
if [ -z $tabla ];then
x=1 #solo evita que de error en el if else
else
#Seleccionar los campos a usar
dialog --backtitle "$titleback" --title "NOTA" --backtitle "$titleback" --no-cancel --msgbox "En la siguiente pantalla seleccione los campos que desea ver. Para mostralos todos solo presione ENTER" 0 0
hacerSeleccion $1 $2 "use $base;describe $tabla;" 2>>/dev/null
#Realizar la consulta 
hacerConsulta $1 $2 "use $base;select $sentencia from $tabla;">.tmp.01
dialog --backtitle "$titleback" --textbox .tmp.01 20 25 
a=2
fi
fi
done
	;;
########################################### Insertar datos ###############################################################
#########################################################################################################
	8)
a=1
while [ $a -eq 1 ]
do
rm -f .tmp.02
mostrarEntidad $1 $2 "show databases;" "Seleccione la base de datos"
base="$lit"

if [ -z $item ]
then
x=1
else
#Hago que elija tablas, si es que las hay
mostrarEntidad2 $1 $2 "use $base;show tables;" "Base de Datos" tablas
tabla="$lit2"

if [ -z $item2 ]
then
x=1
else
hacerConsulta $1 $2 "use $base;describe $tabla" | awk 'NR>1 {print $1}' >.tmp.01
limite=$(cat .tmp.01 | awk 'END {print NR}')
echo $limite
echo "use $base;insert into $tabla values(" >.tmp.02
conta=1
while [ $conta -le $limite ]
do
echo "Dentro $limite"
campo=$(cat .tmp.01 | awk -v item=$conta 'NR==item {print $1}')
echo $campo
valor=$(dialog --stdout --backtitle "$titleback" --inputbox "Ingrese el valor del campo $campo " $input )
	if [ -z "$valor" ] ;then
	dialog --backtitle "$titleback" --title "Titulo" --backtitle "$titleback" --sleep 2 --infobox "No Selecciono nada" 0 0		
	else
		echo "$valor" >> .tmp.02
		if [ $conta -eq $limite ];then
		echo ")">>.tmp.02 
		else
		echo ",">>.tmp.02
		fi
		conta=$(expr $conta + 1)
	fi
done
mysql -u$1 -p$2 $base < .tmp.02
if [ $? = 0 ];then
dialog --backtitle "$titleback" --title "Titulo" --backtitle "$titleback" --sleep 2 --infobox "Datos ingresados exitosamente" 0 0
a=2
else
dialog --backtitle "$titleback" --title "Titulo" --backtitle "$titleback" --sleep 2 --infobox "Valores no validos" 0 0
fi

fi
fi
done
	;;
########################################### Salir del sistema ###############################################################
#########################################################################################################
	9)
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
	;;
	esac
;;
1)
./Main.sh
;;
esac

done
