//;****************************************************************************
//;*UNIVERSIDAD NACIONAL DE COLOMBIA - FACULTAD DE INGENIERÍA - SEDE BOGOTÁ   *
//;****************************************************************************
//;*Departamento de Ingeniería Mecánica y Mecatrónoca  -  Microcontroladores  *
//;*Primer Semestre 2019                                                      *
//;****************************************************************************
//;*Fecha: 28/05/2019                                                         *
//;*                                                                          *
//;*Autores: Alejandra Arias Torres                                           *
//;*         Leonardo Fabio Mercado                                           *
//;*         Daniel Diaz Coy                                                  *
//;*         Marco Andres Lopez                                               *
//;*                                                                          *
//;*Descripción:  IHM para el laboratorio #7                                  *
//;*                                                                          *
//;*Documentación:  Informe laboratorio #7                                    *
//;*                                                                          *
//;*Archivos Adicionales:                                                     *
//**Repositorio:https://github.com/LeonardoMercado/MicroControladores/tree/   *
//master/Laboratorio7                                                         *
//;*                                                                          *
//;*Versión 1.0 Se implementa el mockup diseñado                              *
//;*Versión 1.1 Se ajusta para las acciones y datos                           *
//;****************************************************************************



import processing.serial.*; //Importamos la libreria Serial y sus métodos
import controlP5.*;         //Importamos la libreria ControlP5 y sus métodos de inputText

 
Serial puerto;              //Objeto de tipo Serial.
ControlP5 control5;         //Objeto de tipo ControlP5
String conectado = "OFF";   //Flag de conexión
boolean statepuerto = false; //Estado del puerto COM a conectar
String top = "00";          //Inicializador del cronometro a mostrar
String down = "00";          //Inicializador del cronometro a mostrar
int[] entrada = new int[2];  //Arreglo de los valores de entrada introducidos a la interfaz para
                             // fijar el cronometro cuando se le de STOP en el mic
int contador = 0;            //Contador de cantidad de valores introducidos al tiempo a la interfaz



void setup(){
  size(1000,600);              
  control5 = new ControlP5(this);    //Instanciación del objeto control
  
  control5.addTextfield("TOP").setPosition(112,470).setSize(60,60).setFont(createFont("TraditionalArabic",26));  //Cuadro de texto Top para introducir datos
  control5.addTextfield("DOWN").setPosition(190,470).setSize(60,60).setFont(createFont("TraditionalArabic",26)); //Cuadro de texto Down para introducir datos
  control5.addBang("ENVIAR").setPosition(314,470).setSize(100,60).setFont(createFont("TraditionalArabic",30));   //Boton de Enviar la información almacenada en TOP y DOWN
  
  
}

void draw(){
  
  background(0); //Fondo negro cada ciclo

  
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
  text("Leonardo M. Benítez, Maria A. Arias, Daniel Diaz Coy, Marco Andres Lopez.",500,85);
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

  //_________________________________________________________________________
  //VISUALIZACIONES VARIABLES EN TIEMPO 
  //---CLOCK
  fill(255,255,255);
  textSize(130);
  text(top,580,420);
  text(":",680,420);
  text(down,780,420); 
  //_________________________________________________________________________
  
}
  
void mousePressed(){   //FUNCION QUE DOMINA LAS ACCIONES DE LOS BOTONES
  
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
  top = "00";
  down = "00";
  }
  
  
  //---LEDROJO
  if((mouseX>157 & mouseX<247)&(mouseY>300 & mouseY<390) & (conectado == "ON")){
  fill(255,0,0,255);
  rect(157,300,90,90,3);
  puerto.clear();
  puerto.write('1');          //Se envia el 1 en ASCII para alternar estado del led ROJO
  }
  
  
  //---LEDVERDE
  if((mouseX>455 & mouseX<545)&(mouseY>300 & mouseY<390) & (conectado == "ON")){
  fill(0,255,0,255);
  rect(455,300,90,90,3);
  puerto.clear();
  puerto.write('3');          //Se envia el 3 en ASCII para alternar estado del led Verde
  }
  
  
  //---LEDAZUL
  if((mouseX>766 & mouseX<856)&(mouseY>300 & mouseY<390) & (conectado == "ON")){
  fill(0,0,255,10);
  rect(766,300,90,90,3);
  puerto.clear();
  puerto.write('2');          //Se envia el 2 en ASCII para alternar estado del led AZUL
  }
  //_________________________________________________________________________
  
}
void ENVIAR(){ //FUNCION QUE DOMINA EL ENVIO DE DATOS PARA EL CRONOMETRO
  top = control5.get(Textfield.class,"TOP").getText(); //captura del valor en TOP en formato String
  down = control5.get(Textfield.class,"DOWN").getText(); //Captura del valor en Down con formato String
  byte[] byteTop = top.getBytes();                       //Castin a byte del valor en TOP
  byte[] byteDown = down.getBytes();                     //Castin a byte del valor en DOWN
  byte[] cronometro = concat(byteTop, byteDown);         //Concatenación del valor deseado para el Cronometro

  for(int i = 0; i < 4; i++){ 
    puerto.write(cronometro[i]);                        //Envio de cada valor almacenado en cronometro
  }  
  fill(255,255,255);                                    //Actualización del valor del cronometro dentro de la interfaz
  textSize(130);
  text(top,580,420);
  text(":",680,420);
  text(down,780,420);
  contador = 0;                                          //Control de cantidad de datos que ingresan para actualizar el valor del cronometro en la interfaz
}

//_________________________________________________________________________
//RECEPCIÓN DE DATOS PARA CRONOMETRO.
void serialEvent(Serial puerto) { 
  if(puerto.available()>0 & contador<2){
   entrada[contador]  = puerto.read();
   contador++;
   println(entrada);
  }
  top = Integer.toString(entrada[0]);
  down = Integer.toString(entrada[1]);
} 

//_________________________________________________________________________
