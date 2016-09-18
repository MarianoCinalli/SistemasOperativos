while read -r linea
do
	nombreDirectorio=$( echo "$linea" | cut -d= -f1)
	ruta=$( echo "$linea" | cut -d= -f2)
	usuario=$(echo "$linea" | cut -d= -f3)
	case $nombreDirectorio in
	DIRBIN) if [ -z "$DIRBIN" ] 
		then DIRBIN=$ruta 
		fi;;
	DIRMAE) if [ -z "$DIRMAE" ] 
		then DIRMAE=$ruta 
		fi;;
	DIRREC) if [ -z "$DIRREC" ] 
		then DIRREC=$ruta 
		fi;;
	DIROK) if [ -z "$DIROK" ] 
		then DIROK=$ruta 
		fi;;
	DIRINFO) if [ -z "$DIRINFO" ] 
		then DIRINFO=$ruta 
		fi;;
	DIRLOG) if [ -z "$DIRLOG" ] 
		then DIRLOG=$ruta 
		fi;;
	GRUPO) if [ -z "$GRUPO" ] 
		then GRUPO=$ruta 
		fi;;
	DIRPROC) if [ -z "$DIRPROC" ] 
		then DIRPROC=$ruta 
		fi;;
	esac
done <dirconf/instalep.conf

