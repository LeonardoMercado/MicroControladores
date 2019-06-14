import processing.serial.*;
import controlP5.*;

Serial puerto;
ControlP5 control;
Bang botonIniciar, botonParar;

//_______________________________________________________________________________________



String dato;
int[] valor = new int[8];
int[] valorAux = new int[16];
int canal = 0;
int contador = 0;
//_______________________________________________________________________________________

void setup(){
  size(800,650);
  control = new ControlP5(this);

  botonIniciar = control.addBang("Iniciar").setPosition(20,150).setSize(60, 40)
                    .setFont(createFont("Liberation Sans Narrow Bold", 16))
                    .setCaptionLabel("Iniciar \n COM");
  botonParar = control.addBang("Parar").setPosition(90, 150).setSize(60, 40)
                  .setFont(createFont("Liberation Sans Narrow Bold", 16))
                  .setCaptionLabel("Parar \n COM");
}

void draw(){
  background(0);
  
  //_______________________________________________________________________________________
  fill(255);
  textSize(30);
  text("LABORATORIO 8: MÓDULO ADC",200,80);
  textSize(20);
  text("Leonardo M. Benítez, Maria A. Arias, Daniel Diaz Coy, Marco Andres Lopez.",40,125);
  //_______________________________________________________________________________________
  
  //_______________________________________________________________________________________
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
  
  int h=4095/16+70;
  int h1=(580-h)/5;
  
  fill(0);
  line(115,h,115,580);
  

  line(100,580,115,580);
  line(100,h+h1,115,h+h1);
  line(100,h+2*h1,115,h+2*h1);
  line(100,h+3*h1,115,h+3*h1);
  line(100,h+4*h1,115,h+4*h1);
  line(100,h,115,h);
  
  fill(0);
  textSize(14);
  pushMatrix();
  translate(95,580);
  //rotate(-HALF_PI);
  translate(-95,-585);
  text("0", 60,585);
  popMatrix();
  

  pushMatrix();
  translate(95,h+4*h1);
  //rotate(-HALF_PI);
  translate(-95,-537);
  text("819", 60,537);
  popMatrix();
  

  pushMatrix();
  translate(95,h+3*h1);
  //rotate(-HALF_PI);
  translate(-95,-480);
  text("1638", 60,480);
  popMatrix();
  

  pushMatrix();
  translate(95,h+2*h1);
  //rotate(-HALF_PI);
  translate(-95,-425);
  text("2457", 60,425);
  popMatrix();
  

  pushMatrix();
  translate(95,h+h1);
  //rotate(-HALF_PI);
  translate(-95,-369);
  text("3276", 60,369);
  popMatrix();
  

  pushMatrix();
  translate(95,h);
  //rotate(-HALF_PI);
  translate(-95,-324);
  text("4095", 60,324);
  popMatrix();
  
  text("S7",151,600);
  text("S6",226,600);
  text("S5",301,600);
  text("S4",376,600);
  text("S3",451,600);
  text("S2",526,600);
  text("S1",601,600);
  text("S0",676,600);
  //_______________________________________________________________________________________
  
  fill(0);
  textSize(12);
  text(valor[7],151,316);
  text(valor[6],226,316);
  text(valor[5],301,316);
  text(valor[4],376,316);
  text(valor[3],451,316);
  text(valor[2],526,316);
  text(valor[1],601,316);
  text(valor[0],676,316);

     
  fill(255,0,0);
  stroke(0,0,255);
  rect(131,580,74,-valor[7]/16);
 
  rect(206,580,74,-valor[6]/16);

  rect(281,580,74,-valor[5]/16);

  rect(356,580,74,-valor[4]/16);

  rect(431,580,74,-valor[3]/16);

  rect(506,580,74,-valor[2]/16);

  rect(581,580,74,-valor[1]/16);

  rect(656,580,74,-valor[0]/16);
  stroke(0);
 
 
}
void Iniciar(){                              //handler del boton Iniciar
  println("Iniciar COM, en proceso");
  puerto = new Serial(this, "COM5", 19200);
  println("Iniciar COM, conectado");
}
void Parar(){                                //handler del boton Parar
  println("Parar COM");
  puerto.stop();
  for(int i = 0; i<8; i++){
    valor[i] = 0;
  }
}

//RECEPCIÓN DE DATOS.

void serialEvent(Serial puerto) { 
  if(puerto.available()>0 & contador<16){   
   valorAux[contador] = puerto.read();   
   if((contador-1)%2==0){
     println("parte baja",valorAux[contador]);
     valor[canal]=valorAux[contador-1];
     valor[canal]=valor[canal]<<8;
     valor[canal]+=valorAux[contador];
     println("H+L",valor[canal]);
     println("canal= ",canal,"contador= ",contador);
     if(canal==7){
         canal=-1;
     }
     canal++;
    }else{
      println("parte alta",valorAux[contador]);    
    }
     if(contador==15){
       contador=-1;
    }      
    contador++;
  }   
} 
