import processing.serial.*;
import controlP5.*;

Serial puerto;
ControlP5 control;
Bang botonIniciar, botonParar;

//_______________________________________________________________________________________



String dato;
int[] valor = new int[8];
int canal = 0;
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
  //_______________________________________________________________________________________
  
  fill(0);
  textSize(12);
  text(valor[0],151,570-(valor[0]/4));
  text(valor[1],226,570-(valor[1]/4));
  text(valor[2],301,570-(valor[2]/4));
  text(valor[3],376,570-(valor[3]/4));
  text(valor[4],451,570-(valor[4]/4));
  text(valor[5],526,570-(valor[5]/4));
  text(valor[6],601,570-(valor[6]/4));
  text(valor[7],676,570-(valor[7]/4));

     
  fill(255,0,0);
  stroke(0,0,255);
  rect(131,580,74,-valor[0]/4);
 
  rect(206,580,74,-valor[1]/4);

  rect(281,580,74,-valor[2]/4);

  rect(356,580,74,-valor[3]/4);

  rect(431,580,74,-valor[4]/4);

  rect(506,580,74,-valor[5]/4);

  rect(581,580,74,-valor[6]/4);

  rect(656,580,74,-valor[7]/4);
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

void serialEvent (Serial puerto){    //equivalente a una interrupcion para recibir datos del puerto serial
    
    if(puerto.available()>=0){
      dato = puerto.readStringUntil('\n');
    
    if(dato!=null){
      println(dato);
      valor[canal] = Integer.parseInt(dato.trim());
      canal++;
    }
    if(canal>7){
      canal = 0;
    }
  }
}
