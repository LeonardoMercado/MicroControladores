#include <hidef.h> /* for EnableInterrupts macro */
#include "derivative.h" /* include peripheral declarations */



interrupt VectorNumber_Vadc void adc_isr() {	

}



void main(void) {
	
	SCGC1 = 0XFF;
	ADCCFG = 0X29;
	ADCSC2 = 0x00;
	ADCSC1 = 0x68;
	APCTL1 = 0Xff;
	APCTL2 = 0x01;
	
	
	
	
	
  EnableInterrupts;
  /* include your code here */

  

  for(;;) {
    __RESET_WATCHDOG();	/* feeds the dog */
  } /* loop forever */
  /* please make sure that you never leave main */
}
