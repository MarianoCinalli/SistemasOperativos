#!/usr/bin/env perl

###Objeto Filtro####

#defino objeto filtro, su objetivo es filtrar provincias , trimestres, centros u otros campos
#en el constructor recibe una lista de tokens (strings) y rangos
sub Filtro::new{
	my $class=shift;
	my $self={aceptar_todo=> 0,tokens=>{}, rangos=>[]};
	bless ($self, $class);
	foreach (@_){
		$self->add($_);
	}
	return $self;
}

#agrega token o rango
sub Filtro::add{
	my $self=shift;
	if (@_[0]=~/\*/) {
		push($self->{rangos}, @_[0]);
	}
	else{
		$self->{tokens}->{@_[0]}=undef;
	}
}

sub Filtro::set_aceptar_todo{
	my $self=shift;
	$self->{aceptar_todo}=1;
}

#retorna true si coincide con alguno de los tokens o rangos agregados.
#si flag aceptar_todo esta activa acepta todo
sub Filtro::filtrar{
	$self=shift;
	if ($self->{aceptar_todo}){
		return 1;
	}
	if (exists($self->{tokens}->{$_[0]})){
		return 1;
	}
	foreach $rango (@{$self->{rangos}}){
		$aux=$rango;							
		$rango=~s/\*//;
		if ($_[0]=~/^$rango/){
			return 1;
		}
		$rango=$aux;
	}
	return 0;
}

###Termina Objeto Filtro#####

sub getAnio{
	print "Ingrese año:";
	my $anio=<STDIN>;
	chop($anio);
	return $anio;
}
		




sub getFiltro{
	#muestro mensaje
	print $_[0];
	my $linea=<STDIN>;
	chop $linea;
	my @campos=split (",", $linea);
	my $filtro=undef;
	if (!@campos){
		if ($_[1]){
			#si me pasa valores creo el filtro con esos valores
			$filtro=Filtro->new(@{$_[1]});
		}else{
			#sino creo uno que acepte todo
			$filtro=Filtro->new();
			$filtro->set_aceptar_todo();
		}
		return $filtro;
	}
	$filtro=Filtro->new();
	#elimino espacios en blancos y agrego a filtro
	foreach $campo (@campos){
		$campo=~ s/^\s*//;
		$campo=~ s/\s*$//;
		$filtro->add($campo);
	}
	return $filtro;
}


sub getPresupuestoTrimestres{
	my %presupuesto_trimestres=($trimestres[0], {}, $trimestres[1], {}, $trimestre[2], {}, $trimestre[3], {});
	my $archivo_ruta=$path_sancionado.$_[0].".csv";
	open (my $archivo, '<', $archivo_ruta) or die("fallo al abrir archivo ".$archivo_ruta);
	my $linea=<$archivo>;
	while ($linea=<$archivo>){
		chop($linea);
		my @campos=split(';', $linea);
		#reemplazo coma por punto para poder sumar doubles
		$campos[2]=~ s/"//g;
		$campos[3]=~ s/"//g;
		$campos[2] =~ s/,/./;
		$campos[3] =~ s/,/./;
		$presupuesto_trimestres{$campos[1]}->{$campos[0]}=$campos[2]+$campos[3];
	}
	return %presupuesto_trimestres;
}

sub getArchivoSalida{
	print "Ingrese path archivo de salida\n";
	print "Si no ingresa nada, solo imprime por pantalla:";
	my $linea=<STDIN>;
	if ($linea eq "\n"){
		return undef;
	}
	chop($linea);
	return $linea;
}

sub getInicioTrimestres{
	my $archivo_ruta=$path_maestros."/trimestres.csv";
	open(my $trimestres, '<', $archivo_ruta) or die("fallo al abrir archivo ".$archivo_ruta);
	my $linea=undef;
	my %inicio_trimestres;
	$linea=<$trimestres>;
	while ($linea=<$trimestres>){
		chop($linea);
		my @campos = split ";" , $linea;
		if ($campos[0] eq $_[0]){
			(my $dia, my $mes, my $anio)=split "/", $campos[2];
			my $inicio=$anio.$mes.$dia;
			if ($campos[1] eq $trimestres[0]){
				$inicio_trimestres{$trimestres[0]}=$inicio;
			}
			elsif ($campos[1] eq $trimestres[1]){
				$inicio_trimestres{$trimestres[1]}=$inicio;
			}
			elsif ($campos[1] eq $trimestres[2]){
				$inicio_trimestres{$trimestres[2]}=$inicio;
			}
			else{
				$inicio_trimestres{$trimestres[3]}=$inicio;
			}
		}
	}
	return %inicio_trimestres;
}

sub getGastosPlanificados{
	my %gastos_planificados;
	my $archivo_ruta=$path_maestros."/tabla-AxC.csv";
	open(my $planes, '<', $archivo_ruta) or die("fallo al abrir archivo ".$archivo_ruta);
	my $linea;
	$linea=<$planes>;
	while ($linea=<$planes>){
		chop $linea;
		(my $actividad, my $centro)=split ";", $linea;
		if (! defined($gastos_planificados{$centro})){
			$gastos_planificados{$centro}={};
		}
		$gastos_planificados{$centro}->{$actividad}=undef;
	}
	return %gastos_planificados;
}

sub getNumActividades{
	my %num_actividades;
	my $archivo_ruta=$path_maestros."/actividades.csv";
	open(my $nombres, '<', $archivo_ruta) or die("fallo al abrir archivo ".$archivo_ruta);
	my $linea;
	$linea=<$nombres>;
	while ($linea=<$nombres>){
		chop $linea;
		my @campos=split(";", $linea);
		$num_actividades{$campos[3]}=$campos[0];
	}
	return %num_actividades;
}

sub getNombres{
	my %nombres;
	my $archivo_ruta=$path_maestros."/".$_[0];
	open ($fnombres, '<', $archivo_ruta) or die("fallo a abrir ".$archivo_ruta);
	my $linea;
	$linea=<$fnombres>;
	while ($linea=<$fnombres>){
		chop $linea;
		my @campos=split(";", $linea);
		$nombres{$campos[0]}=$campos[1];
	}
	close($fnombres);
	return %nombres;
}

sub CargarRegistros{
	my @regitros;
	foreach my $ruta (<$path_ejecutados/ejecutado_$_[0]*>){
		open(my $archivo, '<', $ruta) or die ("fallo al abrir ".$ruta);
		my $linea;
		$linea=<$archivo>;
		while ($linea=<$archivo>){
			chop($linea);
			my @campos=split ";", $linea;
			if ($_[2]->filtrar($campos[2]) && $_[1]->filtrar($campos[4])){
				push(@registros, $linea);
			}
		}
		close($archivo);
	}
	return @registros;
}

sub ordenarPorCentroYFecha{
	@campos_a=split(';',$_[0]);
	@campos_b=split(';',$_[1]);
	if (@campos_a[2] lt @campos_b[2]){
		return -1;
	}
	elsif (@campos_a[2] gt @campos_b[2]){
		return 1;
	}
	elsif (@campos_a[1] < @campos_b[1]){
		return -1;
	}
	elsif (@campos_a[1] > @campos_b[1]){
		return 1;
	}
	return 0;
}

sub ultimo_registro_centro{
	$longitud=@registros;
	if ($longitud == $_[1]+1){
		return 1;
	}
	my @campos=split ";", $registros[$_[1]+1];
	if ($_[0] ne $campos[2]){
		return 1;
	}
	return 0;
}

sub actividad_planeada{
	my $num_act=$num_actividades{$_[1]};
	return exists($gastos_planificados{$_[0]}->{$num_act});
}

sub calcularYMostrarSaldos(){
	@registros=sort {ordenarPorCentroYFecha($a, $b)} @registros;
	my $linea=getArchivoSalida();
	my $out=undef;
	if ($linea){
		open($out, '>', $linea) or die($!);
	}
	$encabezado="ID;FECHA MOV;CENTRO;ACTIVIDAD;TRIMESTRE;IMPORTE;SALDO por TRIMESTRE;CONTROL;SALDO ACUMULADO\n";
	if ($out){
		print $encabezado;
	}
	print $encabezado;
	my $centro="";
	my $trimestre="";
	my $saldo=0;
	my $saldo_acumulado=0;
	$i=0;
	foreach my $registro (@registros){
		my @campos=split (';', $registro);
		if ($centro ne $campos[2] || $trimestre ne $campos[4]){
			#empieza nuevo trimestre o centro
			$saldo=$presupuesto_trimestres{$campos[4]}->{$campos[2]};
			if ($centro ne $campos[2]){
				$saldo_acumulado=$saldo;
			}
			else{
				$saldo_acumulado=$saldo+$saldo_acumulado;
			}
			$centro=$campos[2];
			$trimestre=$campos[4];
			#reemplazo . por coma para imprimirlo
			$saldo=~ s/\./,/;
			$saldo_acumulado=~ s/\./,/;
			$saldo_final='';
			if (ultimo_registro_centro($centro, $i)){
				$saldo_final='(*)';
			}
			my $salida="(++);".$inicio_trimestres{$trimestre}.";".$centro.";0;".$trimestre.";".'"'.$saldo.'"'.";".'"'.$saldo.'"'.";-;".'"'.
			$saldo_acumulado.$saldo_final.'"'."\n";
			print $salida;	
			if ($out){
				print $out $salida;
			}
			$saldo=~ s/,/./;
			$saldo_acumulado=~ s/,/./;
		}
		else{
			my $importe=$campos[5];
			my $control='';
			$importe=~ s/"//g;
			$importe=~ s/,/./;
			$saldo-=$importe;
			if ($saldo<0){
				$control="presupuesto excedidio";
			}
			if (!actividad_planeada($centro, $campos[3])){
				if ($control){
					$control=$control." ";
				}
				$control=$control."gasto no planificado";
			}
			if (! $control){
				$control='-';
			}
			$saldo_acumulado-=$importe;
			$importe=~ s/\./,/;
			$saldo=~ s/\./,/;
			$saldo_acumulado=~ s/\./,/;
			my $salida=$campos[0].";".$campos[1].";".$campos[2].";".$campos[3].";".$campos[4].";".'"'.$importe.'"'.";".'"'.$saldo.'"'.";".$control.";";
			if (ultimo_registro_centro($centro, $i)){
				$salida=$salida.'"'.$saldo_acumulado."(*)".'"'."\n";
			}else{
				$salida=$salida.'"'.$saldo_acumulado.'"'."\n";
			}
			print $salida;
			if ($out){
				print $out $salida;
			}
			$saldo=~ s/,/./;
			$saldo_acumulado=~ s/,/./;
		}
		++$i;
	}
}

sub ordenarPorCentroTrimestre{
	#Obtengo los campos del registro separandolos.
	@campos_a = split ";" , $_[0];
	@campos_b = split ";" , $_[1];

	#cambio C por c para que quede ordenado 'cuarto trimestre'
	$campos_a[1] =~ s/C/c/;
	$campos_b[1]=~ s/C/c/;
	
	if ($campos_a[0] lt $campos_b[0]){
		return -1;
	}
	if ($campos_a[0] gt $campos_b[0]){
		return 1;
	}
	if ($campos_a[1] lt $campos_b[1]){
		return -1;
	}
	if ($campos_a[1] gt $campos_b[1]){
		return 1;
	}
	return 0;
}

sub ordenarPorTrimestreCentro{
	#Obtengo los campos del registro separandolos.
	@campos_a = split ";" , $_[0];
	@campos_b = split ";" , $_[1];

	#cambio C por c para que quede ordenado 'cuarto trimestre'
	$campos_a[1] =~ s/C/c/;
	$campos_b[1]=~ s/C/c/;
	
	if ($campos_a[1] lt $campos_b[1]){
		return -1;
	}
	if ($campos_a[1] gt $campos_b[1]){
		return 1;
	}
	if ($campos_a[0] lt $campos_b[0]){
		return -1;
	}
	if ($campos_a[1] gt $campos_b[1]){
		return 1;
	}
	return 0;
}

#empieza Script--------------------------------------------------

$path_grupo=$ENV{GRUPO};
$path_maestros=$path_grupo."/".$ENV{DIRMAE};
$path_ejecutado_anio_fiscal=$path_grupo."/".$ENV{DIRPROC}."/proc/ejecutado-";
$path_ejecutados=$path_grupo."/".$ENV{DIROK};
$path_sancionado=$path_maestros."/sancionado-";

printf "Elija el listado que desee generar: \n";
printf "1- Listado de presupuesto sancionado \n";
printf "2- Listado de presupuesto ejecutado \n";
printf "3- Listado de control de presupuesto ejecutado \n";
$opcion = <STDIN>;
chop $opcion;
if ($opcion!=1 && $opcion!=3 && $opcion!=2){
	die("error:opcion $opcion incorrecta");
}

#pido anio a procesar
$anio=getAnio;

if ($opcion==1){
	my $ruta = $path_sancionado.$anio.".csv";
	open($sancionado, '<',$ruta) or die("fallo al abrir ".$ruta);
	%centros_nombres=getNombres("centros.csv");
	printf "Seleccione orden de los campos para ordenar los presupuestos sancionados \n";
	printf "1- Codigo Centro/Trimestre \n";
	printf "2- Trimestre/Codigo Centro \n";
	my $orden=<STDIN>;
	chop $orden;
	if ($orden!=1 && $orden!=2){
		die("error: opcion $opcion incorrecta");
	}
	my %centros_nombres=getNombres("centros.csv");
	$linea=<$sancionado>;
	my @registros;
	my $total_anual=0;
	while ($linea=<$sancionado>){
		#cargo los registros en memoria y los dejo  listos para mostrar, tambien calculo total
		chop $linea;
		my @campos=split ";", $linea;
		$campos[2]=~ s/"//g;
		$campos[3]=~ s/"//g;
		$campos[2]=~ s/,/./;
		$campos[3]=~ s/,/./;
		$total=$campos[2]+$campos[3];
		$total_anual+=$total;
		$total=~ s/\./,/;
		$linea=$centros_nombres{$campos[0]}.";".$campos[1].";".'"'.$total.'"'."\n";
		push(@registros, $linea);
	}
	#ordeno los registros
	if ($orden==1){
		@registros=sort {ordenarPorCentroTrimestre($a, $b)} @registros;	
	}else{
		@registros=sort {ordenarPorTrimestreCentro($a, $b)} @registros;
	}
	my $ruta=getArchivoSalida();
	my $out=undef;
	if ($ruta){
		open($out, '>', $ruta) or die($!);
	}
	my $encabezado="Centro;Año presupuestario $anio;Total Sancionado\n";
	print $encabezado;
	if ($out){
		print $out $encabezado;
	}
	foreach (@registros){
		print $_;
		if ($out){
			print $out $_;
		}
	}
	$total_anual=~ s/\./,/;
	my $salida="Total Anual;".'"'.$total_anual.'"'."\n";
	print $salida;
	if ($out){
		print $out $salida;
	}
	close($out);
	close($sancionado);
	exit;
}

sub ordenarPorProvincia{
	my @campos_a=split ";", $_[0];
	my @campos_b=split ";" , $_[1];
	if (@campos_a[7] lt @campos_b[7]){
		return -1;	
	}
	if (@campos_a[7] gt @campos_b[7]){
		return 1;	
	}
	return 0;
}

if ($opcion==2){
	my %provincias_nombres=getNombres("provincias.csv");
	print "Código----Provincia\n";	
	foreach (keys(%provincias_nombres)){
		print $provincias_nombres{$_}."   ".$_."\n";
	}
	my $filtro_provincias=getFiltro("Ingrese la lista de provincias (puede ser nombre o numero) a filtrar, separados por comas,\n"."si no ingresa ninguna provincia se asume que quiere todas:");
	#si agrego numeros los remplazo por nombre de provincias
	foreach(keys(%{$filtro_provincias->{tokens}})){
		if (exists($provincias_nombres{$_})){
			$filtro_provincias->add($provincias_nombres{$_});
		}
	}
	%gastos_planificados=getGastosPlanificados();
	my $archivo_ruta=$path_ejecutado_anio_fiscal.$anio;
	open(my $archivo, '<', $archivo_ruta) or die("fallo al abrir archivo".$archivo_ruta);
	my $ruta=getArchivoSalida();
	my $out=undef;
	if ($ruta){
		open($out, '>', $ruta) or die($!);
	}
	my @registros;
	while ($linea=<$archivo>){
		chop $linea;
		my @campos=split ';', $linea;
		if ($filtro_provincias->filtrar($campos[8])){
			#el campo control se lo agrego mas adelante
			$salida=$campos[1].";".$campos[2].";".$campos[9].";".$campos[7].";".$campos[3].";".$campos[4].";".$campos[5].";".$campos[8];
			push(@registros, $salida);
		}	
	}
	sort {ordenarPorProvincia($a, $b)} @registros;
	my $salida="Fecha;Centro;Nom Cen;cod Act;Actividad;Trimeste;Gasto;provincia;control\n";
	print $salida;
	if ($out){
		print $out $salida;
	}
	$i=0;
	my @campos=split ";" , $registros[1];
	$provincia=$campo[7];
	my $gasto_total=0;
	foreach (@registros){
		my @campos_act=split ";" , $registros[$i];
		$campos_act[6]=~ s/,/./;
		$campos_act[6]=~ s/"//g;
		$gasto_total+=$campos_act[6];
		if (! actividad_planeada($campos_act[1], $campos_act[3])){
			$salida=$_.";gasto fuera de la planificacion\n";
		}else{
			$salida=$_.";-\n";
		}
		print $salida;
		if ($out){
			print $out $salida;
		}
		my @campos_next=split ";", $registros[$i+1];
		if ($campos_act[7] ne $campos_next[7]){
			#ultimo registro de provincia
			$gasto_total=~ s/\./,/;
			my $salida="-;-;-;-;-;Total Gastos ".$campos_act[7].";".'"'.$gasto_total.'"'."\n";
			print $salida;
			if ($out){
				print $out $salida;
			}
			$gasto_total=0;
		}
		++$i;
	}
	exit;
}


#cargo nombres de trimestres en array para ahorame trabajo
@trimestres=("Primer Trimestre $anio", "Segundo Trimestre $anio", "Tercer Trimestre $anio", "Cuarto Trimestre $anio");
#cargo fecha de inicio de trimestre en hash, solo los de anio
%inicio_trimestres=getInicioTrimestres($anio);
#creo un hash que contendra un hash para trimestre, dentro del hash de cada trimestre estan los centros y sus presupuestos
%presupuesto_trimestres=getPresupuestoTrimestres($anio);
%num_actividades=getNumActividades();
%gastos_planificados=getGastosPlanificados();
#este objeto filtar trimestre, si el usario no agrega ningun trimestre se cargan los de la lista @trimestres, o sea, todos
$filtro_trimestres=getFiltro("Ingrese la lista de trimestres a filtrar (1,2,3,4) separados por comas,\n"."si no ingresa ningun trimestre se asume que quiere
todos:", \@trimestres);
#si usuario no agrega ningun centro, el filtro se setea para aceptar todo
$filtro_centros=getFiltro("Ingrese centros a filtrar, puede ser una lista, en la lista puede haber rangos (centro1,centro2,rango), si no\n"."ingresa nada asume que quiere todos:");
#carga los registros que pasan la filtracion
@registros=CargarRegistros($anio, $filtro_trimestres, $filtro_centros);
#hace todo el trabajo y lo imprime por pantalla
calcularYMostrarSaldos();	
