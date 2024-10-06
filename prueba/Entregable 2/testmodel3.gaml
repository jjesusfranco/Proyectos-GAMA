/**
* Name: testmodel3
* Based on the internal empty template. 
* Author: jesusf
* Tags: 
*/


model testmodel3

global{
	// Carga de un shapefile de frentes de manzana
	shape_file frentes_manzana_clip <- shape_file("../includes/inegi/frentes_manzana_clip.shp");

	// Carga de otro shapefile de manzanas (zona urbana)
	shape_file mi_archivo <- shape_file("../includes/inegi/huentitan2.shp");

	// Define una geometría basada en el contorno del shapefile de las manzanas
	geometry shape <- envelope(mi_archivo);

	// Mapa que asigna valores numéricos a tipos de recubrimientos de calles
	map<string,int> map_recubrimiento <- [
		"Empedrado o adoquín"::100,
		"Pavimento o concreto"::60,
		"Sin recubrimiento"::30,
		"Conjunto habitacional"::0,
		"No aplica"::0,
		"No especificado"::0
	];

	// Inicialización del modelo
	init{
		// Crea agentes "manzana" a partir del shapefile, asociando la población total y mayores de 60 años
		create manzana from:mi_archivo with:[
			pobtot::int( read("POBTOT") ),
			pob60ymas::int( read("P_60YMAS"))
		];

		// Crea 100 agentes de tipo "persona"
		create persona number:100;

		// Crea agentes "block_fronts" (frentes de manzana) con un atributo de recubrimiento de calle
		create block_fronts from:frentes_manzana_clip with:[
			recubrimiento::read("RECUCALL_D")
		];
	}
	
	// Reflex para calcular la densidad de población por manzana y normalizarla
	reflex principal{
		// Calcula la densidad de población para cada manzana
		ask manzana{
			densidad <- pobtot / shape.area#m2;
		}

		// Crea una lista para almacenar las densidades de todas las manzanas
		list<float> mi_lista;
		mi_lista <- manzana collect(each.densidad);

		// Calcula la densidad máxima
		float max_dens_value <- max(mi_lista);

		// Normaliza las densidades en base a la máxima densidad
		ask manzana{
			densidad <- (densidad / max_dens_value) * 100;
		}

		// Escribe las densidades normalizadas
		mi_lista <- manzana collect(each.densidad);
		write mi_lista;
	}
}

species persona skills:[moving]{
	// Atributos de las personas
	float estatura;
	int edad;
	string nombre;
	point ubicacion;

	init{
		// Asigna una ubicación inicial al azar en una de las manzanas
		location <- one_of(manzana).location;
		estatura <- 1.70#cm;
	}

	// Comportamiento de movimiento aleatorio
	reflex{
		do wander;
	}

	// Visualización de las personas como círculos de color
	aspect default{
		draw circle(5) color:rgb (68, 196, 167, 255);
	}
}

species manzana{
	// Atributos de las manzanas
	int pobtot;       // Población total
	int pob60ymas;    // Población mayor de 60 años
	float densidad;   // Densidad de población calculada
	rgb mi_color;     // Color para visualización
	int transparencia <- 80; // Nivel de transparencia

	// Definición de aspecto según densidad de población
	aspect default{
		if(densidad < 25){ // Densidad baja
			mi_color <- rgb (66, 174, 30, transparencia); // Verde
		} else if(densidad < 50){
			mi_color <- rgb (234, 196, 43, transparencia); // Amarillo
		} else if(densidad < 75){
			mi_color <- rgb (230, 74, 47, transparencia);  // Rojo claro
		} else {
			mi_color <- rgb (140, 4, 4, transparencia);    // Rojo intenso
		}
		draw shape color:mi_color;
	}
}

species block_fronts{
	// Atributo que indica el tipo de recubrimiento
	string recubrimiento;
	rgb mi_color;

	// Visualización del recubrimiento de calles según el mapa de valores
	aspect default{
		int valor_numerico <- map_recubrimiento[recubrimiento];
		if(valor_numerico = 100){
			mi_color <- #limegreen;
		} else if(valor_numerico = 60){
			mi_color <- #gamaorange;
		} else if(valor_numerico = 30){
			mi_color <- rgb (249, 249, 0, 255); // Amarillo
		} else {
			mi_color <- #red; // Rojo para los valores más bajos o no aplicables
		}	
		draw shape color:mi_color width:5.0;
	}
}

experiment mi_experimento{
	// Configuración de visualización
	output{
		display mi_visualizacion background:#black{
			species manzana aspect:default;
			species block_fronts aspect:default;
			species persona aspect:default;
		}
	}
}

experiment otro_experimento{
	output{
		// Puede añadirse otra visualización o comportamientos aquí
	}
}

experiment batch_experiment type:batch until:cycle>50{
	output{
		// Puede guardar datos de las personas al finalizar la simulación
		//save persona file:"personas.shp" type:"shp";
	}
}
