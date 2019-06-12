#include <hidef.h> /* for EnableInterrupts macro */
#include "derivative.h" /* include peripheral declarations */

unsigned volatile char dato[];
unsigned short datoaux[];
volatile unsigned char canal = 0;
unsigned short varDelay;


unsigned volatile char i = 0;
unsigned int num, temp;
unsigned long factor = 1;

void SCI_send(char valor);
void sendString(char valor[]);
void delay(unsigned short);
void convCadena(unsigned short);

interrupt VectorNumber_Vadc void adc_isr() {	
	switch (canal) {			
	case 0:
		datoaux[0] = ADCRH<<8;
		datoaux[0] += ADCRL;
		canal = 1;				
		ADCSC1_ADCH = 0b00001;	
		break;					
	case 1:
		datoaux[1] = ADCRH<<8;
		datoaux[1] += ADCRL;
		canal = 2;
		ADCSC1_ADCH = 0b00010;
		break;
	case 2:
		datoaux[2] = ADCRH<<8;
		datoaux[2] += ADCRL;
		canal = 3;				
		ADCSC1_ADCH = 0b00011;	
		break;					
	case 3:
		datoaux[3] = ADCRH<<8;
		datoaux[3] += ADCRL;
		canal = 4;
		ADCSC1_ADCH = 0b00100;
		break;
	case 4:
		datoaux[4] = ADCRH<<8;
		datoaux[4] += ADCRL;	
		canal = 5;				
		ADCSC1_ADCH = 0b00101;	
		break;					
	case 5:
		datoaux[5] = ADCRH<<8;
		datoaux[5] += ADCRL;
		canal = 6;
		ADCSC1_ADCH = 0b00110;
		break;
	case 6:
		datoaux[6] = ADCRH<<8;
		datoaux[6] += ADCRL;		
		canal = 7;				
		ADCSC1_ADCH = 0b00111;	
		break;					
	case 7:
		datoaux[7] = ADCRH<<8;
		datoaux[7] += ADCRL;;
		canal = 0;
		ADCSC1_ADCH = 0b00000;
		break;
	default:					
		break;
	}
}
void setADC(){
	SCGC1_ADC = 1;
	ADCCFG = 0X39;
	ADCSC2 = 0x00;
	ADCSC1 = 0x68;
	APCTL1 = 0Xff;
	APCTL2 = 0x01;
}

void setSCI() {
	SCGC1_SCI2 = 1;
    SCI2BDH = 0x00;
    SCI2BDL = 14;
    SCI2C1 = 0x00;
    SCI2C2_TE = 1;
}

//------------------------------------------------------------------------------------------------------------

void SCI_send(char valor){
	while(SCI2S1_TDRE == 0);
	SCI2D = valor;
	return;
}
void sendString(char valor[]){
    unsigned volatile int j = 0;
	while(valor[j]!='\0'){
		SCI_send(valor[j]);
		j++;
    }
	SCI_send('\n');	
}
//------------------------------------------------------------------------------------------------------------


void main(void) {
  SOPT1 = 0x02;
  setADC();
  setSCI();

  EnableInterrupts;
  /* include your code here */
  
  delay(1000);  //Delay de estabilizacion del ADC
  
  ADCSC1 = 0x60;  
    

  for(;;) {
	  datoaux[0] = 1023;
	  conveCadena(datoaux[0]);
    
  } /* loop forever */
  /* please make sure that you never leave main */
}

void convCadena(unsigned short num) {
	temp = num;
	while (temp) {					
		temp = temp / 10;
		factor = factor * 10;
	}
	while (factor > 1) {
		factor = factor / 10;		
		dato[i] = (num / factor);	
		dato[i] = dato[i] + 48;		
		num = num % factor;			
		i++;
	}
	i = 0;
}

void delay(unsigned short max) {
	for (varDelay = 0; varDelay < max; ++varDelay) {
	}
}
