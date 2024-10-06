/**
* Name: testmodel4
* Based on the internal empty template. 
* Author: JesusFranco
* Tags: Este es un cambio realizado desde mi laptop
*/

model testmodel4

global{
	
	// Cargar shapefiles geoespaciales que contienen la geometría del área a modelar
	shape_file manzana_shape_file <- shape_file("../includes/inegi/huentitan2.shp"); // Manzanas (bloques)
	shape_file frente_shape_file <- shape_file("../includes/inegi/frentes_manzana_clip.shp"); // Frentes de manzana
	shape_file roads_shp <- shape_file("../includes/inegi/roads.shp"); // Red de carreteras/calles
	shape_file corteOSM_shp <- shape_file("../includes/inegi/limit_huentitan.shp"); // Límite de la región (corte OSM)

	// Definir la geometría del área total a simular (usando el archivo de manzanas)
	geometry shape <- envelope(manzana_shape_file);

	// Grafo de carreteras (conectando las calles de la red)
	graph roads_network;
	
	// Campo de tráfico que se utilizará para visualizar el tráfico en una cuadrícula de 100x100
	field traffic <- field(100,100);

	// Mapa que asocia tipos de recubrimiento de calles con valores numéricos
	map<string,int> map_recubrimiento<-[ 
		"Empedrado o adoquín"::100, // Máxima calidad de calle
		"Pavimento o concreto"::60,  // Calle pavimentada
		"sin recubrimiento"::30,     // Calle sin pavimentar
		"Conjunto habitacional"::0,  // Sin valor
		"No aplica"::0,
		"No especificado"::0
	];
	
	init{
		// Crear entidades de carreteras a partir del shapefile de carreteras
		create road from:roads_shp;
		
		// Convertir las entidades de carreteras en un grafo para manejar conectividad entre nodos
		roads_network <- as_edge_graph(road,100);
		
		// Crear entidades de tipo manzana (bloques) desde el shapefile de manzanas, asignando atributos a partir del archivo
		create manzana from:manzana_shape_file with:[
			pobtot::int(read("POBTOT")),       // Población total
			viviendas_hab::int(read("TVIPAHAB")),  // Viviendas habitadas
			calles_pav::int(read("RECUCALL_C")),   // Calidad del recubrimiento de calles
			banquetas::int(read("BANQUETA_C")),    // Presencia de banquetas
			alumb_pub::int(read("ALUMPUB_C"))    // Alumbrado público
			
		];
		
		// Crear 100 entidades de personas
		create persona number:200;

		// Crear entidades de frentes de manzana desde el shapefile, asignando el tipo de recubrimiento de la calle
		create block_fronts from:frente_shape_file with:[
			recubrimiento::read("RECUCALL_D") // Tipo de recubrimiento
		];
	}
	
	// Reflex principal: se ejecuta en cada ciclo de simulación
	reflex principal{
		// Calcular la densidad de población discapacitada por área en cada manzana
		ask manzana{
			densidad <- pobtot/shape.area#m2; // Calcular densidad
		}

		// Crear una lista para almacenar las densidades
		list<float> mi_lista;
		
		// Recopilar las densidades de todas las manzanas en la lista
		mi_lista <- manzana collect(each.densidad);
		
		// Calcular el valor máximo de densidad de la lista
		float max_dens_value <- max(mi_lista); 

		// Escribir la lista de densidades y el valor máximo en la consola
		write mi_lista;
		write max_dens_value;

		// Normalizar las densidades dividiendo por el valor máximo y multiplicando por 100
		ask manzana{
			densidad <- (densidad/max_dens_value)*100;
		}
		
		// Actualizar la lista con las densidades normalizadas
		mi_lista <- manzana collect(each.densidad);
		write mi_lista; 
	}

	// Reflex para actualizar el mapa de calor del tráfico
	reflex update_heatmap{
		ask persona{
			// Incrementar el valor de tráfico en la ubicación actual de cada persona
			traffic[location] <- traffic[location] + 10;
		}
	}
}

species manzana {
	// Atributos de la manzana
	int pobtot;         // Población total
	int viviendas_hab;  // Viviendas habitadas
	int calles_pav;     // Calles pavimentadas
	int banquetas;      // Presencia de banquetas
	int alumb_pub;      // Alumbrado público
	float densidad;     // Densidad calculada de la población 
	rgb mi_color;       // Color para la visualización
	int transparencia <-80; // Transparencia para la visualización
	
	// Definir el aspecto visual de las manzanas
	aspect default{
		// Asignar color según la densidad poblacional
		if(densidad<25){
			mi_color <- #darkgreen; // Baja densidad
		}
		else if(densidad<50){
			mi_color <- #mediumspringgreen; // Media baja densidad
		}
		else if(densidad<75){
			mi_color <- #chocolate; // Media alta densidad
		}
		else{
			mi_color <- #red; // Alta densidad
		}
		// Dibujar la forma de la manzana con el color asignado
		draw shape color:mi_color;
	}
}

species persona skills:[moving]{
	// Atributos de las personas
	point home;    // Punto inicial de la persona
	point destiny; // Destino actual
	float estatura; // Estatura de la persona
	int edad;       // Edad de la persona
	string nombre;  // Nombre de la persona
	point ubicacion; // Ubicación actual

	init{
		// Asignar una ubicación de inicio (home) y un destino dentro de una manzana aleatoria
		home <-any_location_in(one_of(manzana));
		destiny <-any_location_in(one_of(manzana));
		location <-home;
		estatura <- 1.70#m; // Asignar una estatura
	}
	
	// Reflex para controlar el movimiento de las personas
	reflex movement{
		// Moverse hacia el destino usando la red de carreteras
		do goto target:destiny on:roads_network;
		
		// Si llega al destino, cambiar el destino al punto inicial (home)
		if(location=destiny){
			destiny <-home;
		} 
	}
	
	// Aspecto visual de las personas
	aspect default{
		draw circle(15) color:#red; // Dibujar un círculo rojo representando a la persona
	}
}

species block_fronts{
	// Atributos de los frentes de manzana
	rgb mi_color;          // Color para la visualización
	string recubrimiento;  // Tipo de recubrimiento de calle

	aspect default{
		// Asignar un color basado en el valor del recubrimiento (pavimento, empedrado, etc.)
		int valor_numerico <- map_recubrimiento [recubrimiento];
		if (valor_numerico=100){
			mi_color <- #limegreen; // Empedrado o adoquín
		}
		else if(valor_numerico=60){
			mi_color <- #gamaorange; // Pavimento o concreto
		}
		else if(valor_numerico=30){
			mi_color <- rgb (249,249,0,255); // Sin recubrimiento
		}
		else{
			mi_color <- #red; // Otros casos
		}
		// Dibujar la forma del frente con el color asignado y un ancho de línea de 5.0
		draw shape color:mi_color width:5.0;
	}
}

species road{
	// Definir el aspecto visual de las carreteras
	aspect default{
		draw shape color:#white; // Dibujar las carreteras en color blanco
	}
}

experiment mi_experimento{
	// Definir la visualización del modelo
	output{
		display mi_visualizacion background:#grey{
			// Mostrar el campo de tráfico con una paleta de colores
			mesh traffic color:palette([#black, #black, #orange, #orange, #red, #red, #red]) smooth:2;
			
			// Mostrar las especies
			species road aspect:default; // Carreteras
			species persona aspect:default; // Personas
		}
	}
}

