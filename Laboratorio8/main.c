// LABORATORIO 8 - 
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

// Configuraciones Iniciales

// Configuraciones Propias del Modulo ADC

#define Entrada0        APCTL1_ADPC0      // Define la entrada analoga 0 - ADP0 (Pin #)
#define Entrada1        APCTL1_ADPC1      // Define la entrada analoga 1 - ADP0 (Pin #)
#define Entrada2        APCTL1_ADPC2      // Define la entrada analoga 2 - ADP0 (Pin #)
#define Entrada3        APCTL1_ADPC3      // Define la entrada analoga 3 - ADP0 (Pin #)
#define Entrada4        APCTL1_ADPC4      // Define la entrada analoga 4 - ADP0 (Pin #)
#define Entrada5        APCTL1_ADPC5      // Define la entrada analoga 5 - ADP0 (Pin #)
#define Entrada6        APCTL1_ADPC6      // Define la entrada analoga 6 - ADP0 (Pin #)
#define Entrada7        APCTL1_ADPC7      // Define la entrada analoga 7 - ADP0 (Pin #)
#define Entradas        APCTL1          // Permite seleccionar la entrada activa del ADC a convertir, mediante Corrimiento

#define bufferADCH           ADCRH      // Toma el nibble inferior para usarse como los bits 12-8 del valor ADC
#define bufferADCL           ADCRL      // Toma el valor como los bits 7-0 del valor ADC

#define convActiva      ADCSC2_ADACT    // Bandera Conversion Activa, no se puede cambiar de canal si este valor es 1
#define convCompleta    ADCSC1_COCO     // Bandera de "Conversion Completa"
 
#define canalEntrada    ADCSC1_ADCH     // Selecciona el canal de entrada (00000 - 01001 en el QE16) al cual se le hara la conversión




// Configuraciones recicladas del Lab. 7

#define display1  PTBD_PTBD0          // Por convención y por orden, se toman los 4 pines del puerto 
#define display2  PTBD_PTBD1          // ubicados en la tarjeta  para facilitar
#define display3  PTBD_PTBD2          // el ensamble en la protoboard, desde esta definicion se pueden ubicar
#define display4  PTBD_PTBD3          // en otro puerto distinto

#define datoDisplay     PTDD        // dato para enviar al display (PTA0-PTA3) (32-35)
#define bufferSCI       SCI2D       // Buffer de datos del SCI

//variables en RAM

unsigned char centima, decima, segundo, dsegundo;   //Variables usadas para el numero visto en el display
unsigned char cronometro;                           //Determina si el cronometro es ascendente (1) o descendente (0)
unsigned char bandera;                              //Permite detener el cronometro con ambos botones 
unsigned int display;

unsigned char flag_rx;                              //Variable bandera de la interrupcion SCI_RX
volatile unsigned int tiempo;
volatile unsigned char contDato = 2;

//Variables en ROM

unsigned const time=10;             //Constante en ROM que determina el numero de ciclos del retardo

void setPrograma()                  // Inicializacion del Programa
{
    SOPT1 = 0x02;                   // deshabilitar el watchdog
    
    ADCSC2_ACFE=0;                  // deshabilita la comparacion de valores en ADC
    ADCSC1_ADCO=0;                  // deshabilita la conversion continua, asi tomara dato a dato que se requiera y activara las banderas
    ADCCFG_MODE=1;                  // Habilita la conversion de 12 bits
    APCTL1 = 0x00;                  // Habilita todos los pines de entrada ADCP0-ADCP7
    
    PTADD = 0x0f;                   //configuracion de pines para manejo del display 7 segmentos
    PTBDD_PTBDD0 = 1;               //pin para anodo 1/digito1
    PTBDD_PTBDD1 = 1;               //pin para anodo 2/digito2
    PTBDD_PTBDD2 = 1;               //pin para anodo 3/digito3
    PTBDD_PTBDD3 = 1;               //pin para anodo 4/digito4
    PTCDD_PTCDD0 = 1;               //define salida para pin 20, PTC0
    PTCDD_PTCDD1 = 1;               //define salida para pin 19, PTC1
    PTCDD_PTCDD2 = 1;               //define salida para pin 15, PTC2

    dsegundo = 2;                   // Inicializa con un valor predefinido, en este caso se coloco
    segundo = 0;                    // el año actual (2019) para ser visualizado
    decima = 1;                     // como prueba de que el boton reset esta funcionando correctamente
    centima = 9;                    //
    
    EnableInterrupts;               //Macro para habilitar interrupciones
}

// Reciclado del Lab7

void setKBI()
{
    PTDPE_PTDPE5 = 1;           // Habilita la resistencia Pull en PTD0, boton "start"
    PTDPE_PTDPE6 = 1;           // Habilita la resistencia Pull en PTD1, boton "stop"   
    
    KBI2SC_KBIE = 1;            // Habilita las interrupciones en KBI2
    KBI2SC_KBIMOD = 0;          // Habilita la operacion solo por flancos
    KBI2SC_KBACK = 0;           // Limpia la bandera de Ejecucion de KBI2 
    
    KBI2PE_KBIPE5 = 1;          // Habilita el Pin 0 de KBI2 (pin 16)
    KBI2PE_KBIPE6 = 1;          // Habilita el pin 1 de KBI2 (pin 17)
    KBI2ES_KBEDG5 = 0;          // Habilita interrupción por flanco de bajada en la entrada KBI2P0
    KBI2ES_KBEDG6 = 0;          // Habilita interrupción por flanco de bajada en ls entrada KBI2P1
}

interrupt VectorNumber_Vkeyboard void KBI_ISR()
{
    KBI2SC_KBACK = 1;           // Limpia la bandera de Interrupción
    
    
    
    //display=displayTop*100+displayDown;
    
    //displayTop=display/100;
    //displayDown=display%100;
    
    //SCI_send(144);              // IMPORTANTE : Dato de Envio
}


void setSCI()
{
    SCI2BDH = 0;
    SCI2BDL = 15;
    SCI2C1 = 0x00;
    SCI2C2_TE = 1;
    SCI2C2_RE = 1;
    SCI2C2_RIE = 1;
}

void SCI_send(char dato)
{
    while(SCI2S1_TDRE == 0);
    SCI2D = dato;
    return;
}

interrupt VectorNumber_Vadc void servicioADC(int entrada)
{
    Entradas=0;
    switch(entrada)
    {
        case 0:
            Entrada0=1;
            
        break;
    }
}

void main(void)
{
  
    setPrograma();                  // Inicializa las variables y parametros del programa
    EnableInterrupts;
  /* include your code here */

  

  for(;;) {
    __RESET_WATCHDOG();	/* feeds the dog */
  } /* loop forever */
  /* please make sure that you never leave main */
}

// Subrutina que envia sucesivamente todos los datos del programa

void enviarTodo()
{
    unsigned volatile int i;
    Entradas=1;
    for(i=0;i<8;i++)
    {
        canalEntrada++;
        SCI_send(bufferADCH);
        pausa(time);
        SCI_send(bufferADCL);
        Entradas<<1;
    }
    Entradas=0;
}

void setDisplay(unsigned int var)                   // Reciclado del Ejemplo
{
    centima=var%10;                //centesimas de s
    decima=var/10%10;             //decimas de s
    segundo=var/100%10;            //unidades
    dsegundo=var/1000;              //decenas
    
    datoDisplay = dsegundo;         //cargar numero del digito 1 en PTA
    display1 = 1;                 //encender el digito 1 con el anodo 1
    pausa(time);              //llamar funcion retardo pasandole valor time para uso en ciclo for
    display1 = 0;                 //apagar el digito 1 para pasar al siguiente
    datoDisplay = segundo;
    display2 = 1;
    pausa(time);
    display2 = 0;
    datoDisplay = decima;
    display3 = 1;
    pausa(time);
    display4 = 0;
    datoDisplay = centima;
    display4 = 1;
    pausa(time);
    display4 = 0;
}

//funcion de retardo por software o polling
void pausa(unsigned short max)
{
    unsigned volatile int ciclo;
    for (ciclo = 0; ciclo < max; ciclo++) 
    {
        //funcion recibe un parametro "max" utilizado para el ciclo for
    }
}
