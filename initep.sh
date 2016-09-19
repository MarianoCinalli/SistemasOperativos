#!/bin/bash
#Lee todas las rutas especificadas en instalep de los directorios correspondientes. 
while read -r linea
do
	nombreDirectorio=$( echo "$linea" | cut -d= -f1)
	ruta=$( echo "$linea" | cut -d= -f2)
	usuario=$(echo "$linea" | cut -d= -f3)
	case $nombreDirectorio in
	#Pregunta si no esta inicializada la variable
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

#Pregunta si quiere activar el demonep
read -p "¿Desea efectuar la activación de Demonep (S/N)?" opcion

case "$opcion" in
	s|S ) echo "Activar Demonep y explicar como detenerlo manualmente"
	      #source ./demonep.sh
		#faltaria pasarle el texto al logep de que se activo el demonep, pero no se como se hace [MZ]
	      source ./logep.sh ;;
	n|N ) echo "Explicacion manual para arrancar Demonep" ;;
	* ) echo "Ingrese una opción correcta";;
esac

