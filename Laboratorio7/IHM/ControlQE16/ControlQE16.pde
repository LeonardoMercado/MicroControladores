import processing.serial.*; //Importamos la libreria Serial y sus métodos
import controlP5.*;         //Importamos la libreria ControlP5 y sus métodos de inputText

 
Serial puerto;              //Objeto de tipo Serial.
ControlP5 control5;         //Objeto de tipo ControlP5
String conectado = "OFF";   //Flag de conexión
boolean statepuerto = false;
String top = "00";
String down = "00";


void setup(){
  size(1000,600);
  control5 = new ControlP5(this);
  
  control5.addTextfield("TOP").setPosition(112,470).setSize(60,60).setFont(createFont("TraditionalArabic",26));
  control5.addTextfield("DOWN").setPosition(190,470).setSize(60,60).setFont(createFont("TraditionalArabic",26));
  control5.addBang("ENVIAR").setPosition(314,470).setSize(100,60).setFont(createFont("TraditionalArabic",30));
  
  
}

void draw(){
  
  background(0);

  
  //_________________________________________________________________________
  //TITULO
  fill(255,255,255);
  textSize(30);
  textAlign(CENTER, TOP);
  text("LABORATORIO #7 COMUNICACIÓN SERIAL",500,25);
  //_________________________________________________________________________
 
  //_________________________________________________________________________
  //NOMBRE INTEGRANTES
  fill(255,255,255);
  textSize(14);
  textAlign(CENTER, TOP);
  text("Leonardo M. Benítez, Maria A. Arias, Daniel Diaz Coy.",500,85);
  stroke(231,220,12);
  strokeWeight(2);
  //_________________________________________________________________________
  
  
  //_________________________________________________________________________
  //BOTONES
  //---INICIAR COMUNICACION  
  fill(255,255,255);
  rect(62,125,250,100,25);
  fill(0,0,0);
  text("INICIAR COMUNICACIÓN",185,170);
  
  
  //---PARAR COMUNICACION    
  fill(255,255,255);
  rect(686,125,250,100,25);
  fill(0,0,0);
  text("PARAR COMUNICACIÓN",811,170);
  
  //---ESTADO COMUNICACION 
  fill(255,255,255);
  textAlign(CENTER, TOP);
  text("Estado Conexión",500,160);
  textSize(20);
  text(conectado,500,190);
  textSize(14);
  
  
  //---LEDROJO
  fill(255,0,0);
  rect(157,300,90,90,3);
  fill(0,0,0);
  text("LED ROJO",202,340);
  
  
  //---LEDVERDE
  fill(0,255,0);
  rect(455,300,90,90,3);
  fill(0,0,0);
  text("LED VERDE",500,340);
  
  
  //---LEDAZUL
  fill(0,0,255);
  rect(766,300,90,90,3);
  fill(0,0,0);
  text("LED AZUL",811,340);

  
  //---CLOCK
  fill(255,255,255);
  textSize(130);
  text(top,580,420);
  text(":",680,420);
  text(down,780,420);


  
  //_________________________________________________________________________
  
}

void mousePressed(){   
  
  //_________________________________________________________________________
  //ACCIONES
  
  //---INICIAR COMUNICACION
  if((mouseX>62 & mouseX<312)&(mouseY>125 & mouseY<225) & !statepuerto){
  fill(255,0,0);
  rect(62,125,250,100,25);  
  puerto = new Serial(this, "COM5", 19200); //Modificar El puerto segun el pc en que se use
  statepuerto = !statepuerto;
  delay(1000);
  println("Iniciar COM, conectado");
  conectado = "ON";
  }
  
  
  //---PARAR COMUNICACION 
  if((mouseX>686 & mouseX<936)&(mouseY>125 & mouseY<225) & statepuerto){
  fill(250,0,0);
  rect(686,125,250,100,25);
  puerto.stop();
  statepuerto = !statepuerto;
  println("Puerto COM, desconectado");
  conectado = "OFF";
  }
  
  
  //---LEDROJO
  if((mouseX>157 & mouseX<247)&(mouseY>300 & mouseY<390) & (conectado == "ON")){
  fill(255,0,0,255);
  rect(157,300,90,90,3);
  puerto.clear();
  puerto.write('1');
  }
  
  
  //---LEDVERDE
  if((mouseX>455 & mouseX<545)&(mouseY>300 & mouseY<390) & (conectado == "ON")){
  fill(0,255,0,255);
  rect(455,300,90,90,3);
  puerto.clear();
  puerto.write('3');
  }
  
  
  //---LEDAZUL
  if((mouseX>766 & mouseX<856)&(mouseY>300 & mouseY<390) & (conectado == "ON")){
  fill(0,0,255,10);
  rect(766,300,90,90,3);
  puerto.clear();
  puerto.write('2');
  }
  
  

  
  //---ENVIAR
  

  
  //_________________________________________________________________________
}

void ENVIAR(){
  top = control5.get(Textfield.class,"TOP").getText();
  down = control5.get(Textfield.class,"DOWN").getText();
  

  byte[] byteTop = top.getBytes();
  byte[] byteDown = down.getBytes();
  byte[] cronometro = concat(byteTop, byteDown);
  
  println(cronometro);
  for(int i = 0; i < 4; i++){
    puerto.clear();
    puerto.write(cronometro[i]);
    delay(1);
    puerto.clear();
  }
  
  
  fill(255,255,255);
  textSize(130);
  text(top,580,420);
  text(":",680,420);
  text(down,780,420);
    
}
