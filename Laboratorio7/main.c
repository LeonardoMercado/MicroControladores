// LABORATORIO 7
//
/*
;****************************************************************************
;*UNIVERSIDAD NACIONAL DE COLOMBIA - FACULTAD DE INGENIERÍA - SEDE BOGOTÁ   *
;****************************************************************************
;*Departamento de Ingeniería Mecánica y Mecatrónica  -  Microcontroladores  *
;*Primer Semestre 2019                                                      *
;****************************************************************************
;*Fecha: 28/05/2019                                                         *
;*                                                                          *
;*Autores: Alejandra Arias Torres                                           *
;*         Leonardo Fabio Mercado                                           *
;*         Daniel Diaz Coy                                                  *
;*         Marco Andres Lopez                                               *                                         
;*                                                                          *
;*Descripción: Comunicación Serial con interfaz gráfica                     *
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

#define anodo1	PTBD_PTBD0			// Por convención y por orden, se toman los 4 pines del puerto B
#define anodo2	PTBD_PTBD1			// ubicados en el extremo de la tarjeta (21,22,23,24) para facilitar
#define anodo3	PTBD_PTBD2			// el ensamble en la protoboard, desde esta definicion se pueden ubicar
#define anodo4	PTBD_PTBD3			// en otro puerto distinto

#define	LedR	PTCD_PTCD0	 		// Parametros del Led RGB (PTC0-PTC2) (15,19,20)
#define	LedG	PTCD_PTCD1		 
#define	LedB	PTCD_PTCD2	

#define	datoDisplay		PTAD		// dato para enviar al display (PTA0-PTA3) (32-35)
#define	bufferSCI		SCI2D		// Buffer de datos del SCI

//variables en RAM

unsigned char centima, decima, segundo, dsegundo;	//Variables usadas para el numero visto en el display
unsigned char cronometro;							//Determina si el cronometro es ascendente (1) o descendente (0)
unsigned char bandera;								//Permite detener el cronometro con ambos botones 
unsigned int display;
unsigned char displayTop = 0;                                //Contador general para el reloj, Valor siempre presente en el display
unsigned char displayDown = 0;                                //Contador general para el reloj, Valor siempre presente en el display

unsigned char flag_rx;                              //Variable bandera de la interrupcion SCI_RX
volatile unsigned int tiempo;
volatile unsigned char contDato = 2;

//Constantes en ROM 

unsigned const time=10;				//Constante en ROM que determina el numero de ciclos del retardo

//Prototipos de funciones

void setDisplay(unsigned int);						//prototipos de las funciones para que el compilador
void retardo(unsigned short);			//entienda el nombre y los parametros que reciben/retornan 


void SCI_send(char);
void setPrograma()					// Inicializacion del Programa
{
	SOPT1 = 0x02;					//deshabilitar el watchdog
	PTADD = 0x0f;					//configuracion de pines para manejo del display 7 segmentos
	PTBDD_PTBDD0 = 1;				//pin para anodo 1/digito1
	PTBDD_PTBDD1 = 1;				//pin para anodo 2/digito2
	PTBDD_PTBDD2 = 1;				//pin para anodo 3/digito3
	PTBDD_PTBDD3 = 1;				//pin para anodo 4/digito4
	
	PTCDD_PTCDD0 = 1;				//define salida para pin 20, PTC0
	PTCDD_PTCDD1 = 1;				//define salida para pin 19, PTC1
	PTCDD_PTCDD2 = 1;				//define salida para pin 15, PTC2

	dsegundo = 2;					// Inicializa con un valor predefinido, en este caso se coloco
	segundo = 0;					// el año actual (2019) para ser visualizado
	decima = 1;						// como prueba de que el boton reset esta funcionando correctamente
	centima = 9;					//
	
	cronometro=1;
	bandera=0;
	display=2019;

	EnableInterrupts;				//Macro para habilitar interrupciones
}

//funcion inicializacion del modulo IRQ
void setIRQ()
{
	IRQSC_IRQEDG = 0;				// activa con flanco de bajada
	IRQSC_IRQPE = 1;				// habilita el pin como entrada IRQ
	IRQSC_IRQIE = 1;				// se habilita la interrupcion por IRQ
	IRQSC_IRQMOD = 0;				// se selecciona solo con flanco
}

//funcion que atendera la interrupcion por IRQ
interrupt VectorNumber_Virq void IRQ_ISR() 	//referencia de la interrupcion
{  
	IRQSC_IRQACK = 1;			// acknowledge para la interrupcion
	RTCSC_RTCPS = 0;			// Detiene el modulo RTC
	cronometro=1;				// Establece el cronometro en Ascendente
	bandera=1;					// Permite detener el cronometro
	LedB=!LedB;					// Enciende/Apaga el led azul
	display = 0;				// Resetea los digitos del display
}

//inicializa el modulo KBI
void setKBI()
{
	PTDPE_PTDPE7 = 1;			// Habilita la resistencia Pull en PTD0, boton "start"
	PTDPE_PTDPE6 = 1;			// Habilita la resistencia Pull en PTD1, boton "stop"   
	
	KBI2SC_KBIE = 1;			// Habilita las interrupciones en KBI2
	KBI2SC_KBIMOD = 0;			// Habilita la operacion solo por flancos
	KBI2SC_KBACK = 0;			// Limpia la bandera de Ejecucion de KBI2 
	
	KBI2PE_KBIPE7 = 1;			// Habilita el Pin 0 de KBI2 (pin 16)
	KBI2PE_KBIPE6 = 1;			// Habilita el pin 1 de KBI2 (pin 17)
	KBI2ES_KBEDG7 = 0;			// Habilita interrupción por flanco de bajada en la entrada KBI2P0
	KBI2ES_KBEDG6 = 0;			// Habilita interrupción por flanco de bajada en ls entrada KBI2P1
}

// Funcion que atendera la interrupcion por KBI
interrupt VectorNumber_Vkeyboard void KBI_ISR()
{
	KBI2SC_KBACK = 1;			// Limpia la bandera de Interrupción
	
	
	
	if(PTDD_PTDD6==0)			// Si detecta un flanco negativo en el boton "Descendente"
	{
		if(bandera&display>0)
		{
			cronometro=0;			// Establece el cronometro en Descendente
			RTCSC_RTCPS = 11;		// Desactiva el modulo RTC haciendo el Preescalado = 0
			LedR=1;
		}
		else
		{
			LedR=0;
		    RTCSC_RTCPS = 0;		// Detiene el cronometro
		    displayTop=display/100;
		    SCI_send(displayTop);
		    retardo(10);
		    displayDown=display%100;
		    SCI_send(displayDown); 
		    
		}
		bandera=!bandera;
	}
	if(PTDD_PTDD7==0)			// Si detecta un flanco negativo en el boton "Ascendente"
	{
		if(bandera&display<9999)
		{
			cronometro=1;			// Establece el cronometro en Ascendente
			RTCSC_RTCPS = 11;		// Desactiva el modulo RTC haciendo el Preescalado = 0
			LedG=1;
		}
		else
		{
			RTCSC_RTCPS = 0;		// Detiene el cronometro
			LedG=0;
			displayTop=display/100;
			SCI_send(displayTop);
			retardo(10);
			displayDown=display%100;
			SCI_send(displayDown); 
		}
		bandera=!bandera;
	}
	
	//display=displayTop*100+displayDown;
	
	//displayTop=display/100;
	//displayDown=display%100;
	
	//SCI_send(144);              // IMPORTANTE : Dato de Envio
}

//inicializa el modulo RTC
void setRTC()
{
	RTCSC_RTIF = 0;				// Coloca la bandera de interrupcion RTC en 0
	RTCSC_RTCLKS = 0;			// Selecciona el origen de la señal de reloj, 1Khz LPO
	RTCSC_RTIE = 1;				// Habilita la interrupcion por RTC
	RTCSC_RTCPS = 0;			// PreEscalado del reloj, en 0 para no iniciar cuenta al habilitar
}
// Funcion que atendera la interupcion por RTC
interrupt VectorNumber_Vrtc void RTC_ISR()
{
	RTCSC_RTIF = 0;				// Limpia la bandera de la interrupcion
	RTCSC_RTCPS = 11;			// Vuelve a llamar la interrupcion al variar el preescale en 10ms
	
	if(cronometro)
	{
		display++;
	}
	else
	{
		display--;
	}
		
	if(display==0|display==9999)				
	{
		RTCSC_RTCPS = 0;		// Detiene el cronometro al llegar a los limites del displau
	}
}

// MODULO SCI

void setSCI()
{
    SCI2BDH = 0;
    SCI2BDL = 15;
    SCI2C1 = 0x00;
    SCI2C2_TE = 1;
    SCI2C2_RE = 1;
    SCI2C2_RIE = 1;
}

interrupt VectorNumber_Vsci2rx void sci_rx()
{   
    flag_rx=SCI2S1_RDRF;    
    
    if(SCI2D < 100)
    {
        LedB=!LedB;
        if(contDato==2)
        {
            displayTop = SCI2D;
            contDato=5;
        }
        else if(contDato==5)
        {
            displayDown = SCI2D;
            //contDato=!contDato;
            contDato=2;
        }
        display=displayTop*100+displayDown;
        //contDato=!contDato;
    }
    else if(SCI2D == 100)
    {
        PTCD_PTCD0 = !PTCD_PTCD0;
    }
    else if(SCI2D == 101)
    {
        PTCD_PTCD1 = !PTCD_PTCD1;
    }
    else if(SCI2D == 102)
    {
        PTCD_PTCD2 = !PTCD_PTCD2;
    }
    
}

void SCI_send(char dato)
{
    while(SCI2S1_TDRE == 0);
    SCI2D = dato;
    return;
}



void main(void) 
{
	setPrograma();					// Inicializa las variables y parametros del programa
	setIRQ();						// Inicializa IRQ
	setKBI();						// Inicializa KBI
	setRTC();						// Inicializa RTC
	setSCI();                       // Inicializa SCI
	
	for (;;) 
	{
		setDisplay(display);					//llamar a display constantemente
	} /* loop forever */
	/* please make sure that you never leave main */
}

//******************* Subrutinas de Ejecucion ******************

//metodo para el display 7 segmentos
void setDisplay(unsigned int var) 					// Reciclado del Ejemplo
{
	centima=var%10;                //centesimas de s
	decima=var/10%10;             //decimas de s
	segundo=var/100%10;            //unidades
	dsegundo=var/1000;              //decenas
	
	datoDisplay = dsegundo;			//cargar numero del digito 1 en PTA
	anodo1 = 1;					//encender el digito 1 con el anodo 1
	retardo(time);				//llamar funcion retardo pasandole valor time para uso en ciclo for
	anodo1 = 0;					//apagar el digito 1 para pasar al siguiente
	datoDisplay = segundo;
	anodo2 = 1;
	retardo(time);
	anodo2 = 0;
	datoDisplay = decima;
	anodo3 = 1;
	retardo(time);
	anodo3 = 0;
	datoDisplay = centima;
	anodo4 = 1;
	retardo(time);
	anodo4 = 0;
}

//funcion de retardo por software o polling
void retardo(unsigned short max)
{
	unsigned volatile int ciclo;
	for (ciclo = 0; ciclo < max; ciclo++) 
	{
		//funcion recibe un parametro "max" utilizado para el ciclo for
	}
}

