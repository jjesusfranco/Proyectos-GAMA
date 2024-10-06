/**
* Name: testmodel
* Based on the internal empty template. 
* Author: JesusFranco
* Tags: 
* PRACTICA DEL SABADO 7 DE SEPTIEMBRE
*/



model testmodel

global {
	//geometry shape <-square(1000#m);
	//shape_file mi_archivo <- shape_file ("../includes/nha2.shp");
	//shape_file mi_archivo <- shape_file("../includes/nha2.shp"); //puedes jalarlo directamente 
	shape_file mi_archivo3<- shape_file("../inegi/calles_huenti.shp");
	shape_file mi_archivo2<- shape_file("../inegi/manzanas2.shp");
	

	//geometry shape <-envelope(mi_archivo3);
  	geometry shape <-envelope(mi_archivo2);
  	//geometry shape <-envelope(mi_archivo3);
	init{
	
	//create building from:mi_archivo;
	create manzana from:mi_archivo2 with:[
		pobtot::int(read("POBTOT")),
		p_60ymas::int(read("P_60YMAS"))
	];
	create persona number:100;	
	}
reflex principal {
	ask manzana {
		densidad <- pobtot/shape.area#m2;
		
		
	}
	list <float> mi_lista;
	//list<manzana> otra_lista;
	//list<persona> lista_personas;
	mi_lista <- manzana collect(each.densidad);
	float max_dens_value <- max(mi_lista);
	write mi_lista;
	write max_dens_value;
	ask manzana {
		densidad <- (densidad/max_dens_value)*100;
	}
	mi_lista <- manzana collect(each.densidad);
	write mi_lista;
}

}

species persona skills:[moving]{
	int estatura;
	int edad;
	string nombre;
	point ubicacion;
	init {
		location <- one_of(manzana).location;
		//location <- building[30].location;
		//location <- building[30].location;
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
species manzana {
	int pobtot;
	int p_60ymas;
	float densidad;
	rgb mi_color;
	aspect default{
		if(densidad<0.25){//valor de densidad baja
			mi_color <-#lime;
		}
		else if (densidad<0.50){
			mi_color <-#yellow;
		}
		else if (densidad<0.75){
			mi_color <-rgb (249, 49, 69, 255);
			
		}
		else{
			mi_color <-#red;
		}
		draw shape color:mi_color;
		//rojointenso, rojo, amarillo, verde
		
	}
}	

species huenti{
	aspect default{
		draw shape color:#deepskyblue;
	}
}
experiment mi_experimento{
	output {
		display mi_visualizacion {
			species huenti aspect:default;
			species manzana aspect:default;
			species persona aspect:normal;
			
		}
		//display otra_visua {}
	}
}

experiment otro_experimento {
	output{
		
	}
}
experiment batch_experiment type:batch until:cycle>50{
	
}
/*experiment otro_experimento{
	output {}
}/

/* Insert your model definition here */

