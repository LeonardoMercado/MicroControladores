
/*
;****************************************************************************
;*UNIVERSIDAD NACIONAL DE COLOMBIA - FACULTAD DE INGENIER�A - SEDE BOGOT�   *
;****************************************************************************
;*Departamento de Ingenier�a Mec�nica y Mecatr�nica  -  Microcontroladores  *
;*Primer Semestre 2019                                                      *
;****************************************************************************
;*Fecha: 28/05/2019                                                         *
;*                                                                          *
;*Autores: Alejandra Arias Torres                                           *
;*         Leonardo Fabio Mercado                                           *
;*         Daniel Diaz Coy                                                  *
;*         Marco Andres Lopez                                               *                                         
;*                                                                          *
;*Descripci�n: Comunicaci�n Serial con interfaz gr�fica                     *
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

//Identificaci�n de puertos
#define	Disp1	  PTBD_PTBD0	 // �nodos display (PTB0-PTB3) (21-24)
#define	Disp2	  PTBD_PTBD1		 
#define	Disp3	  PTBD_PTBD2		
#define	Disp4     PTBD_PTBD3
#define	PtoDisp1  PTBDD_PTBDD0	 // puertos de salida
#define	PtoDisp2  PTBDD_PTBDD1		 
#define	PtoDisp3  PTBDD_PTBDD2		
#define	PtoDisp4  PTBDD_PTBDD3
#define	LedR	  PTCD_PTCD0	 // Led RGB (PTC0-PTC2) (15,19,20)
#define	LedG	  PTCD_PTCD1		 
#define	LedB	  PTCD_PTCD2	
#define	Tx	      PTCD_PTCD6     // bluetooth (PTC6-PTC7) (36,37)		 
#define	Rx	      PTCD_PTCD7
#define	datoDisp  PTAD           // dato para enviar al display (PTA0-PTA3) (32-35)
#define	buffSCI	  SCI2D          // Buffer de datos del SCI

//Constantes
const unsigned short tRet=10;    //tiempo de retardo anodos

//Variables 
volatile unsigned int tiempo;    // variable para conteo de tiempo
volatile unsigned char datoTx;   // 
volatile unsigned char datoRx;   // 
unsigned char flagRx;            //Solo lectura - bandera interrupcion de SCI_rx
unsigned char flagTx;            //Solo lectura - bandera interrupcion de SCI_tx
volatile unsigned char dig1,dig2,dig3,dig4;  //Datos para enviar al display   


//Prototipos de funciones
void digitos (unsigned int );  //Funci�n para actualizar el valor de los d�gitos a mostrar en el display
void display(void);			   //Funci�n para alternar los �nodos en el display
void retardo(unsigned short);  //Retardo para definir la frecuencia para el cambio de los �nodos
void enviarSCI(unsigned int);  //Funci�n para env�o de datos 


//Inicializaci�n de interrupciones

void irq_init() {
	IRQSC_IRQEDG = 0;				// activa con flanco de bajada
	IRQSC_IRQPE = 1;				// habilita el pin como entrada IRQ
	IRQSC_IRQIE = 1;				// se habilita la interrupcion por IRQ
	IRQSC_IRQMOD = 0;				// se selecciona solo flanco
}

void kbi_init() {
	KBI2PE_KBIPE6=1;                // habilitar pines 16 y 17 para interrupci�n kbi
	KBI2PE_KBIPE7=1;
	PTDPE_PTDPE6 =1;				// habilitar resistencias pull-up 
	PTDPE_PTDPE7 =1;
	KBI2ES_KBEDG6=0;                // resistencia pull-up y flanco de bajada
	KBI2ES_KBEDG7=0;
	KBI2SC_KBIMOD=0;                // detecci�n unicamente de flancos
	KBI2SC_KBIE  =1;                // habilitar interrupci�n
	KBI2SC_KBACK =1;                // evitar falsas interrupciones la iniciar
}

void rtc_init(){
	RTCSC=0b00010000;               //RTCLKS = 00 clock de 1khz (LPO) Bit 5 y 6 RTCSC
	                                //RTIE=1 = activar interrupci�n por RTI
	                                //RTCPS  = preescaler desactivado	
	RTCMOD=0;                       //Valor de desborde del contador
}

void SCI_init(){
	SCGC1_SCI2 = 1;                 //Activar Bus Clock para el m�dulo SCI2
	SCI2BDH = 0;                    
	SCI2BDL = 27;                   //Divisor=27 BaudRate=Busclk/(27*16)
	SCI2C1_LOOPS = 0;               //RX y Tx en pines separados
	SCI2C1_M= 0;                    //Modo de 8 bits (Start-datos-Stop) LSB primero
	SCI2C1_PE= 0;                   //No se utiliza bit de paridad 	
	SCI2C2_TE = 1;                  //Activar Transmisor
	SCI2C2_RE = 1;                  //Activar Receptor
	SCI2C2_TIE = 1;                 //Activar Interrupci�n del Transmisor (TDRE flag)
	SCI2C2_RIE = 1;                 //Activar Interrupci�n del Receptor (RDRF flag)
}

//Vectores de interrupciones

//RESET-IRQ
interrupt VectorNumber_Virq void irq_isr() { 
	IRQSC_IRQACK = 1;				//acknowledge para la interrupcion
	tiempo=0;
}

//START-STOP
interrupt VectorNumber_Vkeyboard void kbi_isr(){
	KBI2SC_KBACK = 1;               //acknowledge 
	if (PTDD_PTDD7 ==0 ){           //stop
		RTCSC=0b00010000;           //Desactivar Prescaler
		enviarSCI(tiempo);          //Enviar valor al PC
	}else if(PTDD_PTDD6==0){        //start
		RTCSC=0b00011011;           //Divisor a 10ms
	}
}

//CRON�METRO
interrupt VectorNumber_Vrtc void rtc_isr(){	               
	RTCSC_RTIF=1;           //acknowledge interrupt request
	if (tiempo>0){          //restar solo si tiempo no ha llegado al l�mite
		tiempo--;
	}
}

//RECIBIR DATOS
interrupt VectorNumber_Vsci2rx void sci_rx(){
	flagRx=SCI2S1_RDRF;     //acknowledge interrupt request   
	if(buffSCI == 1){       //encender led seg�n el dato enviado
        LedR = !LedR;			
	}else if(buffSCI == 3){
	    LedG = !LedG;  
	}else if(buffSCI == 2){
	    LedB = !LedB;
	}
}

//ENVIAR DATOS
interrupt VectorNumber_Vsci2tx void sci_tx(){
	flagTx=SCI2S1_TDRE;  //acknowledge interrupt request
	buffSCI=datoTx;
}

/**********************************************/


void main(void) {	
	SOPT1 = 0x02;					//deshabilitar el watchdog
    tiempo=0;                       //iniciar contador de tiempo   
	SOPT1 = 0x02;					//deshabilitar el watchdog
	PTADD = 0x0f;					//configuracion de pines para manejo del display 7 segmentos
	PtoDisp1 = 1;				    //configurar pines como salida
	PtoDisp2 = 1;				
	PtoDisp3 = 1;				
	PtoDisp4 = 1;				
	irq_init();						//inicializar interrupciones
	kbi_init();	
	rtc_init();
	SCI_init();
	EnableInterrupts;				 //Habilitar interrupciones CLI en assembler (Clear Interrupt Mask Bit)

  for(;;) {
		digitos(tiempo);            //separar datos de tiempo en unidades decenas decimas y centesimas de s
	    display();                  //siempre mostrar display
  } 
  
}

//Funci�n para actualizar el valor de los d�gitos a mostrar en el display
void digitos (unsigned int var){ /*VERIFICAR ORDEN EN DISPLAY*/
	dig4=var%10;                //centesimas de s
	dig3=var/10%10;             //decimas de s
	dig2=var/100%10;            //unidades
	dig1=var/1000;              //decenas
};

//Funci�n para alternar los �nodos en el display
void display() {
	datoDisp = dig1;				//cargar numero del digito 1 en PTA
	Disp1 = 1;					//mostrar digito 1 en Display1
	retardo(tRet);				//llamar funcion retardo 
	Disp1 = 0;					//apagar el digito 1 para pasar al siguiente
	datoDisp = dig2;
	Disp2 = 1;
	retardo(tRet);
	Disp2 = 0;
	datoDisp = dig3;
	Disp3 = 1;
	retardo(tRet);
	Disp3 = 0;
	datoDisp = dig4;
	Disp4 = 1;
	retardo(tRet);
	Disp4 = 0;
}

//Retardo para definir la frecuencia para el cambio de los �nodos
void retardo(unsigned short max) {
	unsigned int contRet;           //Contador para retardo en los anodos 
	for (contRet = 0; contRet < max; ++contRet) {
		asm nop; 		 
	}
}

void enviarSCI(unsigned int dato){
	datoTx=dato/100;                //parte alta
	datoTx=dato%100;                //parte baja	
}

