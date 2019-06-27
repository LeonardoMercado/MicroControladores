#include <hidef.h> /* for EnableInterrupts macro */
#include "derivative.h" /* include peripheral declarations */

//#define duty  TPM3C0V;
//#define	timer	PTBD_PTBD0;
#define	buffSCI  SCI2D		        // Buffer de datos del SCI

unsigned const time=1000; 
volatile unsigned int timerTpmA;
unsigned char timerTpmAH;
unsigned char timerTpmAL;
unsigned char flag_rx;              //Variable bandera de la interrupcion SCI_RX
volatile char enviarLectura;        //Funciona como booleano
volatile unsigned char i;

void retardo(unsigned short); 
void SCI_send(char);


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
    	//canal=0;
    	i=0;
    	SCI_send ('S');
    	retardo(time);
    }else{
    	enviarLectura=0;
    	//canal=0;
    	i=0;
    }
}

void set_tpm_PWM(){
	TPM3SC_CLKSx  = 0b01;    //Source Buss Clock  4M
	TPM3SC_PS = 0b011;       //Preescaler en 8 500k 
	TPM3SC_CPWMS = 0;        //PWM alineado en flanco
	TPM3C0SC_MS0x  = 0b10;   //
	TPM3MOD = 500;           //Divisor de frecuencia en 500 freq=1k
	TPM3C0SC_ELS0x  = 0b10;  //
	TPM3C0V = 200;		     //Ciclo útil 50%
}

void set_tmp_input(){        
	TPM1SC_CLKSx  = 0b01;    //Source Buss Clock  4M
	TPM1SC_PS = 0b000;       //31250
	TPM1SC_CPWMS = 0;        //PWM alineado en flanco
	TPM1C0SC_MS0x = 0b00;
	//TPM1MOD = 60000;  
	TPM1C0SC_ELS0x = 0b01;  //Captura en flanco de subida unicamente
	TPM1C0SC_CH0IE = 1;     //Activar Interrupción
}

interrupt VectorNumber_Vtpm1ch0 void tpm1_ch0_isr(){
	timerTpmA = TPM1C0V;
	PTBD_PTBD0=!PTBD_PTBD0;
	TPM1CNT=0;	
	//TPM1C0V=0;
	TPM1C0SC_CH0F = 0;           //acknowledge interrupt
}


void setPrograma()                  // Inicializacion del Programa
{
	setSCI(); 
	set_tpm_PWM();
    SOPT1 = 0x02;                   // deshabilitar el watchdog  
    PTBDD_PTBDD0 = 1;
    //ICSTRM = 0xBC;                // Trim CLk a 231 (busclk = 4k)    
    EnableInterrupts;               //Macro para habilitar interrupciones
}

void main(void) {  
  setPrograma();  
  set_tmp_input();  

  /* include your code here */
  

  for(;;) {		  

	  timerTpmAL=timerTpmA%256;
	  timerTpmAH=timerTpmA/256;

	  i=0;
	      	if(enviarLectura){		      		
	      		SCI_send(timerTpmAH);
	      		retardo(time);
	      		SCI_send(timerTpmAL);
	      		retardo(time);      		

	      	}   
  } /* loop forever */
  /* please make sure that you never leave main */
}


void retardo(unsigned short max)
{
    unsigned volatile int ciclo;
    for (ciclo = 0; ciclo < max; ciclo++) 
    {    	
    	 //funcion recibe un parametro "max" utilizado para el ciclo for
    }
}

void SCI_send(char dato)
{
    while(SCI2S1_TDRE == 0);
    buffSCI = dato;
    return;
}
