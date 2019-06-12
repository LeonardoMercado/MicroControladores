#include <hidef.h> /* for EnableInterrupts macro */
#include "derivative.h" /* include peripheral declarations */

unsigned short var, x_h;
volatile unsigned char canal = 1;
volatile unsigned short dato[2];

unsigned char arr[6], i = 0;
unsigned int num, temp;
unsigned long factor = 1;		//factor cuenta el numero de digitos con multiplos de 10, por eso es long

void getAscii(unsigned int);
void retardo(unsigned short);

interrupt VectorNumber_Vadc void adc_isr() {	//interrupción que se activa con cada conversion completada
	switch (canal) {			//alternar entre canales segun el canal anterior leido
	case 1:
		dato[0] = ADCRL;		//como se esta en configuracion de solo 8 bits
		canal = 2;				//basta con leer solo la parte baja del resultado ADCRL
		ADCSC1_ADCH = 0b00111;	//cambiar de canal
		break;					//importante break en switch para no evaluar mas casos.
	case 2:
		dato[1] = ADCRL;
		canal = 1;
		ADCSC1_ADCH = 0b00110;
		break;
	default:					//caso default en caso de que se tengan otros valores de canal inesperados
		break;
	}
}

void SCI_init() {
	SCI1BDH = 0;
	SCI1DL = 27;
	SCI1C1 = 0x00;
	SCI1C2_TE = 1;
	SCI1C2_RE = 1;
	SCI1C2_RIE = 1;
}

void SCI_send(unsigned char mensaje) {
	while (SCIS1_TDRE == 0);				//enviar datos por polling en el puerto serial
	SCID = mensaje;							//esperando que el registro se desocupe
}

void main(void) {
	SOPT1 = 0x02;
	SCI_init();
	ADCCFG_ADLPC = 0;
	ADCCFG_ADIV = 0b01;
	ADCCFG_ADLSMP = 0;
	ADCCFG_MODE = 0b00;
	ADCCFG_ADICLK = 0b01;

	EnableInterrupts
	;

	ADCSC1_ADCO = 1;
	ADCSC1_AIEN = 1;				//habilitar interrupcion ADC
	ADCSC1_ADCH = 0b00110;

	/* include your code here */

	for (;;) {
		x_h = dato[0];
		getAscii(x_h);				//conversion a ASCII
		while (x_h != 0) {			//enviar digitos al puerto
			x_h = x_h / 10;			//cuando ya no quedan digitos sale del while
			SCI_send(arr[i]);
			i++;
		}
		i = 0;
		SCI_send(13);		//enviar retorno de carrito
		SCI_send(10);		//enviar line finish
		retardo(6000);		//retardo por polling para dealy entre envio de datos
	} /* loop forever */
	/* please make sure that you never leave main */
}

void getAscii(unsigned int num) {
	temp = num;
	while (temp) {					//contar el numero de digitos del dato
		temp = temp / 10;
		factor = factor * 10;
	}
	while (factor > 1) {
		factor = factor / 10;		
		arr[i] = (num / factor);	//descomponer el número en digitos
		arr[i] = arr[i] + 48;		//sumarle 48 a cada digito y guardarlo en un arreglo
		num = num % factor;			//actualizar numero con los siguientes digitos que faltan
		i++;
	}
	i = 0;
}

void retardo(unsigned short max) {
	for (var = 0; var < max; ++var) {
	}
}
