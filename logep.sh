#!/bin/bash

# tipo de log, por defecto info
tipo=[INFO]

#check si LOGDIR esta fijada
if [ -z "$LOGDIR" ]
then
	printf "%b\n" "la variable LOGDIR esta vacia"
	exit
elif [ ! -d "$LOGDIR" ]
then
	printf "%b\n" "la variable LOGDIR no contiene un directorio valido"
	exit
fi	

#parsea todas las opciones de log y toma la ultima a menos que haya
#una opcion incorrecta o este la opcion de ayuda, en tal caso imprime
#el mensaje correspondiente y sale
while getopts iweh op
do
	case $op in
	i) tipo=[INFO];;
	w) tipo=[WARM];;
	e) tipo=[ERR];;
	h) printf "Modo de empleo: logep [opcion] [comando] [mensaje]\n"
		 printf "Graba en el archivo de log del comando el mensaje en formato W5. De no existir el archivo lo crea\n"
		 printf "La variable global LOGDIR debe ser fijada con el directorio del archivo de log, antes de grabar cualquier log\n"
		 printf "Tipos:\n"
		 printf " %b\n" "-i graba un mensaje de tipo info"  "-w graba un mensaje de tipo warm" "-e graba un mensaje de tipo error"
		 # despues de dar el mensaje de ayuda, sale de la invocacion
		 exit;;
		#si el parametro no es conocido, cierra la aplicacion, el mensaje de error es escrito por el comando getopts
		*)exit;;
	esac
done

# el primer parametro que no sea una opcion pasa a tomar la primera posicion, $1
shift $[ $OPTIND - 1 ]

#revisa que este los parametros obligatorios
if [ $# -lt 2 ]
then
	printf "%b\n" "logep: falta alguno de los parametros obligatorios [comando] o [mensaje]"
	exit
fi

#si el archivo no existe lo creo.
logfile="$LOGDIR/$1.log"

printf "%b\n" "$USERNAME `date +%D` $1 $tipo $2">>"$logfile"

#esta variable contiene el maximo numero de lineas, debe ser par
max_lines=2000

if [ `wc -l < "$logfile"` -lt $max_lines ]
then
	exit
fi

#mensaje para indicar que se ha excedido el tamanio del archivo
log_excedido="Log Excedido"

printf "%s\n" "$log_excedido"

#creo un archivo temporal de trabajo
work_file="$LOGDIR/temp$1.log"

#guardo las primeras max_lines/2 lineas del log en un archivo comprimido
head -n $[max_lines/2] "$logfile" >"$work_file"
zip "$logfile.zip" "$work_file"

#en el original dejo las restantes lineas
printf "%b\n" "$USERNAME `date +%D` $1 $tipo $log_excedido">"$work_file"
tail -n $[max_lines/2] "$logfile" >>"$work_file"
cat "$work_file">"$logfile"
rm "$work_file"

