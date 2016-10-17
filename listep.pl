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
	open (my $archivo, '<', $path."/sancionado-".$_[0].".csv") or die($!);
	my $linea=<$archivo>;
	while ($linea=<$archivo>){
		chop($linea);
		my @campos=split(';', $linea);
		#reemplazo coma por punto para poder sumar doubles
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
	open(my $trimestres, '<', $path."/trimestres.csv") or die($!);
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
	open(my $planes, '<', $path."/tabla-AxC.csv") or die($!);
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
	open(my $nombres, '<', $path."/actividades.csv") or die($!);
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
	open ($fnombres, '<', $path."/".$_[0]) or die($!);
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
	foreach my $ruta (<$path/ejecutado_$_[0]*>){
		open(my $archivo, '<', $ruta) or die $!;
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

#variable harcadodeada a borrar
$path="/home/pepe/Escritorio/gaspar/cosas/gaspar/contenido_pendrive/programacion/sistemas_operativos/tp/SistemasOperativos/datos";

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
	my $ruta = $path ."/sancionado-" . $anio . ".csv";
	open($sancionado, '<',$ruta) or die($!);
	%centros_nombres=getNombres("centros.csv");
	printf "Seleccione orden de los campos para ordenar los presupuestos sancionados \n";
	printf "1- Codigo Centro/Trimestre \n";
	printf "2- Trimestre/Codigo Centro \n";
	my $orden=<STDIN>;
	chop $orden;
	if ($orden!=1 && $orden!=2){
		die("error: opcion $opcion incorrecta");
	}
	my %centros_nombres=getCentrosNombres();
	$linea=<$sancionado>;
	my @registros;
	my $total_anual=0;
	while ($linea=<$sancionado>){
		chop $linea;
		my @campos=split ";", $linea;
		$campos[2]=~ s/,/./;
		$campos[3]=~ s/,/./;
		$total=$campos[2]+$campos[3];
		$total_anua+=$total;
		$total=~ s/\./,/;
		$linea=$centros_nombres{$campos[0]}.";".$campos[1].";".'"'.$total.'"'."\n";
		push(@registros, $linea);
	}
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
	my $salida="Total Anual;".$total_anual."\n";
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
	if (@campos_a[4]<@campos_b[4]){
		return -1;	
	}
	if (@campos_a[4]>@campos_b[4]){
		return 1;	
	}
	return 0;
}

if ($opcion==2){
	my %provincias_nombres=getNombres("provincias.csv");
	print "códigos provincias\n";	
	foreach (keys(%provincias_nombres)){
		print $provincias_nombres{$_}."   ".$_."\n";
	}
	my $filtro_provincias=getFiltro("Ingrese la lista de códigos de provincias a filtrar (1,2,3,4) separados por comas,\n"."si no ingresa ninguna provincia se asume que quiere todas:");
	%gastos_planificados=getGastosPlanificados();
	open(my $archivo, '<', $path."ejecutado_".$anio) or die($!);
	my $linea=<$archivo>;
	my $ruta=getArchivoSalida();
	my $out=undef;
	if ($ruta){
		open($out, '>', $ruta) or die($!);
	}
	my @registros;
	while ($linea=<$archivo>){
		my @campos=split ';', $linea;
		$salida=$campos[0].$campos[1].$campos[8].$campos[6].$campos[2].$campos[3].$campos[4].$campos[7];	
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
		$gasto_total+=$campos_act[6];
		if (actividad_planeada($campos[1], $campos[3])){
			$salida=$_."gasto fuera de la planificacion";
		}else{
			$salia=$_."-";
		}
		print $salida;
		if ($out){
			print $out $salida;
		}
		my @campos_next=split ";", $registros[$i+1];
		if ($campos_act[7] ne $campos_next[7]){
			#ultimo registro de provincia
			$gasto_total=~ s/\./,/;
			my $salida=";;;;;".'"'.$gasto_total.'"'.";".$campos_act[7]."\n";
			print $salida;
			if ($out){
				print $out $salida;
			}
			$gasto_total=0;
		}
	}
	exit;
}


#cargo nombres de trimestres en array para ahorame trabajo
@trimestres=("Primer Trimestre $anio", "Segundo Trimestre $anio", "Tercer Trimestre $anio", "Cuarto Trimestre $anio");
#cargo fecha de inicio de trimestre en hash, solo los de anio
%inicio_trimestres=getInicioTrimestres($anio);
#creo un hash que contendra un hash para trimestre, dentro del hash de cada trimestre estan los centros y sus presupuestos
%presupuesto_trimestres=getPresupuestoTrimestres($anio);
%num_actividades=getNumActividades;
%gastos_planificados=getGastosPlanificados;
#este objeto me ayuda a filtara trimestres
$filtro_trimestres=getFiltro("Ingrese la lista de trimestres a filtrar (1,2,3,4) separados por comas,\n"."si no ingresa ningun trimestre se asume que quiere
todos:", \@trimestres);
$filtro_centros=getFiltro("Ingrese centros a filtrar, puede ser una lista, en la lista puede haber rangos (centro1,centro2,rango), si no\n"."ingresa nada asume que quiere todos:");
#carga los registros que pasan la filtracion
@registros=CargarRegistros($anio, $filtro_trimestres, $filtro_centros);
#hace todo el trabajo y lo imprime por pantalla
calcularYMostrarSaldos();	
