/**
* Name: NewModel
* Based on the internal empty template. 
* Author: michailroussos
* Tags: 
*/


model NewModel

global {
	int numberOfPeople <- 10;
	int numberOfFoodStores <- 2;
	int numberOfDrinkStores <- 2;
	int numberOfCenters <- 1;
	
	// All the statements under this init scope will be computed once, at the begining of our simulation. 
	init {
		create FestivalGuest number:numberOfPeople;
		create FestivalStore number:numberOfFoodStores with:(hasFood:true,hasDrinks:false);
		create FestivalStore number:numberOfDrinkStores with:(hasFood:false,hasDrinks:true);
		create InformationCenter number:numberOfCenters with:(targetPoint:{10,10,10});
		
		loop counter from: 1 to: numberOfFoodStores + numberOfDrinkStores{
	        FestivalStore store <- FestivalStore[counter - 1];
		}
	}	
}


/* Insert your model definition here */

species FestivalGuest skills:[moving]
{	bool isHungry;
	bool isThirsty;
	list visitedFoodStores;
	list visitedDrinkStores;
	init{
		isHungry <- false; // update: flip(0.5);
		isThirsty <- false; // update: flip(0.5);
		visitedFoodStores <- [];
		visitedDrinkStores <- [];
	}

	string headedTo<-nil;
	
	point targetPoint <- nil;

	
	reflex beIdle when: targetPoint = nil
	{
		do wander;
	}
	
	reflex goToTarget when: isHungry=true or isThirsty=true
	{
		if(headedTo= nil){
			ask InformationCenter{			
				myself.targetPoint<-self.location;
				myself.headedTo<-"InfoCenter";
			}
		}
	}
	
	action printLocation {
		write "The target of guest :" + targetPoint;
	}
	
	reflex changeStatus when: (isHungry=false and isThirsty=false){
		if flip(0.2){
			isHungry<-true;
		}
		else if flip(0.2){
			isThirsty<-true;
		}
		else if flip(0.01){
			isHungry<-true;
			isThirsty<-true;
		}
		else{
			isHungry<-false;
			isThirsty<-false;
		}
	}
	
	reflex moveToTarget when: targetPoint !=nil
	{
		do goto target:targetPoint;
	}
	
	reflex enterStore when: (targetPoint != nil) and (location distance_to(targetPoint) < 2)
	{	
		
		if(headedTo="InfoCenter"){
			ask InformationCenter  {
				FestivalStore nearest <- FestivalStore(self.which_store(myself.isHungry, myself.isThirsty));
				myself.targetPoint <-nearest.location;
				if (nearest.hasFood=true and nearest.hasDrinks=false){
					myself.headedTo<-"FoodStore";
					myself.visitedFoodStores<-myself.visitedFoodStores + nearest;
				}else if (nearest.hasFood=false and nearest.hasDrinks=true) {
					myself.headedTo<-"DrinksStore";
					myself.visitedDrinkStores<-myself.visitedDrinkStores + nearest;
				}else if (nearest.hasFood=true and nearest.hasDrinks=true){
					myself.headedTo<-"FoodStore";
					myself.visitedFoodStores<-myself.visitedFoodStores + nearest;
				}else{
					write "Unknown Target";
					myself.targetPoint<-nil;
					myself.isHungry<-false;
					myself.isThirsty<-false;
				}
			}
		}	
		else if ( headedTo ="FoodStore" ){
			self.isHungry<-false;
			self.targetPoint<-nil;
			self.headedTo<-nil;
		}
		else if ( headedTo ="DrinksStore" ){
			self.isThirsty<-false;
			self.targetPoint<-nil;
			self.headedTo<-nil;
		}
		else {
			headedTo<-nil;
			targetPoint<-nil;
			isHungry<-false;
			isThirsty<-false;
		}
	}
	
	// Visual Aspect
	aspect base {
		rgb agentColor <- rgb("green");
		
		if (isHungry and isThirsty) {
			agentColor <- rgb("red");
		} else if (isThirsty) {
			agentColor <- rgb("darkorange");
		} else if (isHungry) {
			agentColor <- rgb("purple");
		}
		
		draw circle(1) color: agentColor;
	}
}

species FestivalStore
{
	bool hasFood;
	bool hasDrinks;
	point targetPoint <- nil;
	
//	reflex beIdle when: targetPoint !=nil
//	{
//		
//	}
//	
//	reflex moveToTarget when: targetPoint !=nil
//	{
//
//	}
//	
//	reflex enterStore when: location distance_to(targetPoint) < 2
//	{
//		//Do Something here
//	}
	
	aspect base {
		rgb storeColor <- rgb("blue");
		
		if (hasFood=true and hasDrinks=false) {
			storeColor <- rgb("purple");
		} else {
			storeColor <- rgb("darkorange");
		}
		
		draw square(2) color: storeColor;
	}
}


species InformationCenter
{
	init {
		location <-{10,10,10};
		shape <-circle(1);
	}
	point targetPoint;
	string name;
	
	action printLocation {
		write "The location of info center :" + location;
	}
	
	
//	reflex beIdle when: targetPoint !=nil
//	{
//		
//	}
//	
//	reflex moveToTarget when: targetPoint !=nil
//	{
//
//	}
//	
//	reflex enterStore when: location distance_to(targetPoint) < 2
//	{
//		//Do Something here
//	}
	
	FestivalStore which_store(bool isHungry, bool isThirsty){
		float minDist <- #max_float;
		FestivalStore nearestStore;
		loop counter from: 1 to: numberOfFoodStores + numberOfDrinkStores{
	        FestivalStore store <- FestivalStore[counter - 1];
	        
	        point storeLocation <- store.location;
	        point infCenterLocation <-targetPoint;
	        float distance <- distance_to(storeLocation, infCenterLocation);
	        write "distance to store " + counter + " is" + distance;
	        if (distance < minDist) {
	        	
	        	if (isHungry=true and store.hasFood=true){
		        	minDist<-distance;
		        	nearestStore<-store;
		        	}
		        else if (isThirsty=true and store.hasDrinks=true){
		        	minDist<-distance;
		        	nearestStore<-store;
		        }
		        else{}
	        }
	        
//	        write store;
//	        write store.hasFood;
		}
		write "nearest store is: " + nearestStore;
		return nearestStore;
	}

	aspect base {
		rgb infoCenterColor <- rgb("magenta");
		/*
		if (isHungry and isThirsty) {
			agentColor <- rgb("red");
		} else if (isThirsty) {
			agentColor <- rgb("darkorange");
		} else if (isHungry) {
			agentColor <- rgb("purple");
		}
		*/
		draw hexagon(3) color: infoCenterColor;
	}
}


experiment myExperiment type:gui {
	output {
		display myDisplay {
			// Display the species with the created aspects
			species FestivalGuest aspect:base;
			species FestivalStore aspect:base;
			species InformationCenter aspect:base;
			
		}
	}
}
