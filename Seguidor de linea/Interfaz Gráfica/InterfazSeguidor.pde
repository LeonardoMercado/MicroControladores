import processing.serial.*;
import controlP5.*;
import meter.*;

Serial puerto;
ControlP5 control;
Bang botonIniciar, botonParar;
Meter m;
Meter m1;

//_______________________________________________________________________________________

int ancho=1620;
int alto=912;


int setPoint=14332;
int[] sensor = new int[8];
int[] sensorAux = new int[16];
int canal = 0;
int posicion = 0;
int[] posAux = new int[2];
int errorPos = 0;
int signoError = 0;
int[] errorAux = new int[2];

int contador = 0;
int j=0;
boolean recibir=false;

int[] inMotor = new int[2];
int[] inMotorAux = new int[4];

int valueMotorL = 0;
int valueMotorR = 0;
int auxL = 0;
int auxR = 255;
//_______________________________________________________________________________________

void setup(){
  
  size(1620,912);
  control = new ControlP5(this);
  botonIniciar = control.addBang("Iniciar").setPosition(60,40).setSize(80, 47)
                    .setFont(createFont("Times new roman", 16))
                    .setCaptionLabel("  Iniciar \n    COM");
  botonParar = control.addBang("Parar").setPosition(160, 40).setSize(80, 47)
                  .setFont(createFont("Times new roman", 16))
                  .setCaptionLabel("   Parar \n    COM");
  
 //_________________________________________MOTOR IZQUIERDO_____________________________________________________________//
 
  // Display a full circle meter frame.
  m = new Meter(this, 50, 250, true); // Instantiate a full circle meter class.
  m.setTitleFontSize(18);
  m.setTitleFontName("Arial Bold Italic");
  m.setTitleFontColor(color(0, 0, 0));
  // Move title down
  m.setTitleYOffset(24);  // default is 12 pixels
  // Define where the scale labele will appear
  m.setArcMinDegrees(180); // (start)
  m.setArcMaxDegrees(360); // ( end)
  // Set the meter values to correspond to the sensor readings.
  m.setMinScaleValue(0);
  m.setMaxScaleValue(80);
  String[] scaleLabels = {"0", "5", "10", "15", "20", "25", "30","35", "40", "45","50","55", "60", "65","70", "75","80"};
  m.setScaleLabels(scaleLabels);
  // Change the title from the default "Voltage" to a more meaningful label.
  m.setTitle("Velocidad angular Motor Izquierdo [Rad/s]");  
  
   //_________________________________________MOTOR DERECHO_____________________________________________________________//
  
  
  m1 = new Meter(this, 1150, 250, true); // Instantiate a full circle meter class.
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
  m1.setMaxScaleValue(80);
  //String[] scaleLabels = {"0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "110", "120"};
  m1.setScaleLabels(scaleLabels);
  // Change the title from the default "Voltage" to a more meaningful label.
  m1.setTitle("Velocidad angular Motor Derecho [Rad/s]");
  
}

void draw(){
  background(0);
  //______________________________________________________________________________________________
  
  /*********************************** ENCABEZADO ***********************************************/
  
  //______________________________________________________________________________________________
  fill(255);
  textSize(30);
  textAlign(CENTER);
  text("SEGUIDOR DE LÍNEA", ancho/2,60);
  textSize(20);
  text("Leonardo M. Benítez, Maria A. Arias, Daniel Diaz Coy, Marco Andres Lopez.",ancho/2,120);
  
  //______________________________________________________________________________________________
  
  /********************************* GRAFICOS DE POSICION **************************************/
  
  //______________________________________________________________________________________________
  
  // Marco Central Lectura vs Sensor  
  fill(255);
  rect(0,160,ancho,752);  
  
  fill(230);
  rect(590,250,520,450);
      
  //Barra Posición
  stroke(255,171,171);
  fill(255,171,171);
  rect(590,760,520,25);
  
  //Barra Error
  stroke(171,171,255);
  fill(171,171,255);
  rect(590,830,520,25);
  
  stroke(0);
  fill(0);

  textAlign(CENTER);
  text("Posición", 590+520/2,230);
  
  int h=300;  
  int h1=(400)/5;  
   
  fill(255,0,0);
  line(580,h,580,700); 
  
  // Etiquetas Sensores
  
  line(565,h+5*h1,580,h+5*h1);
  line(565,h+h1,580,h+h1);
  line(565,h+2*h1,580,h+2*h1);
  line(565,h+3*h1,580,h+3*h1);
  line(565,h+4*h1,580,h+4*h1);
  line(565,h,580,h);
 
  fill(0);
  textSize(14);
  pushMatrix();
  translate(95,700);
  translate(-95,-700);
  textAlign(RIGHT);
  text("0", 555,700);
  popMatrix();  

  pushMatrix();
  translate(95,h+4*h1);
  translate(-95,-537);
  text("819", 555,537);
  popMatrix();
  
  pushMatrix();
  translate(95,h+3*h1);
  translate(-95,-480);
  text("1638", 555,480);
  popMatrix();
  
  pushMatrix();
  translate(95,h+2*h1);
  translate(-95,-425);
  text("2457", 555,425);
  popMatrix();
  
  pushMatrix();
  translate(95,h+h1);
  translate(-95,-369);
  text("3276", 555,369);
  popMatrix();  

  pushMatrix();
  translate(95,h);
  translate(-95,-324);
  text("4095", 555,324);
  popMatrix();
   
  textAlign(CENTER);
  int sep=65;
  text("S1",590-sep/2+sep*1,720);
  text("S2",590-sep/2+sep*2,720);
  text("S3",590-sep/2+sep*3,720);
  text("S4",590-sep/2+sep*4,720);
  text("S5",590-sep/2+sep*5,720);
  text("S6",590-sep/2+sep*6,720);
  text("S7",590-sep/2+sep*7,720);
  text("S8",590-sep/2+sep*8,720);  
  
  // Actualización barras sensores, posición y error
  
  fill(0);
  textSize(12);
  text(sensor[0],590-sep/2+sep*1,280);
  text(sensor[1],590-sep/2+sep*2,280);
  text(sensor[2],590-sep/2+sep*3,280);
  text(sensor[3],590-sep/2+sep*4,280);
  text(sensor[4],590-sep/2+sep*5,280);
  text(sensor[5],590-sep/2+sep*6,280);
  text(sensor[6],590-sep/2+sep*7,280);
  text(sensor[7],590-sep/2+sep*8,280);
  text(posicion,590+520/2,800);
  text(errorPos,590+520/2,870);
  
  /*********************************/ 
  
  fill(255,0,0);
  stroke(0);
  rect(590,h+h1*5,sep,-map(sensor[0],0,4095,0,5*h1)); 
  rect(590+sep*1,h+h1*5,sep,-map(sensor[1],0,4095,0,5*h1));
  rect(590+sep*2,h+h1*5,sep,-map(sensor[2],0,4095,0,5*h1));
  rect(590+sep*3,h+h1*5,sep,-map(sensor[3],0,4095,0,5*h1));
  rect(590+sep*4,h+h1*5,sep,-map(sensor[4],0,4095,0,5*h1));
  rect(590+sep*5,h+h1*5,sep,-map(sensor[5],0,4095,0,5*h1));
  rect(590+sep*6,h+h1*5,sep,-map(sensor[6],0,4095,0,5*h1));
  rect(590+sep*7,h+h1*5,sep,-map(sensor[7],0,4095,0,5*h1)); 
  
  stroke(255,0,0);
  rect(590,760,map(posicion,0,28665,0,520),25);  
  stroke(0);
  
  stroke(0,0,255);
  fill(0,0,255);
  rect(590+520/2,830,map(errorPos,-setPoint,setPoint,-520/2,520/2),25);  
  stroke(0); 
  
//______________________________________________________________________________________________
  
/************************* GRAFICOS VELOCIDADES MOTOR IZQUIERDO *********************************/
  
//______________________________________________________________________________________________
  
  // velocidad Angular    

  valueMotorL = int(map(inMotor[0],0,80,0,255)); 
  // Display the new sensor value.
  m.updateMeter(valueMotorL);
  
  delay(10); // Allow time to see the change.  
  
  textSize(16);
  text(valueMotorL,270,520);
 
 //______________________________________________________________________________________________
  
/************************* GRAFICOS VELOCIDADES MOTOR DERECHO *********************************/
 
  valueMotorR = int(map(inMotor[1],0,80,0,255)); 
  // Display the new sensor value.
  m1.updateMeter(valueMotorR);
  delay(10); // Allow time to see the change. 
  textSize(16);
  text(valueMotorR,1370,520);  
  

//______________________________________________________________________________________________
  
  // Marcos velocidad angular
  
  strokeWeight(10);
  fill(255);
  stroke(255);  
  line(50,698,490,698);
  line(50,535,50,698);
  line(490,535,490,698);
  
  line(1150,698,1590,698);
  line(1150,535,1150,698);
  line(1590,535,1590,698);
  
  stroke(0);
  strokeWeight(4); 
  line(52,530,488,530);
  line(1152,530,1588,530);  
  
//______________________________________________________________________________________________
  
  strokeWeight(1);
  stroke(0);
  
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
    sensor[i] = 0;    
  }
  recibir=false;
  contador=0;
  canal=0;
}

//RECEPCIÓN DE DATOS.

void serialEvent(Serial puerto) { 
  /********************  Sincronización (Caracter de verificación)  **************/
  while(puerto.available()>0 & !recibir){
    int dato_verif=puerto.read();
    println("dato_verif=", dato_verif);
    if(char(dato_verif)=='S'){     
      recibir=true;
    }
  }
  /*Recepción de datos ADC*/
  if(puerto.available()>0 & contador<16 & recibir){   
   sensorAux[contador] = puerto.read();  
   //println("dato numerico=",sensorAux[contador]);
   if((contador-1)%2==0){
     //println("parte baja",sensorAux[contador]);
     sensor[canal]=sensorAux[contador-1];
     sensor[canal]=sensor[canal]<<8;
     sensor[canal]+=sensorAux[contador];
     println(canal,":",sensor[canal]);  
     /*Ciclo para tomar muestras (calibración sensores)*/
     if(j==10){
       Parar();
     }
     if(canal==7){
         canal=-1;
         //j++;
     }
     /************  Ciclo para tomar muestras (calibración sensores)  ************/
     canal++;
    }else{
      
    }
    /*
     if(contador==15){
       contador=-1;
     }  
    */
    contador++;
  }
  
  
  /**************************  Recepción de Posición  **************************/
  
 
  if(puerto.available()>0 & contador<18 & recibir){ 
     if(contador==16){
       posAux[0]=puerto.read();
     } 
     if(contador==17){
       posAux[1]=puerto.read();       
       //contador=-1;
     } 
     posicion=posAux[0];
     posicion=posicion<<8;
     posicion+=posAux[1]; 
     contador++;
  }
  
  /**********************  Recepción del Error de Posición  **********************/

  if(puerto.available()>0 & contador<21 & recibir){ 
     if(contador==18){
       signoError=puerto.read();
       //println("signo",signoError);
     } 
     if(contador==19){
       errorAux[0]=puerto.read();       
       //println("parte alta",errorAux[0]);
     } 
     if(contador==20){
       errorAux[1]=puerto.read();
       //println("parte baja",errorAux[1]);
       contador=-1;
     } 
     errorPos=errorAux[0];     
     errorPos=errorPos<<8;
     errorPos+=errorAux[1];     
     if(signoError=='N'){
        errorPos=errorPos*(-1); 
     }
    // println("error",errorPos);
     contador++;
  } 
  
} 
