
/*
;****************************************************************************
;*UNIVERSIDAD NACIONAL DE COLOMBIA - FACULTAD DE INGENIERÍA - SEDE BOGOTÁ   *
;****************************************************************************
;*Departamento de Ingeniería Mecánica y Mecatrónoca  -  Microcontroladores  *
;*Primer Semestre 2019                                                      *
;****************************************************************************
;*Fecha: 22/05/2019                                                         *
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
#define	dato	PTAD

//variables en RAM
unsigned int contRet;            //Retardo anodos    
unsigned char dig1,dig2,dig3,dig4;
unsigned char contar;            // bandera para permitir conteo
volatile unsigned int tiempo;    // variable para conteo de tiempo

//variables en ROM
const unsigned int limTmp=6000;     //Conteo hasta 60s
const unsigned short tRet=10;		//tiempo de retardo anodos


//Prototipos de funciones
void digitos (unsigned int ); //Función para actualizar el valor de los dígitos a mostrar en el display
void display(void);			  //Función para alternar los ánodos en el display
void retardo(unsigned short); //retardo para definir la frecuencia para el cambio de los ánodos

void irq_init() {
	IRQSC_IRQEDG = 0;				// activa con flanco de bajada
	IRQSC_IRQPE = 1;				// habilita el pin como entrada IRQ
	IRQSC_IRQIE = 1;				// se habilita la interrupcion por IRQ
	IRQSC_IRQMOD = 0;				// se selecciona solo flanco
}

void kbi_init() {
	KBI2PE_KBIPE0=1;                // habilitar pin para interrupción kbi
	KBI2PE_KBIPE1=1;
	//PTDPE_PTDPE0 = 1;				// habilitar resistencias pull-up o pull-down
	//PTDPE_PTDPE0 = 1;
	KBI2ES_KBEDG0=0;                // resistencia pull-up y flanco de bajada
	KBI2ES_KBEDG1=0;
	KBI2SC_KBIMOD=0;                // detección unicamente de flancos
	KBI2SC_KBIE=1;                  // habilitar interrupción
	KBI2SC_KBACK=1;                 // evitar falsas interrupciones la iniciar
}

void rti_init(){
	RTCSC=0b00011011;              //RTCLKS = 00 clock de 1khz  (LPO) Bit 5 y 6 RTCSC
	                               //RTIE=1 = activar interrupción por RTI
	                               //RTCPS  = preescaler a 10ms	
	RTCMOD=0;                      //Valor de desborde del contador
}

interrupt VectorNumber_Virq void irq_isr() { //reset
	IRQSC_IRQACK = 1;				//acknowledge para la interrupcion
	tiempo=0;
	contar=0;
}

interrupt VectorNumber_Vkeyboard void kbi_isr(){
	KBI2SC_KBACK = 1;               //acknowledge 
	if (PTDPE_PTDPE0 ==0 ){ // stop
	    contar=0;
	}else if(PTDPE_PTDPE1==0){ //play
		contar=1;
	}
}

interrupt VectorNumber_Vrtc void rtc_isr(){
	RTCSC_RTIF=1;                 //acknowledge interrupt request
    if(contar==1){
    	tiempo++;
    	if(tiempo>limTmp){
    		tiempo=0;
        }
    }    
}

void main(void) {
    tiempo=0;
		
  /* include your code here */
  for(;;) {
	digitos(tiempo);            //separar datos de tiempo en unidades decenas decimas y centesimas de s
    display();                  //siempre mostrar display
  } /* loop forever */  
}

void digitos (unsigned int var){ /*VERIFICAR ORDEN EN DISPLAY*/
	dig1=var%10;                //centesimas de s
	dig2=var/10%10;             //decimas de s
	dig3=var/100%10;            //unidades
	dig4=var/1000;              //decenas
};

void display() {
	dato = dig1;				//cargar numero del digito 1 en PTA
	anodo1 = 1;					//encender el digito 1 con el anodo 1
	retardo(tRet);				//llamar funcion retardo pasandole valor time para uso en ciclo for
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

void retardo(unsigned short max) {
	for (contRet = 0; contRet < max; ++contRet) {//funcion recibe un parametro "max" utilizado para el ciclo for
		asm nop;  
	}
}

