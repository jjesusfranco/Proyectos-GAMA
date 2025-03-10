

model testmodel

global {
	
	shape_file mi_archivo2<- shape_file("../inegi/mexticacan.shp");
	
//Cargas un shapefile (huentitan2.shp) y creas una geometría basada en el área total del archivo.

	
  	geometry shape <-envelope(mi_archivo2);

	init{
	
	
	create manzana from:mi_archivo2 with:[ //Inicializas la especie manzana a partir de los datos del shapefile, asignando valores como población total, población femenina, etc.
		pobtot::int(read("POBTOT")),
		pobfem::int(read("POBFEM")),
		pobmas::int(read("POBMAS")),
		vivtot::int(read("VIVTOT")),
		p_60ymas::int(read("P_60YMAS"))
		
];

	
	create persona number:100;	//creas 100 instancias de la especie persona.
	}
reflex principal {
	ask manzana {
		densidad <- pobfem/shape.area#m2; //Calculas la densidad de población femenina (pobfem) en cada manzana dividiendo por el área.
		
		
	}
	list <float> mi_lista; 
	mi_lista <- manzana collect(each.densidad);
	float max_dens_value <- max(mi_lista);
	write mi_lista;
	write max_dens_value;
	ask manzana {
		densidad <- (densidad/max_dens_value)*100;
	}
	mi_lista <- manzana collect(each.densidad);
	write mi_lista; //densidades normalizadas
}

}

species persona skills:[moving]{
	int estatura;
	int edad;
	string nombre;
	point ubicacion;
	init {
		location <- one_of(manzana).location;
		
	}reflex {
		do wander;
	}
	aspect normal{draw circle(20) color:#red;
	} 
}


species manzana {
	int pobtot;
	int p_60ymas;
	int pobfem;
	int pobmas;
	int vivtot;
	float densidad;
	rgb mi_color;
	rgb mi_color2 <-rgb (164, 251, 174, transparencia);
	int transparencia <- 150;
	aspect default{
		if(densidad<0.25){//valor de densidad baja
			mi_color <-rgb (164, 251, 174, transparencia);
		}
		else if (densidad<0.50){
			mi_color <-rgb (223, 232, 66, transparencia);
		}
		else if (densidad<0.75){
			mi_color <-rgb (213, 30, 75, transparencia);
			
		}
		else{
			mi_color <-#maroon;
		}
		draw shape color:mi_color;
		//rojointenso, rojo, amarillo, verde
		
	}
}	


experiment mi_experimento{
	output {
		display mi_visualizacion background:rgb (45, 45, 45, 255) {
			species manzana aspect:default;
			species persona aspect:normal;
			
			
			
		}
		
	}
}



