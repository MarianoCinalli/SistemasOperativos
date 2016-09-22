#!/bin/bash

export DIRBIN;
export DIRINFO;
export DIRREC;
export DIROK;
export DIRLOG;
export GRUPO;
export DIRPROC;

#Inicializo variables de directorio
while read -r linea
do
	nombreDirectorio=$( echo "$linea" | cut -d= -f1)
	ruta=$( echo "$linea" | cut -d= -f2)
	usuario=$(echo "$linea" | cut -d= -f3)
	case $nombreDirectorio in
	DIRBIN) if [ -z "$DIRBIN" ] 
		then DIRBIN=$ruta
		else printf "Ambiente ya inicializado, para reinicializar termine la sesión e ingrese nuevamente" 
		fi;;
	DIRMAE) if [ -z "$DIRMAE" ] 
		then DIRMAE=$ruta 
		else printf "Ambiente ya inicializado, para reinicializar termine la sesión e ingrese nuevamente" 
		fi;;
	DIRREC) if [ -z "$DIRREC" ] 
		then DIRREC=$ruta
		else printf "Ambiente ya inicializado, para reinicializar termine la sesión e ingrese nuevamente"  
		fi;;
	DIROK) if [ -z "$DIROK" ] 
		then DIROK=$ruta 
		else printf "Ambiente ya inicializado, para reinicializar termine la sesión e ingrese nuevamente" 
		fi;;
	DIRINFO) if [ -z "$DIRINFO" ] 
		then DIRINFO=$ruta 
		else printf "Ambiente ya inicializado, para reinicializar termine la sesión e ingrese nuevamente" 
		fi;;
	DIRLOG) if [ -z "$DIRLOG" ] 
		then DIRLOG=$ruta 
		else printf "Ambiente ya inicializado, para reinicializar termine la sesión e ingrese nuevamente" 
		fi;;
	GRUPO) if [ -z "$GRUPO" ] 
		then GRUPO=$ruta 
		else printf "Ambiente ya inicializado, para reinicializar termine la sesión e ingrese nuevamente" 
		fi;;
	DIRPROC) if [ -z "$DIRPROC" ] 
		then DIRPROC=$ruta 
		else printf "Ambiente ya inicializado, para reinicializar termine la sesión e ingrese nuevamente" 
		fi;;
	esac
done <dirconf/instalep.conf

#Verifico permisos de escritura,lectura y ejecucion cuando corresponda

#Termina la ejecucion de initep sino puede cambiar el permiso correspondiente
if [ ! -r dirconf/instalep.conf ] 
	#Habria que forzar la salida sino se puede cambiar el permiso (no lo hace)
then	chmod +r dirconf/instalep.conf || exit
fi
	
if [ ! -w dirconf/instalep.conf ]
then	chmod +w dirconf/instalep.conf || exit 
fi

if [ ! -x dirconf/instalep.conf ]
then	chmod +x dirconf/instalep.conf || exit 
fi

if [ ! -x logep.sh ]
then	chmod +x logep.sh || exit 
fi

if [ ! -r logep.sh ]
then	chmod +r logep.sh || exit

if [ ! -x demonep.sh ]
then	chmod +x demonep.sh || exit
fi

if [ ! -r demonep.sh ]
then	chmod +r demonep.sh || exit
fi
	#Pregunto por demonep
	read -p "¿Desea efectuar la activación de Demonep (S/N)?" opcion

	case "$opcion" in
		s|S ) echo "Activar Demonep y explicar como detenerlo manualmente"
		      logep.sh -i initep.sh "¿Desea efectuar la activación de Demonep (S/N)? Si"
			#falta agregar el proceces id						
			echo "Demonep corriendo bajo el numero:" 
			logep.sh -i initep.sh "Demonep corriendo bajo el numero: "
			;;

		n|N ) echo "Explicacion manual para arrancar Demonep"
			logep.sh -i initep.sh "¿Desea efectuar la activación de Demonep (S/N)? No"
			 ;;

		* ) echo "Ingrese una opción correcta";;
	esac

