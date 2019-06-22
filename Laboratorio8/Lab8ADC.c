//                              LABORATORIO 8                              //
//                                                                         //
/*                                                                         //
;****************************************************************************
;*UNIVERSIDAD NACIONAL DE COLOMBIA - FACULTAD DE INGENIERÍA - SEDE BOGOTÁ   *
;****************************************************************************
;*Departamento de Ingeniería Mecánica y Mecatrónica  -  Microcontroladores  *
;*Primer Semestre 2019                                                      *
;****************************************************************************
;*Fecha: 11/06/2019                                                         *
;*                                                                          *
;*Autores: Alejandra Arias Torres                                           *
;*         Leonardo Fabio Mercado                                           *                                             *                                         
;*                                                                          *
;*Descripción: Módulo ADC                                                   *
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


#define	LedR	 PTCD_PTCD0	 		// Parametros del Led RGB (PTC0-PTC2) (15,19,20)
#define	LedG	 PTCD_PTCD1		 
#define	LedB	 PTCD_PTCD2	
#define	buffSCI  SCI2D		        // Buffer de datos del SCI
#define	CtrlADC  APCTL1		        // Buffer de datos del SCI
#define	selecADC   ADCSC1_ADCH		// Buffer de datos del SCI

//variables en RAM
unsigned char flag_rx;              //Variable bandera de la interrupcion SCI_RX
//unsigned char i;                  //Variable para determinar que dato se va a enviar
volatile unsigned char canal;       //Variable para seleccionar el canal ADC
volatile char sensorH[8];           //Arreglo para almacenar la parte alta de la conversión
volatile char sensorL[8];           //Arreglo para almacenar la parte baja de la conversión
volatile char enviarLectura;        //Funciona como booleano
volatile unsigned char i;
//Constantes  

unsigned const time=1000;				//Constante en ROM que determina el numero de ciclos del retardo

//Prototipos de funciones

void retardo(unsigned short);		//entienda el nombre y los parametros que reciben/retornan 
void SCI_send(char);

void setPrograma()					// Inicializacion del Programa
{
	SOPT1 = 0x02;					//deshabilitar el watchdog	
	PTCDD_PTCDD0 = 1;				//define salida para pin 20, PTC0 LEDR
	PTCDD_PTCDD1 = 1;				//define salida para pin 19, PTC1 LEDG
	PTCDD_PTCDD2 = 1;				//define salida para pin 15, PTC2 LEDB	
	EnableInterrupts;				//Macro para habilitar interrupciones
}

// MODULO SCI
void setSCI()
{
	SCGC1_SCI2 = 1;   //Activar Bus Clock para el módulo SCI2
    SCI2BDH = 0;      //Modulo divisor =0
    SCI2BDL = 16;     // 19600 Baud Rate
    //SCI2BDL = 15;      
    SCI2C1 = 0x00;    // Operacion normal modo 8 bits
    SCI2C2_TE = 1;    //Activar transmisión
    SCI2C2_RE = 1;    //Activar recepción
    SCI2C2_RIE = 1;   //Interrupción Rx
} 

interrupt VectorNumber_Vsci2rx void sci_rx(){   
    flag_rx=SCI2S1_RDRF;  
    if(buffSCI == 'T'){
    	enviarLectura=1;
    	canal=0;
    	i=0;
    	SCI_send ('S');
    	retardo(time);
    	//if(buffSCI == 'F')
    }else{
    	enviarLectura=0;
    	canal=0;
    	i=0;
    }
}



// MODULO ADC
void setADC()
{
	SCGC1_ADC = 1;        //Activar Bus Clock para el módulo ADC
    ADCSC1_AIEN=1;        //Habilitar Interrupción
    ADCSC1_ADCO=0;        //Conversión continua activada
    selecADC=0b11111;     //Ningún canal activo  
    ADCSC2_ADTRG=0;       //Conversión activada por software
    ADCSC2_ACFE=0;
    ADCSC2_ACFGT=0;
    ADCCFG_ADLPC=0;       //Alta velocidad
    ADCCFG_ADIV=0b00;     //divisor=1   
    ADCCFG_MODE=0b01;     //N=12 bits
    ADCCFG_ADICLK=0b00;   //input clk = bus clk
    CtrlADC=0xff;         //Inicializar bits de control          
}

interrupt VectorNumber_Vadc void ADC_ISR() 	//interrupción generada cuando se completa una conversión 
{  
    sensorH[canal]=ADCRH; //Almacenar parte baja del dato 
    sensorL[canal]=ADCRL; //Almacenar parte alta del dato         
}
void main(void) 
{   
	setPrograma();					// Inicializa las variables y parametros del programa
	setSCI();                       // Inicializa SCI
	setADC();                       // Inicializa ADC
	enviarLectura=0;
	for (;;) 	
	/* please make sure that you never leave main */
	{  //Siempre mostrar  los datos 
		selecADC=0;           // Activar Canal 0 Interrupción
		i=0;	
		if(enviarLectura){
		while(i<8){
			SCI_send(sensorH[i]); //transmitir parte alta del dato
			retardo(time);
			SCI_send(sensorL[i]); //transmitir parte baja del dato	
			retardo(time);
			i++;
			canal++;
			selecADC++;
		}	
		    canal=0;
		}
	} 	
}

//******************* Subrutinas de Ejecucion ******************


//funcion de retardo por software o polling
void retardo(unsigned short max)
{
	unsigned volatile int ciclo;
	for (ciclo = 0; ciclo < max; ciclo++) 
	{
		//funcion recibe un parametro "max" utilizado para el ciclo for
	}
}

//envio de datos por SCI

void SCI_send(char dato)
{
    while(SCI2S1_TDRE == 0);
    buffSCI = dato;
    return;
}
