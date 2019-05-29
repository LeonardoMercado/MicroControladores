/*
;****************************************************************************
;*UNIVERSIDAD NACIONAL DE COLOMBIA - FACULTAD DE INGENIERÍA - SEDE BOGOTÁ   *
;****************************************************************************
;*Departamento de Ingeniería Mecánica y Mecatrónoca  -  Microcontroladores  *
;*Primer Semestre 2019                                                      *
;****************************************************************************
;*Fecha: 28/05/2019                                                         *
;*                                                                          *
;*Autores: Alejandra Arias Torres                                           *
;*         Leonardo Fabio Mercado                                           *
;*                                                                          *
;*Descripción: Cronómetro con nterrupciones RTC, KBI, IRQ                   *
;*                                                                          *
;*Documentación:Hoja de datos QE16                                          *
;*                                                                          *
;*Archivos Adicionales:                                                     *
;*                                                                          *
;*Versión 1.0 realizada en CodeWarrior (Eclipse) V11                        *
;****************************************************************************
*/


#include <hidef.h> /* for EnableInterrupts macro */
#include "derivative.h" /* include peripheral declarations */

//Identificación de puertos
#define	anodo1	PTBD_PTBD2		
#define	anodo2	PTBD_PTBD3		 
#define	anodo3	PTCD_PTCD0		
#define	anodo4  PTCD_PTCD1
#define	dato	PTAD             // dato para enviar al display

//variables en RAM
unsigned int contRet;            //Contador para retardo en los anodos    
unsigned char dig1,dig2,dig3,dig4;
volatile unsigned int tiempo;    // variable para conteo de tiempo
unsigned char temp;

//variables en ROM
const unsigned int limTmp=6000;     //Conteo hasta 60s
const unsigned short tRet=10;		//tiempo de retardo anodos


//Prototipos de funciones
void digitos (unsigned int ); //Función para actualizar el valor de los dígitos a mostrar en el display
void display(void);			  //Función para alternar los ánodos en el display
void retardo(unsigned short); //Retardo para definir la frecuencia para el cambio de los ánodos

void init_icg(void);		  //Activación del BusClk para el ISC2	
void init_sci(void);		  //Configuracion del ICS2	
void send_sci(char dato_sci); //Función enviar Dato del ICS2
char receive_sci(void);       //Función Recibir Dato del ICS2

void irq_init() {
	IRQSC_IRQEDG = 0;				// activa con flanco de bajada
	IRQSC_IRQPE = 1;				// habilita el pin como entrada IRQ
	IRQSC_IRQIE = 1;				// se habilita la interrupcion por IRQ
	IRQSC_IRQMOD = 0;				// se selecciona solo flanco
}

void kbi_init() {
	KBI2PE_KBIPE0=1;                // habilitar pin para interrupción kbi
	KBI2PE_KBIPE1=1;
	PTDPE_PTDPE0 = 1;				// habilitar resistencias pull-up o pull-down
	PTDPE_PTDPE1 = 1;
	KBI2ES_KBEDG0=0;                // resistencia pull-up y flanco de bajada
	KBI2ES_KBEDG1=0;
	KBI2SC_KBIMOD=0;                // detección unicamente de flancos
	KBI2SC_KBIE=1;                  // habilitar interrupción
	KBI2SC_KBACK=1;                 // evitar falsas interrupciones la iniciar
}

void rtc_init(){
	RTCSC=0b00010000;              //RTCLKS = 00 clock de 1khz  (LPO) Bit 5 y 6 RTCSC
	                               //RTIE=1 = activar interrupción por RTI
	                               //RTCPS  = preescaler a 10ms	
	RTCMOD=0;                      //Valor de desborde del contador
}

interrupt VectorNumber_Virq void irq_isr() { //reset
	IRQSC_IRQACK = 1;				//acknowledge para la interrupcion
	tiempo=0;
}

interrupt VectorNumber_Vkeyboard void kbi_isr(){
	KBI2SC_KBACK = 1;               //acknowledge 
	if (PTDD_PTDD0 ==0 ){           //stop
		RTCSC=0b00010000; 
	}else if(PTDD_PTDD1==0){        //play
		RTCSC=0b00011011; 
		if(tiempo==limTmp){   // reiniciar conteo si se llegó al límite
			tiempo=0;
		}
	}
}

interrupt VectorNumber_Vrtc void rtc_isr(){	               
	RTCSC_RTIF=1;           //acknowledge interrupt request
	if (tiempo<limTmp){    //sumar solo si tiempo no ha llegado al límite
		tiempo++;
	}
}

void main(void) {
	SOPT1 = 0x02;					//deshabilitar el watchdog
    tiempo=0;                       //iniciar contador de tiempo   
	SOPT1 = 0x02;					//deshabilitar el watchdog
	PTADD = 0x0f;					//configuracion de pines para manejo del display 7 segmentos
	PTBDD_PTBDD2 = 1;				//configurar pines como salida
	PTBDD_PTBDD3 = 1;				
	PTCDD_PTCDD0 = 1;				
	PTCDD_PTCDD1 = 1;				
	irq_init();						//inicializar interrupciones
	kbi_init();	
	rtc_init();
	  
    init_icg();
	init_sci();
	
	EnableInterrupts;				 //Habilitar interrupciones CLI en assembler (Clear Interrupt Mask Bit)
	
  /* include your code here */
  for(;;) {
	digitos(tiempo);            //separar datos de tiempo en unidades decenas decimas y centesimas de s
    display();                  //siempre mostrar display
  } /* loop forever */  
}

void init_icg(){

	SCGC1 = 0xFF;               //BUSCLK ENABLE para ICS2
}


void init_sci(){
	
	//	Frequency de bus 4 MHz !!!!VERIFICAR O AJUSTAR!!!
	//	Baudrate 19200
	SCI2BDH = 0x00;
	SCI2BDL = 0x0D;	    		//13 para llegar a los 19200
	SCI2C2_TE = 1;				//Habilita el TX en ICS2		
	SCI2C2_RE = 1;				//Habilita el RX en ICS2
}

void send_sci(char dato_sci){
	while(SCI2S1_TDRE);			//!!!!VERIFICAR!!!!!   (!SCI2S1_TDRE)
	temp = SCI2S1;	
	SCI2D = dato_sci;
}

char receive_sci(void){
	while (!SCI2S1_RDRF); 
	return SCI2D;
}





//Función para actualizar el valor de los dígitos a mostrar en el display
void digitos (unsigned int var){ /*VERIFICAR ORDEN EN DISPLAY*/
	dig4=var%10;                //centesimas de s
	dig3=var/10%10;             //decimas de s
	dig2=var/100%10;            //unidades
	dig1=var/1000;              //decenas
};

//Función para alternar los ánodos en el display
void display() {
	dato = dig1;				//cargar numero del digito 1 en PTA
	anodo1 = 1;					//encender el digito 1 con el anodo 1
	retardo(tRet);				//llamar funcion retardo 
	anodo1 = 0;					//apagar el digito 1 para pasar al siguiente
	dato = dig2;
	anodo2 = 1;
	retardo(tRet);
	anodo2 = 0;
	dato = dig3;
	anodo3 = 1;
	retardo(tRet);
	anodo3 = 0;
	dato = dig4;
	anodo4 = 1;
	retardo(tRet);
	anodo4 = 0;
}

//Retardo para definir la frecuencia para el cambio de los ánodos
void retardo(unsigned short max) {
	for (contRet = 0; contRet < max; ++contRet) {
		asm nop;  
		 
	}
}
