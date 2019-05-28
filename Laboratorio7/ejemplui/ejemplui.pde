import controlP5.*;
import processing.serial.*;

Serial myPort;    //CREACION DEL OBJETO HANDLER DEL PUERTO SERIAL
ControlP5 cp5;    //objeto de libreria botones

Bang botonIniciar, btnLed, botonParar;
PFont font;
String estado="desconectado";
boolean ledstate=false;

void setup(){
  font = createFont("Liberation Sans Narrow Bold", 20);
  size(350, 150);
  cp5 = new ControlP5(this);
  botonIniciar = cp5.addBang("Iniciar").setPosition(20,50).setSize(60, 40)
                    .setFont(createFont("Liberation Sans Narrow Bold", 16))
                    .setCaptionLabel("Iniciar \n COM");
  botonParar = cp5.addBang("Parar").setPosition(90, 50).setSize(60, 40)
                  .setFont(createFont("Liberation Sans Narrow Bold", 16))
                  .setCaptionLabel("Parar \n COM");
  btnLed = cp5.addBang("LED").setPosition(300, 50).setSize(40, 40)
          .setFont(createFont("Liberation Sans Narrow Bold", 12))
          .setColorActive(#AF0003)
          .setColorForeground(#AF0003)
          .setCaptionLabel("LED OFF");
}

void draw () {            //draw() es como la función mainLoop del MCU, se ejecuta constantemente
  background(0);
  textSize(24);
  textAlign(CENTER);
  textFont(font);
  text ("COM "+estado , 250, 150);
}

void Iniciar(){                              //handler del boton Iniciar
  println("Iniciar COM, en proceso");
  myPort = new Serial(this, "COM6", 9600);
  println("Iniciar COM, conectado");
  estado="conectado";
}
void Parar(){                                //handler del boton Parar
  println("Parar COM");
  myPort.stop();
  estado="desconectado";
}

void LED(){                                  //handler del boton LED
  if(estado=="conectado"){
  myPort.write(101);          //enviar el bye 101 al puerto serial
  }
  if(!ledstate){
    ledstate = true;
    println("LED encendido");
    btnLed.setColorForeground(#ff0000).setCaptionLabel("Led ON").setColorActive(#ff0000);
  }else{
    ledstate = false;
    println("LED apagado");
    btnLed.setColorForeground(#AF0003).setCaptionLabel("Led OFF").setColorActive(#AF0003);
  } 
}

void serialEvent (Serial port){    //equivalente a una interrupcion para recibir datos del puerto serial
  println("recibido");
}
