//                              LABORATORIO 8                              //
//                                                                         //
/*                                                                         //
;****************************************************************************
;*UNIVERSIDAD NACIONAL DE COLOMBIA - FACULTAD DE INGENIER�A - SEDE BOGOT�   *
;****************************************************************************
;*Departamento de Ingenier�a Mec�nica y Mecatr�nica  -  Microcontroladores  *
;*Primer Semestre 2019                                                      *
;****************************************************************************
;*Fecha: 11/06/2019                                                         *
;*                                                                          *
;*Autores: Alejandra Arias Torres                                           *
;*         Leonardo Fabio Mercado                                           *                                             *                                         
;*                                                                          *
;*Descripci�n: M�dulo ADC                                                   *
;*                                                                          *
;*Documentaci�n:Hoja de datos QE16                                          *
;*                                                                          *
;*Archivos Adicionales:                                                     *
;*                                                                          *
;*Versi�n 1.0 realizada en CodeWarrior (Eclipse) V11                        *
;****************************************************************************
*/

#include <hidef.h> /* for EnableInterrupts macro */
#include "derivative.h" /* include peripheral declarations */


#define	LedR	 PTCD_PTCD0	 		// Parametros del Led RGB (PTC0-PTC2) (15,19,20)
#define	LedG	 PTCD_PTCD1		 
#define	LedB	 PTCD_PTCD2	

#define	buffSCI  SCI2D		        // Buffer de datos del SCI

//variables en RAM
unsigned char flag_rx;              //Variable bandera de la interrupcion SCI_RX
unsigned char i = 0;            //Variable para determinar que dato se va a enviar
volatile unsigned char canal = 0;   //Variable para seleccionar el canal ADC
volatile char sensorH[8];  //Arreglo para almacenar la parte alta de la conversi�n
volatile char sensorL[8];  //Arreglo para almacenar la parte baja de la conversi�n

//Constantes  

unsigned const time=10;				//Constante en ROM que determina el numero de ciclos del retardo

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
    SCI2BDH = 0;
    SCI2BDL = 15;     // 19600 Baud Rate 
    SCI2C1 = 0x00;     
    SCI2C2_TE = 1;    //Activar transmisi�n
    SCI2C2_RE = 1;    //Activar recepci�n
    SCI2C2_RIE = 1;   //Interrupci�n Rx
} 

void SCI_send(char dato)
{
    while(SCI2S1_TDRE == 0);
    SCI2D = dato;
    return;
}

// MODULO ADC
void setADC()
{
    ADCSC1_AIEN=1;        //Habilitar Interrupci�n
    ADCSC1_ADCO=0;        //Conversi�n continua desactivada
    ADCSC1_ADCO=0;        //Inicia en canal 0
    ADCSC2_ADTRG=0;       //Conversi�n activada por software
    ADCCFG_ADLPC=0;       //Alta velocidad
    ADCCFG_ADIV=0b00;     //divisor=1
    ADCCFG_ADLSMP=0;      //tiempo corto de muestreo (maximizar velocidad de conversi�n)
    ADCCFG_ADLSMP=0b01;   //N=12 bits
    ADCCFG_ADICLK=0b00;   //input clk = bus clk
}

interrupt VectorNumber_Vadc void ADC_ISR() 	//interrupci�n generada cuando se completa una conversi�n 
{      
    ADCSC1_ADCH=canal;    //Seleccionar canal 
    sensorL[canal]=ADCRL; //Almacenar parte baja del dato 
    sensorH[canal]=ADCRH; //Almacenar parte alta del dato 
	canal++;              //Cambiar de canal
	if(canal==8){         //si ya ley� los 8 canales
		canal=0;          //regrese al primer canal
	}	
}

void main(void) 
{
	setPrograma();					// Inicializa las variables y parametros del programa
	setSCI();                       // Inicializa SCI
	setADC();                       // Inicializa ADC
	
	for (;;)                      
	/* please make sure that you never leave main */
	{  //Siempre mostrar  los datos 
		while(i<8){
			SCI_send(sensorH[i]); //transmitir parte alta del dato
			retardo(time);
			SCI_send(sensorL[i]); //transmitir parte baja del dato	
			i++;
		}
		i=0;
		SCI_send(10);             //enviar cambio de l�nea
		retardo(time);
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

