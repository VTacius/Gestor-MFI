#!/bin/bash
clear


while (true)
do 

user=$1
pass=$2
echo -n "mysql> "
read accion
cam=$(echo $accion |awk '{print NF}')
cam1=$(echo $accion | awk '{print $1}') 
cam2=$(echo $accion | awk '{print $2}')
cam3=$(echo $accion | awk '{print $3}')
cam4=$(echo $accion | awk '{print $4}')
quitarpuntoycoma=$(echo $accion | awk  -v w="$cam" '{print $w}' | awk -F";" '{print $1}')
ultimo=$(echo $accion | awk -v fin="$cam" '{print $fin}')
campo=$(echo $accion | awk -F"select" '{print $2}')
campos=$(echo $campo | awk -F"from" '{print $1}')
ultimo2=$(echo $accion | awk -F";" '{print $1}')


#################################CREATE DATABASE O TABLE###########################################################################################
###################################################################################################################################################

#comparamos el primer campo en la variable cam1   
case $cam1 in  #Apertura primer case_______________________________________
     "create"|"CREATE")
          #verificamos que tenga solo tres campos sino msql no lo aceptara.	
	  if [ $cam -eq 3 ] 2> /dev/null  #apertura primer if--------------
	  then
	  #comparamos segundo campo
	  case $cam2 in   #apertura de segundo case_________________________
	       "database"|"DATABASE")

#verificamos si la base de datos existe o no
mysql -u$user -p$pass <<IN | grep $quitarpuntoycoma > /dev/null
show databases;
IN

		    if [ $? -ne 0 ]  #apertura segundo if -----------
		    then
#si no existe la base se crea
mysql -u$user -p$pass <<IN
create database $quitarpuntoycoma;
IN
		    echo "La base de datos fue creada con exito"
		    else      #else segundo if---------------------------------
		    echo " La base de datos no se puede crear porque ya existe"
		    sleep 2
		    fi #cierre del segundo if----------------------------------
	
	
	       ;;

	       "table"|"TABLE")
	    	    rm -f creartab.sql
		    echo -n "Ingrese el nombre de la DDB a la cual desea agregar la tabla: "
		    read base
#Verificamos si la base de datos existe o no
mysql -u$user -p$pass <<IN | grep $base > /dev/null
show databases;
IN
		   
		   if [ $? -eq 0 ] > /dev/null #apertura del tercer if------------------------------
		   then
#verificamos si la tabla existe o no
mysql -u$user -p$pass $base <<IN | grep $quitarpuntoycoma > /dev/null
show tables;
IN
			if [ $? -ne 0 ] > /dev/null #apertura del cuarto if-------------------------
		   	then
			    	
			    echo -ne "cuantos campos tendra: "
			    read cant
			    echo "create table $quitarpuntoycoma (" >> creartab.sql
		          e=1
			  i=1
			    while [ $cant -ge $e ] > /dev/null #apertura del while para campos'''''''''''''''''''
			    do
				echo ""
			        echo -n "campo $e: "
		        	read nomcamp
				
				o=1
				while [ $o -eq 1 ] #apertura del while para tipo de dato'''''''''''''''''''''''''
				do
	
			        echo -n "tipo de dato: "
			        read tipo

				case $tipo in #apertura del tercer case__________________________________________

				"varchar"|"VARCHAR"|"int"|"INT"|"datetime"|"DATETIME"|"char"|"CHAR"|"float"|"FLOAT"|"decimal"|"DECIMAL"|"string"|"STRING")
				  #si es entero no pregunta tamaño
				  if [ "$tipo" == "INT" -o "$tipo" == "int" ]
				  then
	
			            #Para obtener llave primaria 	
				    	
			            if [ $i -eq 1 ]
		        	    then
			            echo -n "Sera este campo su llave primaria s/n: "	
			            read llave
				      if [ "$llave" = "s" ]
				      then
				      echo "$nomcamp $tipo Primary key" >> creartab.sql
				      i=2
				      else
				      echo "$nomcamp $tipo "  >> creartab.sql
				      fi
			            else
				    echo "$nomcamp $tipo" >> creartab.sql
			            fi
				#se es decimal pregunta dos tamaños
				  elif [ "$tipo" = "DECIMAL" -o "$tipo" = "decimal" ]
				  then
				echo -n "tamano 1: "
			        read tam
				echo -n "tamaño 2: "
				read tam1
	
			            #Para obtener llave primaria 	
				    	
			            if [ $i -eq 1 ]
		        	    then
			            echo -n "Sera este campo su llave primaria s/n: "	
			            read llave
				      if [ "$llave" = "s" ]
				      then
				      echo "$nomcamp $tipo($tam,$tam1) Primary key" >> creartab.sql
				      i=2
				      else
				      echo "$nomcamp $tipo($tam,$tam1)"  >> creartab.sql
				      fi
			            else
				    echo "$nomcamp $tipo($tam,$tam1)" >> creartab.sql
				    fi
		##############sino pregunta un tamaño
				  else
				echo -n "tamano: "
			        read tam
	
			            #Para obtener llave primaria 	
				    	
			            if [ $i -eq 1 ]
		        	    then
			            echo -n "Sera este campo su llave primaria s/n: "	
			            read llave
				      if [ "$llave" = "s" ]
				      then
				      echo "$nomcamp $tipo($tam) Primary key" >> creartab.sql
				      i=2
				      else
				      echo "$nomcamp $tipo($tam)"  >> creartab.sql
				      fi
			            else
				    echo "$nomcamp $tipo($tam)" >> creartab.sql

				  fi	
				fi
					#Cierre o separacion de campos en la creacion de tablas
					if [ $e -eq $cant ] 
					then
					echo ")" >> creartab.sql
					else
					echo "," >> creartab.sql
					fi	
				o=2
		   	    	e=$(expr $e + 1 ) #contador
			       ;;
			       *)echo "tipo de dato erroneo...solo se permite"
				 echo "varchar,int,decimal,datetime,float,char,string"
				 o=1
				 sleep 2
			       ;;
			       esac #cierre del segundo case
			       done #cierre del while de tipo de datos'''''''''''''''''''''''''''''''''''
			    done  #cierre del while de campos'''''''''''''''''''''''''''''''''''''
mysql -u$1 -p$2 $base < creartab.sql
			echo "Tabla $quitarpuntoycoma creada con exito"
			sleep 3
			else #else del cuarto if----------------------------------------
			echo "Imposible crear, ya existe una tabla con ese nombre"
			sleep 2
			fi #cierre del cuarto if----------------------------------------

		   else #else del tercer if---------------------------------------------
		   echo "La base de datos no existe... verifique el nombre"
  		   sleep 2
		   fi #cierre del tercer if---------------------------------------------
	     ;;
	     
	     *)echo "Solo se pueden crear tablas y bases de datos"	
	     ;;
	     esac

	  else	# Else primer if--------------------------------------------------------
	  echo "error de sintaxis... no deve haber espacios en blanco en el nombre de la tabla o base de datos"
		 sleep 2
	  fi      #cierre primer if-----------------------------------------------------

     ;;

########################################### SHOW DATABASE O TABLE  ########################################################################################
###########################################################################################################################################################


     "show"|"SHOW")

          #verificamos que tenga solo dos campos sino mysql no lo aceptara.     
          if [ $cam -eq 2 ] 2> /dev/null  #apertura primer if---------------------
          then
          #comparamos segundo campo
          case $quitarpuntoycoma in   #apertura de primer case de show_________________________
               "databases"|"DATABASES")
echo ""

mysql -u$1 -p$2 <<IN  
show databases;
IN
sleep 3

		;;
		"tables"|"TABLES")
		echo -n "ingrese el nombre de la BDD para poder ver sus tablas: "
		read base

#verificamos si la base de datos existe o no
mysql -u$1 -p$2 <<IN | grep $base > /dev/null
show databases;
IN

                    if [ $? -eq 0 ]  #apertura segundo if -------------------------
                    then
echo ""
mysql -u$1 -p$2 $base  <<IN  
show tables;
IN
sleep 3
		    else
		    echo "La base de datos no existe"
		    fi #cierre del segundo if de show------------------------------

		;;
		*)echo " error de sintaxis...."
		sleep 2
		;;
	  esac #cierre del primer case de show_____________________________________

 	 else #else primer if------------------------------------------------------
	 echo "error de sintaxis"
	 sleep 2
	 fi #cierre primer if------------------------------------------------------


     ;;


################################## DROP DATABASE O TABLA ##############################################################################################
#######################################################################################################################################################


     "drop"|"DROP")

		
          #verificamos que tenga solo tres campos sino msql no lo aceptara.     
          if [ $cam -eq 3 ] 2> /dev/null  #apertura primer if---------------------
          then
          #comparamos segundo campo
          case $cam2 in   #apertura de primer case de drop_________________________
               "database"|"DATABASE")


#verificamos si la base de datos existe o no
mysql -u$1 -p$2 <<IN | grep $quitarpuntoycoma > /dev/null
show databases;
IN

                    if [ $? -eq 0 ]  #apertura segundo if -------------------------
                    then

#verficando si base de datos esta vacia
mysql -u$1 -p$2 $quitarpuntoycoma <<IN  > muestra.txt
show tables;
IN
bases=$(cat muestra.txt | awk 'END {print NR}')


			if [ "$bases" -eq 0 ] #apertura tercer if------------------
			then
#eliminacion de bases
mysql -u$1 -p$2 <<IN
drop database $quitarpuntoycoma;
IN

			echo "base eliminada con exito"
			sleep 2
			else # else del tercer if----------------------------------
			echo "la base no se puede eliminar porque contiene tablas"
			sleep 2
			fi #cierre del tercer if

		    else #else del segundo if-------------------------------------- 
			echo " no existe una base da datos con ese nombre"
			sleep 2
		    fi

                ;;
                "table"|"TABLE")
                echo -n "ingrese el nombre de la BDD donde esta la tabla ha eliminar: "
                read base

#verificamos si la base de datos existe o no
mysql -u$1 -p$2 <<IN | grep $base > /dev/null
show databases;
IN

                    if [ $? -eq 0 ]  #apertura cuarto if -------------------------
                    then
#verificamos si la tabla existe o no
mysql -u$1 -p$2 $base <<IN | grep "$quitarpuntoycoma" > /dev/null
show tables;
IN
    if [ $? -eq 0 ] > /dev/null #apertura if 4 y 1/2
    then
#verificar si la tabla esta vacia
mysql -u$1 -p$2 $base  <<IN  > muestra.txt
select * from $quitarpuntoycoma;
IN
bases=$(cat muestra.txt | awk 'END {print NR}')

                        if [ "$bases" -eq 0 ] #apertura quinto if------------------
                        then
#eliminacion de tabla
mysql -u$1 -p$2 $base  <<IN 
drop table $quitarpuntoycoma;
IN

                        echo "tabla eliminada con exito"
                        sleep 2
                        else # else del quinto if----------------------------------
                        echo "la tabla no se puede eliminar porque contiene registros"
                        sleep 2
                        fi #cierre del quinto if
    else  # else  if 4 y 1/2
    echo "La tabla no existe"
    fi  # cierrre de  if 4 y 1/2

                    else
                    echo "La base de datos no existe"
                    fi #cierre del cuarto if de show------------------------------

                ;;
                *)echo " error de sintaxis...."
                sleep 2
                ;;
          esac #cierre del primer case de drop_____________________________________

         else #else primer if------------------------------------------------------
         echo "error de sintaxis"
         sleep 2
         fi #cierre primer if------------------------------------------------------

     ;;


############################################## INSERT DATOS ########################################################################################################
#######################################################################################################################################################

     "insert"|"INSERT")

case $cam2 in #apertura 
	"INTO"|"into")

echo -n "digite el nombre de la BDD en la cual insertara los datos: "
read base
#verificamos si la base de datos existe o no
mysql -u$1 -p$2 <<IN | grep $base> /dev/null
show databases;
IN
if [ $? -eq 0 ] > /dev/null #if uno
then
#verificamos si existe la tabla
mysql -u$1 -p$2 $base <<IN | grep $cam3 > /dev/null
show tables;
IN

	if [ $? -eq 0 ] > /dev/null #apertura if dos 
	then
	if [ "$cam4" = "VALUES" -o "$cam4" = "values" ] >/dev/null #apertura if tres
	then
	echo $accion | grep "(" > /dev/null
	
		if [ $? -eq 0 ] > /dev/null #apertura if cuatro
		then
         echo $accion | grep ")" > /dev/null
		if [ $? -eq 0 ] > /dev/null #apertura if cinco
		then


mysql -u$1 -p$2 $base <<IN 2>/dev/null
$ultimo2;
IN
			if [ $? -eq 0 ] > /dev/null #if seis
			then
			  echo "Datos insertados con exito"
			  sleep 3
			else
			  echo "Los datos no son validos en esta tabla o ya existen"
			  sleep 3
			fi #fin if seis
			
		else
		  echo "Error se esperaba parentesis )"
		fi #fin if cinco
		else 
		  echo "Error se esperaban parentesis ("
		  sleep 3
		fi #fin if cuatro
	else
	echo "Error use 'values'"
	 sleep 3
	fi #fin if tres
	else
	 echo "No existe una tabla con ese nombre"
	 sleep 3
	fi # fin if dos
else
echo "La base de datos no existe"
fi #fin if uno
	;;
	*)echo "Error de sintaxis se esperaba 'into' "
	  sleep 3
	;;
esac

     ;;

########################################################################################################################################################

     "SELECT"|"select")
     
if [ "$cam2" = "." ] >/dev/null #primer if
then
  if [ "$cam3" = "FROM" -o "$cam3" = "from" ] > /dev/null #segundo if
  then
echo -n "Ingrese el nombre de la BDD donde esta la tabla: "
read base
#verificando si la base existe
mysql -u$user -p$pass  <<IN | grep "$base" > /dev/null
show databases;
IN
	if [ $? -eq 0 ] > /dev/null #tercer if
	then
#verificando si la tabla existe
mysql -u$user -p$pass "$base" <<IN | grep "$quitarpuntoycoma" >/dev/null
show tables;
IN
	    if [ $? -eq 0 ] > /dev/null # cuarto if
	    then

mysql -u$user -p$pass "$base" <<IN 2> muestra.txt
select * from $quitarpuntoycoma;
IN
echo ""
cat muestra.txt
sleep 3

	    else
	    echo "Lo sentimos no existe una tabla con ese nombre"
	    sleep 3
	    fi  #cierre cuarto if

	else
	echo "La base de datos no existe"
	sleep 3
	fi  #cierre tercer if

   else
   echo "Se esperaba 'from'"
   sleep 3
   fi  #cierre segundo if

################################3
else

echo -n "Ingrese el nombre de la BDD donde esta la tabla: "
read base
#verificando si la base existe 
mysql -u$user -p$pass <<IN | grep "$base" > /dev/null
show databases;
IN
	if [ $? -eq 0 ] > /dev/null #if uno del else
	then

#verificando si la tabla existe
mysql -u$user -p$pass "$base" <<IN | grep "$quitarpuntoycoma" >/dev/null
show tables;
IN
	    if [ $? -eq 0 ] > /dev/null # if dos del else
	    then
cant=$(echo $campos | awk -F"," '{print NF}')
numero=1

while [ $numero -le $cant ] >/dev/null #apertura while
do
c=$(echo $campos | awk -v num=$numero -F"," '{print $num}') > /dev/null

##verificamos si los campos seleccionados por el usuario existen sino mandamos mensaje de error

mysql -u$user -p$pass "$base" <<IN | grep "$c" > /dev/null
describe $quitarpuntoycoma;
IN

  if [ $? -ne 0 ] >/dev/null #if tres del else
  then
	echo "El campo $c no existe"
	numero=$(expr $cant) #sale del bucle
  else 
	
    if [ $numero -eq $cant ] > /dev/null #if cuatro del else
    then
echo ""
mysql -u$user -p$pass "$base" <<IN 
$ultimo2;
IN
sleep 3
numero=$(expr $cant) #sale del bucle	
    fi  #cierre if cuatro
  fi  #cierre if tres de else
    
numero=$(expr $numero + 1 ) #contador
done #cierre while
	    else
	    echo "Lo sentimos la tabla no existe"
	    sleep 3
	    fi #cierre if dos de else

	else 
	echo "La base de datos no existe"
	sleep 3
        fi #cierre if uno del esle

fi #cierre primer if

     ;;
####################################################### DELETE DATOS#######################################
########################################################################################################################################################

     "DELETE"|"delete")



#verificamos que el campo 2 sea from
if [ "$cam2" = "FROM" -o "$cam2" = "from" ] > /dev/null # if uno
then
    echo -n "Nombre de la BDD donde se encuentra la Tabla: "
    read base

#Verificamos si la base de datos existe o no
mysql -u$user -p$pass <<IN | grep "$base" > /dev/null
show databases;
IN
		   
     if [ $? -eq 0 ] > /dev/null #apertura if dos
     then
#verificamos si la tabla existe o no (contenida en campo 3)
mysql -u$user -p$pass "$base" <<IN | grep "$cam3" > /dev/null
show tables;
IN
	if [ $? -eq 0 ] > /dev/null #apertura del if tres
	then
#comparamos que el cuarto campo sea un "where"
	if [ "$cam4" = "WHERE" -o "$cam4" = "where" ] > /dev/null #if cuatro
	then
#sacamos solo la condicion
condi=$(echo $ultimo2 | awk -F"where" '{print $2}')
#ver cuantas condiciones hay
cant=$(echo $condi | awk -F"and" '{print NF}')
num=1

#bucle de condiciones
while [ $num -le $cant ] > /dev/null #while para evaluar varias condiciones
do
#sacar cada condicion
c=$(echo $condi | awk -v nu="$num" -F"and" '{print $nu}') > /dev/null
#sacar cada campo
eval_campos=$(echo $c | awk -F"=" '{print $1}')
#verificar si existe el campo
mysql -u$user -p$pass "$base" <<IN | grep "$eval_campos"  > /dev/null
describe $cam3;
IN
	if [ $? -eq 0 ] > /dev/null #if cinco
	then
    	    if [ $num -eq $cant ] > /dev/null #if cuatro del else
   	    then
mysql -u$1 -p$2 $base <<IN  > /dev/null
$ultimo2;
IN
		
		echo "datos borrados con exito"
		sleep 3
		num=$(expr $cant) #sale del bucle
		
            fi  #cierre if cuatro

	else 
	echo "El campo $eval_campos no existe"
	sleep 3
	num=$(expr $cant) #sale del bucle
	fi #cierre del if cinco
num=$(expr $num + 1 )
done  #cierre primer while
	else
	echo "Error... use 'where'"
	sleep 3
	fi # cierre if cuatro
	else
	echo "No existe ninguna tabla con ese nombre"
	sleep 3
	fi #cierre if tres

     else 
      echo "La base de datos no existe"
      sleep 3
     fi # cierre if dos

else
echo "Error se esperaba 'from'"
sleep 3
fi  # cierre if uno


      ;;

##############################################################################################################################



     "update"|"UPDATE")

echo "ingrese el nombre de la BDD ha verificar"
read base
#verificando si la base de datos existe
mysql -u$1 -p$2 <<IN | grep "$base" >/dev/null
show databases;
IN
  if [ $? -eq 0 ] > /dev/null #Primer if
  then
#verificando si la tabla existe
mysql -u$1 -p$2 "$base" <<IN | grep "$cam2" >/dev/null
show tables;
IN
	if [ $? -eq 0 ] > /dev/null # sugundo if
	then

					
#VERIFICANDO EL TERCER CAMPO SET DE TABLA
case $cam3 in
	"set"|"SET")
update1=$(echo $accion | awk -F"set" '{print $2}')
update2=$(echo $update1 | awk -F"where" '{print $1}')


#ver cuantas modificaciones
cant=$(echo $update2 | awk -F"," '{print NF}')
num=1

#bucle de modificaciones
while [ $num -le $cant ] > /dev/null #while para evaluar varias modificaciones
do
#sacar cada modificacion
c=$(echo $update2 | awk -v nu="$num" -F"," '{print $nu}') > /dev/null
#sacar cada campo
eval_campos=$(echo $c | awk -F"=" '{print $1}')
#verificar si existe el campo
mysql -u$user -p$pass "$base" <<IN | grep "$eval_campos"  > /dev/null
describe $cam2;
IN
	if [ $? -eq 0 ] > /dev/null #if tres
	then
    	    if [ $num -eq $cant ] > /dev/null #if cuatro 
   	    then
#sacamos la condicion
condicion=$(echo $update1 | awk -F"where" '{print $2}')
#sacamos el campo de la condicion
condi_campo=$(echo $quitarpuntoycoma | awk -F"=" '{print $1}')
#verificar si existe el campo
mysql -u$user -p$pass "$base" <<IN | grep "$condi_campo"  > /dev/null
describe $cam2;
IN
if [ $? -eq 0 ] > /dev/null #if cinco
then

mysql -u$1 -p$2 "$base" <<IN  2> /dev/null
$ultimo2;
IN
		if [ $? -eq 0 ] > /dev/null #if cinco
		then
		echo "Datos modificados con exito"
		sleep 3
		num=$(expr $cant) #sale del bucle
		else 
		echo "Los valores no son correctos"
		sleep 3
		fi
else 
echo "El campo $condi_campo no existe"
sleep 3
num=$(expr $cant) #sale del bucle
fi		
            fi  #cierre if cuatro

	else 
	echo "El campo $eval_campos no existe"
	sleep 3
	num=$(expr $cant) #sale del bucle
	fi #cierre del if tres
num=$(expr $num + 1 )

done  #cierre primer while
	;;	
	 *)echo "se esperaba uso de 'set'"
	sleep 3	
	;;
	esac

	else # del segundo if
	echo "No se encontro la tabla"
	sleep 3
	fi

  else # else primer if
  echo "La base de datos no existe"
  sleep 3
  fi # cierre primer if


     ;;

     "exit"|"bye")
     echo "cerrando el programa"
con=0
while [ $con -le  ]
do
echo "|"
sleep 1
clear
echo "/"
sleep 1
clear
echo "|"
sleep 1
con=$(expr $con + 1 )
done
	clear
	exit
     ;;	
	"quit")
	./Main.sh
     ;; 
     
     *)echo "error de sintaxis..."
	sleep 2
     ;;
esac	

done	
	
