/**
* Name: testmodel
* Based on the internal empty template. 
* Author: JesusFranco
* Tags: 
*/


model test_model1

global {
	//geometry shape <-square(1000#m);
	//shape_file mi_archivo <- shape_file ("../includes/nha2.shp");
	//shape_file mi_archivo <- shape_file("../includes/nha2.shp"); //puedes jalarlo directamente 
	
	shape_file mi_archivo3<- shape_file("../includes/inegi/prueba.shp");

	shape_file mi_archivo2 <- shape_file("../includes/inegi/huentitan2.shp");

	//geometry shape <-envelope(mi_archivo);
  	geometry shape <-envelope(mi_archivo2);
	init{
	
	//create building from:mi_archivo;
	create building from:mi_archivo2 with:[
		pobtot::int(read("POBTOT")),
		p_60ymas::int(read("P_60YMAS"))
	];
	 create building from:mi_archivo3;
	create persona number:1000;
	
	}
}
species persona skills:[moving]{
	int estatura;
	int edad;
	string nombre;
	point ubicacion;
	init {
		//location <- one_of(building).location;
		//location <- building[30].location;
		location <- building[30].location;
	}reflex {
		do wander;
	}
	aspect normal{draw circle(8) color:#navy;
	} 
}

//species building {
	//aspect default{
	//	draw shape;
	//}
species building {
	int pobtot;
	int p_60ymas;
	aspect default{
		draw shape;
	}
}	

experiment mi_experimento{
	output {
		display mi_visualizacion {
			species building aspect:default;
			species persona aspect:normal;
			
		}
		//display otra_visua {}
	}
}

experiment otro_experimento {
	output{
		
	}
}
experiment batch_experiment type:batch until:cycle>50{ //Define un experimento de tipo batch que se ejecuta hasta el ciclo 50, útil para simulaciones automáticas sin visualización.
	
}
/*experiment otro_experimento{
	output {}
}/

/* Insert your model definition here */
