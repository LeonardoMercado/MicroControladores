import processing.serial.*;
import controlP5.*;

Serial puerto;
ControlP5 control;

Toggle BtnComOn;
Button BtnComOff;

String dato;
int[] valor = new int[8];


void setup(){
  size(800,650);

  control = new ControlP5(this);
  
  
  BtnComOn = control.addToggle("INICIAR_COM").setValue(0).setPosition(20,150)
  .setSize(60,60).setColorActive(color(255,0,0)).setColorBackground(color(255)).setFont(createFont("TraditionalArabic",12));
  
  BtnComOff = control.addButton("PARAR_COM").setValue(0).setPosition(130,150)
  .setSize(80,60).setColorActive(color(255,0,0)).setFont(createFont("TraditionalArabic",10));
  
  
  
  puerto = new Serial(this, "COM5", 19200);


  
  

  


}

void draw(){
  background(0);
  
  fill(255);
  textSize(30);
  text("LABORATORIO 8: MÓDULO ADC",200,80);
  textSize(20);
  text("Leonardo M. Benítez, Maria A. Arias, Daniel Diaz Coy, Marco Andres Lopez.",40,125);
  
  fill(255);
  rect(0,250,800,650);
  
  fill(230);
  rect(130,300,600,280);
  
  fill(0);
  pushMatrix();
  translate(50,490);
  rotate(-HALF_PI);
  translate(-50,-490);
  text("Distancia", 50,490);
  popMatrix();
  
  fill(0);
  line(115,300,115,580);
  
  line(100,580,115,580);
  line(100,524,115,524);
  line(100,468,115,468);
  line(100,412,115,412);
  line(100,356,115,356);
  line(100,300,115,300);
  
  fill(0);
  textSize(18);
  pushMatrix();
  translate(95,585);
  rotate(-HALF_PI);
  translate(-95,-585);
  text("0", 95,585);
  popMatrix();
  

  pushMatrix();
  translate(95,537);
  rotate(-HALF_PI);
  translate(-95,-537);
  text("200", 95,537);
  popMatrix();
  

  pushMatrix();
  translate(95,480);
  rotate(-HALF_PI);
  translate(-95,-480);
  text("400", 95,480);
  popMatrix();
  

  pushMatrix();
  translate(95,425);
  rotate(-HALF_PI);
  translate(-95,-425);
  text("600", 95,425);
  popMatrix();
  

  pushMatrix();
  translate(95,369);
  rotate(-HALF_PI);
  translate(-95,-369);
  text("800", 95,369);
  popMatrix();
  

  pushMatrix();
  translate(95,324);
  rotate(-HALF_PI);
  translate(-95,-324);
  text("1000", 95,324);
  popMatrix();
  
  text("S-3",151,600);
  text("S-2",226,600);
  text("S-1",301,600);
  text("S0",376,600);
  text("S1",451,600);
  text("S2",526,600);
  text("S3",601,600);
  text("S4",676,600);
  
  
  
  if(puerto.available()>=0){
    dato = puerto.readStringUntil('\n');
    if(dato!=null){
      valor[0] = Integer.parseInt(dato.trim());

    }
  }
     
  fill(255,0,0);
  stroke(0,0,255);
  rect(131,580,74,-valor[0]/4);
 
  rect(206,580,74,-valor[0]/2);

  rect(281,580,74,-valor[0]/3);

  rect(356,580,74,-valor[0]/1);

  rect(431,580,74,-valor[0]/2);

  rect(506,580,74,-valor[0]/3);

  rect(581,580,74,-valor[0]/2);

  rect(656,580,74,-valor[0]/1);
  stroke(0);
 
  
  
}

public void INICIAR_COM(){
    if(!BtnComOn.getBooleanValue()){
      puerto = new Serial(this, "COM5", 19200);
      println("Iniciar COM, conectado");
    }


}

public void PARAR_COM(){
  if(BtnComOn.getBooleanValue()){
    puerto.stop();
    BtnComOn.setState(false);
  }
}

/*
void serialEvent(){
    if(puerto.available()>0){
    dato = puerto.readStringUntil('\n');
    valor = Integer.parseInt(dato.trim());

  }
}*/
