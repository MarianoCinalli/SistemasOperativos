#!/usr/bin/env perl

#Defino funciones 
#----------------------------------------------------------------------------
sub mostrarMenu
{
	printf "Elija el listado que desee generar: \n";
	printf "1- Listado de presupuesto sancionado \n";
	printf "2- Listado de presupuesto ejecutado \n";
	printf "3- Listado de control de presupuesto ejecutado \n";

	$opcion = <STDIN>;	
}

sub cargarPresupuestos
{
	while($linea = <$sancionado>)
	{
		if(index($linea,$_[0]) != -1)
		{
			@campos = split ";" , $linea;

			#reemplazo coma por punto para poder sumar doubles
			$campos[2] =~ s/,/./;
			$campos[3] =~ s/,/./;

			$presTrimestre{$campos[0]} = $campos[2] + $campos[3];
		}
	}
}

sub buscarRegistrosPorTrimestreYCentros
{
	foreach $nombreArchivo (@nombresArchivos){
			open($archivo, '<', $nombreArchivo);
			
			while($linea = <$archivo>){
				@campos=split ";", $linea;
				if ($campos[4]=~/^$_[0]/){
					#es un booleano para saber si incluir un registro o no
					$incluir=0;
					foreach $centro (@centros){
						if ($centro=~/\*/){
							#es un rango
							#saco * para que no mape cualquier cosa, lo guardo en otra variable para recuperarlo luego
							$aux=$centro;							
							$centro=~s/\*//;
							if ($campos[2]=~/^$centro/){
								#es un booleano para inculir la linea								
								$incluir=1;
							}
							$centro=$aux;
						}
						else{
							if ($campos[2] eq $centro){
								$incluir=1;
							}
						}
						if ($incluir){
							push(@registrosBuscados, $linea);
						}
					}
				}
			}
			close($archivo);
	}
}


sub calcularYMostrarSaldos 
{
#Se pide mostrar en pantalla, pero es ilegible, grabo en un archivo para que se entienda
#por mas que sea opcional.
open (RESULTADO,">resultado.csv");
printf RESULTADO "ID;Fecha;Centro;Actividad;Trimestre;Importe;Saldo;Control\n";
	foreach (keys(%presTrimestre))
		{
			$saldo = $presTrimestre{$_};
			#Faltaria grabar el saldo inicial de cada centro
			#printf "Saldo inicial: " . $saldo . "\n";
			foreach $registro (@registrosBuscados)
			{
				@campos = split ";" , $registro;
				if( $campos[2] eq $_)
				{
					$campos[5] =~ s/,/./;
					$restante = $saldo - $campos[5];
					chomp($campos[5]);
					printf $campos[0] . "   ". $campos[1] . "  ". $campos[2] . "   ". $campos[3]. "  ". $campos[4] . "  ". $campos[5] . "  " . $restante . "      ";

printf RESULTADO $campos[0] . ";". $campos[1] . ";". $campos[2] . ";". $campos[3]. ";". $campos[4] . ";". $campos[5] . ";" . $restante .";";

					$saldo -= $campos[5];
					if($saldo < 0)
					{
						printf "Gasto excedido";
						printf RESULTADO "Gasto excedido";
					}
					else
					{
						printf RESULTADO "-";
					}
					printf "\n";
					printf RESULTADO "\n";
				}
			}
		}
close(RESULTADO);
}

sub mostrarMenuOrden
{
	while ($orden < 1 || $orden > 2)
	{
		printf "Seleccione orden de los campos para ordenar los presupuestos sancionados \n";
		printf "1- Codigo Centro/Trimestre \n";
		printf "2- Trimestre/Codigo Centro \n";
	
		$_[0] = <STDIN>;
	}
	
}
#------------------------------------------------------------------------------
#Aca arranca el script
@registrosBuscados;
%presTrimestre;
$path ="/home/pepe/Escritorio/gaspar/cosas/gaspar/contenido_pendrive/programacion/sistemas_operativos/tp/SistemasOperativos/datos";
mostrarMenu;
while ($opcion < 1 || $opcion > 3)
{
	printf "Ingrese una opcion correcta \n \n";
	mostrarMenu;
}

#Muestro listado de presupuesto sancionado
if ($opcion == 1)
{

	printf "Ingrese año de presupuesto sancionado que quiera listar (2015 o 2016)";
	$anio = <STDIN>;

	#Valido que el año sea correcto
	while($anio != 2015 && $anio != 2016)
	{
		printf "Ingrese año de presupuesto sancionado que quiera listar (2015 o 2016)";
		$anio = <STDIN>;
	}
	chomp($anio);

	#$ruta = $DIRMAE . "/sancionado-" . $anio . ".csv"; esta deberia ser la ruta
	#Uso una ruta absoluta por el momento.
	$ruta = $path ."/sancionado-" . $anio . ".csv";

	#abro el archivo
	open ($presSancionado,'<',$ruta);
		
	#leo primera linea que no sirve de nada
	$primera = <$presSancionado>;
	
	#valido que el orden ingresado sea el correcto
	$orden = -1;
	mostrarMenuOrden ($orden);

	#Fijo el orden para mostrar el listado
	if($orden == 1)
	{
		($primero,$segundo) = (0,1);
	}	
	else
	{
		($primero,$segundo)=(1,0);
	}

	printf "Codigo Centro		Trimestre		Total Sancionado \n";
	while ($linea = <$presSancionado>)
	{
		#Obtengo los campos del registro separandolos.
		@campos = split ";" , $linea;

		#reemplazo coma por punto para poder sumar doubles
		$campos[2] =~ s/,/./;
		$campos[3] =~ s/,/./;

		#cambio C por c para que quede ordenado 'cuarto trimestre'
		$campos[1] =~ s/C/c/;
		$presHash{$campos[$primero] . "           " . $campos[$segundo]} = $campos[2] + $campos[3];
	}

	#Muestro listado de presupuesto sancionado con el orden indicado.
	foreach (sort keys(%presHash))
	{	
		$gastado = $presHash{$_};
		if( index($_,"cuarto") != -1)
		{
			$_ =~ s/c/C/;
		}
		printf $_ . "                " . $gastado . "\n";
	}


}#fin opcion 1


if ($opcion == 3)
{
	$i = 0;
	#Cargo todos los archivos que empiecen con 'ejecutado'
	while ( <$path/ejecutado*>)
	{
		$nombresArchivos[$i] = $_;
		$i++;
	}
	#Abro archivo de presupuesto sancionado de año corriente
	open($sancionado,'<',$path. "/sancionado-2016.csv");

	#guardo los cuatrimestres en una lista en ves de estar preguntando uno por uno	
	print "Ingrese la lista de trimestres a filtrar (1,2,3,4) separados por comas, si no ingresa ningun trimestre asume que quiere todos:";
	$linea=<STDIN>;
	chop $linea;	
	@campos=split (",", $linea);
	@trimestres;
	if (! @campos){
		#si esta vacia quiere todos
		@trimestres[0]="Primer";
		@trimestres[1]="Segundo";
		@trimestres[2]="Tercer";
		@trimestres[3]="Cuarto";
	}
	else{
		#remplazo valores numericos por strings
		foreach $trimestre (@campos){
			if ($trimestre=~ /^\s*1\s*$/){
				push @trimestres,"Primer";
			}
			elsif ($trimestre=~ /^\s*2\s*$/){
				push @trimestres, "Segundo";
			}
			elsif ($trimestre=~ /^\s*3\s*$/){
				push @trimestres, "Tercer";
			}
			elsif ($trimestre=~ /^\s*4\s*$/){
				push @trimestres, "Cuarto";
			}
			else{
				die("error: cuatrimestres no valido");
			}
		}
	}
	#hago lo mismo con los centros
	print "Ingrese centros a filtrar, puede ser una lista, en la lista puede haber rangos (centro1,centro2,rango), si no\n";
	print  "ingresa nada asume que quiere todos:";
	$linea=<STDIN>;
	chop $linea;
	@centros=split (",", $linea);
	#elimino espacios en blancos
	if (!@centros){
		#pusheo un rango que cubre todos los centros
		push @centros, ".*";
	}
	else{
		foreach $centro (@centros){
			#elimino posibles espacios ingresados por el usario
			$centro=~ s/^\s*//;
			$centro=~ s/\s*$//;
		}
	}
	#por cada trimestre en la lista
	foreach	$trimestre (@trimestres){
		#Cargo presupuesto sancionado para cada centro en la lista
		cargarPresupuestos (%presTrimestre, $trimestre);

		$i = 0;

		#Busco todos los registros del trimestre indicado
		buscarRegistrosPorTrimestreYCentros ($trimestre, @registrosBuscados, @centros);

		printf "ID	Fecha	Centro               Actividad    	Trimestre         Importe    Saldo  Control \n";
		calcularYMostrarSaldos (%presTrimestre, @registrosBuscados);
	}
close($sancionado);

}




