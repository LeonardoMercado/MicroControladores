import processing.serial.*;
import controlP5.*;
import meter.*;

Meter m;
Meter m1;
Serial puerto;
ControlP5 control;
Bang botonIniciar, botonParar;

//_______________________________________________________________________________________



String dato;
int[] valor = new int[8];
int[] valorAux = new int[16];
int canal = 0;
int contador = 0;
boolean recibir=false;
int valueMotorL = 0;
int valueMotorR = 0;

int auxL = 0;
int auxR = 255;

//_______________________________________________________________________________________

void setup(){
  size(1350,650);
  control = new ControlP5(this);

  botonIniciar = control.addBang("Iniciar").setPosition(20+600,100).setSize(60, 40)
                    .setFont(createFont("Liberation Sans Narrow Bold", 16))
                    .setCaptionLabel("Iniciar \n COM");
  botonParar = control.addBang("Parar").setPosition(90+600, 100).setSize(60, 40)
                  .setFont(createFont("Liberation Sans Narrow Bold", 16))
                  .setCaptionLabel("Parar \n COM");
                  
  //------------------------------------------------------------------------------------------------------------------- 
  //-----M--------
  // Display a full circle meter frame.
  m = new Meter(this, 10, 200, true); // Instantiate a full circle meter class.
  m.setTitleFontSize(18);
  m.setTitleFontName("Arial Bold Italic");
  m.setTitleFontColor(color(0, 0, 0));
  // Move title down
  m.setTitleYOffset(24);  // default is 12 pixels
  // Define where the scale labele will appear
  m.setArcMinDegrees(180.0); // (start)
  m.setArcMaxDegrees(360.0); // ( end)
  // Set the meter values to correspond to the sensor readings.
  m.setMinScaleValue(0);
  m.setMaxScaleValue(255);
  String[] scaleLabels = {"0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "110", "120"};
  m.setScaleLabels(scaleLabels);
  // Change the title from the default "Voltage" to a more meaningful label.
  m.setTitle("Velocidad angular Motor Izquierdo [Rad/s]");
 
  // Display the digital meter value.
  m.setDisplayDigitalMeterValue(true);
  //-------------------------------------------------------------------------------------------------------------------
  
  
  //------------------------------------------------------------------------------------------------------------------- 
  //-----M1--------
  // Display a full circle meter frame.
  m1 = new Meter(this, 900, 200, true); // Instantiate a full circle meter class.
  m1.setTitleFontSize(18);
  m1.setTitleFontName("Arial Bold Italic");
  m1.setTitleFontColor(color(0, 0, 0));
  // Move title down
  m1.setTitleYOffset(24);  // default is 12 pixels
  // Define where the scale labele will appear
  m1.setArcMinDegrees(180.0); // (start)
  m1.setArcMaxDegrees(360.0); // ( end)
  // Set the meter values to correspond to the sensor readings.
  m1.setMinScaleValue(0);
  m1.setMaxScaleValue(255);
  //String[] scaleLabels = {"0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "110", "120"};
  m1.setScaleLabels(scaleLabels);
  // Change the title from the default "Voltage" to a more meaningful label.
  m1.setTitle("Velocidad angular Motor Derecho [Rad/s]");
  // Display the digital meter value.
  m1.setDisplayDigitalMeterValue(true);
  //-------------------------------------------------------------------------------------------------------------------
  

  background(0);
  

}

void draw(){
  //background(0);
  
  //_______________________________________________________________________________________
  fill(255);
  textSize(30);
  text("Laboratorio 9: Módulo TPM",500,40);
  textSize(20);
  text("Maria A. Arias, Leonardo M. Benítez, Daniel Diaz Coy, Marco Andres Lopez.",330,85);
  //_______________________________________________________________________________________
  
  //_______________________________________________________________________________________
  fill(255);
  stroke(0,0,255);     
  strokeWeight(1);
  rect(475,200,400,200);
  rect(475,420,400,200);
  stroke(0);
  
  strokeWeight(3);
  line(475,360,875,360);
  line(475,580,875,580);
  strokeWeight(0);  
  //_______________________________________________________________________________________
  
  
  

  strokeWeight(1);
  fill(255);
  int x = 525;
  while(x<875){
    fill(0);
    line(x,200,x,650);
    x = x + 50;
  }
  
  int y = 240;
  while(y<400){
    fill(0);
    line(475,y,875,y);
    y = y + 40;
  }
  
  int y2 = 460;
  while(y2<620){
    fill(0);
    line(475,y2,875,y2);
    y2 = y2 + 40;
  }
  //_______________________________________________________________________________________
  
  
  //_______________________________________________________________________________________
  stroke(255,0,0);
  strokeWeight(7);
  line(475, 360, 475, 360);
  
  //for(int i=0;i<255;i++){
  //  line(475+i, 360-i, 475+i, 360-i);
  //}
  
  //_______________________________________________________________________________________
  line(475, 580, 475, 580);
  //for(int i=0;i<255;i++){
  //  line(475+i, 580-i, 475+i, 580-i);
  //}
  stroke(0);

  
  
  
  
  fill(255);
  pushMatrix();
  translate(470,400);
  rotate(-HALF_PI);
  translate(-470,-400);
  textSize(16);
  text("Velocidad Motor IZQ (m/s)", 470,400);
  popMatrix();
  
  pushMatrix();
  translate(470,620);
  rotate(-HALF_PI);
  translate(-470,-620);
  textSize(16);
  text("Velocidad Motor DER (m/s)", 470,620);
  popMatrix();
  
  //_______________________________________________________________________________________
  ///////M1////////
  // Simulate sensor data.
  //valueMotorR = (int)random(0, 255);
  valueMotorR = auxR;
  auxR--;
  if(auxR<0){
    auxR=255;
  }
  // Display the new sensor value.
  m1.updateMeter(valueMotorR);
  delay(10); // Allow time to see the change.
  //_______________________________________________________________________________________
  
  
  //_______________________________________________________________________________________
  ///////M////////  
  // Simulate sensor data.  
  //valueMotorL = (int)random(0, 255);
  valueMotorL = auxL;
  auxL++;
  if(auxL>255){
    auxL=0;
  }
  // Display the new sensor value.
  m.updateMeter(valueMotorL);
  delay(10); // Allow time to see the change.
  //_______________________________________________________________________________________
  

 
 
}
void Iniciar(){                              //handler del boton Iniciar
  println("Iniciar COM, en proceso");
  puerto = new Serial(this, "COM5", 19200);
  puerto.clear();  
  puerto.write('T');
  println("Iniciar COM, conectado");
}
void Parar(){                                //handler del boton Parar
  println("Parar COM");
  puerto.clear();
  puerto.write('F');
  puerto.stop();
  for(int i = 0; i<8; i++){
    valor[i] = 0;    
  }
  recibir=false;
  contador=0;
  canal=0;
}

//RECEPCIÓN DE DATOS.

void serialEvent(Serial puerto) { 
  while(puerto.available()>0 & !recibir){
    int dato_verif=puerto.read();
    println("dato_verif=", dato_verif);
    if(char(dato_verif)=='S'){     
      recibir=true;
    }
  }
  if(puerto.available()>0 & contador<16 & recibir){   
   valorAux[contador] = puerto.read();  
   println("dato numerico=",valorAux[contador]);
   if((contador-1)%2==0){
     //println("parte baja",valorAux[contador]);
     valor[canal]=valorAux[contador-1];
     valor[canal]=valor[canal]<<8;
     valor[canal]+=valorAux[contador];
     println("H+L",valor[canal]);
     //println("canal= ",canal,"contador= ",contador);
     if(canal==7){
         canal=-1;
     }
     canal++;
    }else{
      //println("parte alta",valorAux[contador]);    
    }
     if(contador==15){
       contador=-1;
    }      
    contador++;
  }   
} 
