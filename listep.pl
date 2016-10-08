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

sub buscarRegistrosPorTrimestre
{
	$i = 0;
	foreach $nombreArchivo (@nombresArchivos)
		{
			open($archivo, '<', $nombreArchivo);
			
			while($linea = <$archivo>)
			{
				if (index($linea,$_[0]) != -1)
				{
					$registrosBuscados[$i] = $linea;
					$i++;
				}
			}
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
$path ="/home/marcelo/Descargas/SistemasOperativos/datos";
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

	printf "Elija como filtrar los registros \n";
	printf "1- un solo trimestre \n";
	printf "2- Varios trimestres \n";
	printf "3- Todos los Trimestres \n";
	

	$optrimestre = <STDIN>; 
	if ($optrimestre == 1)
	{
		printf "Seleccione por cual trimestre desea filtrar \n";
		printf "1- Primer \n";
		printf "2- Segundo \n";
		printf "3- Tercer \n";
		printf "4- Cuarto \n";
		$optrimestre = <STDIN>;
		if($optrimestre == 1)
		{
			$trimestreABuscar = "Primer";
		}
		if($optrimestre == 2)
		{
			$trimestreABuscar = "Segundo";
		}
		if($optrimestre == 3)
		{
			$trimestreABuscar = "Tercer";
		}
		if($optrimestre == 4)
		{
			$trimestreABuscar = "Cuarto";
		}
		
		#Cargo presupuesto sancionado para cada centro
		cargarPresupuestos (%presTrimestre,$trimestreABuscar);

		$i = 0;

		#Busco todos los registros del trimestre indicado
		buscarRegistrosPorTrimestre ($trimestreABuscar,@registrosBuscados);

		printf "ID	Fecha	Centro               Actividad    	Trimestre         Importe    Saldo  Control \n";

		#Itero por cada centro
		calcularYMostrarSaldos (%presTrimestre, @registrosBuscados);

	} #fin optrimestre = 1
	if($optrimestre == 3)
	{
		#No hay nada ejecutado en el cuarto trimestre de 2016 (todavia no termino)
		@todosLosTrimestres = ("Primer","Segundo","Tercer");
		foreach $trimestre (@todosLosTrimestres)
		{
			splice (@registrosBuscados);
			undef %{$presTrimestre};
			cargarPresupuestos (%presTrimestre,$trimestre);
			buscarRegistrosPorTrimestre ($trimestre,@registrosBuscados);
			calcularYMostrarSaldos (%presTrimestre,@registrosBuscados);
			#falta descontar saldo negativo de trimestre anterior
		}
	}
close($sancionado);

}




