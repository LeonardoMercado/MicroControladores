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

#include <hidef.h>          /* for EnableInterrupts macro */
#include "derivative.h"     /* include peripheral declarations */

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

#define bufferADCH      ADCRH           // Toma el nibble inferior para usarse como los bits 12-8 del valor ADC
#define bufferADCL      ADCRL           // Toma el valor como los bits 7-0 del valor ADC

#define convActiva      ADCSC2_ADACT    // Bandera Conversion Activa, no se puede cambiar de canal si este valor es 1
#define convCompleta    ADCSC1_COCO     // Bandera de "Conversion Completa"
 
#define canalEntrada    ADCSC1_ADCH     // Selecciona el canal de entrada (00000 - 01001 en el QE16) al cual se le hara la conversión




// Configuraciones recicladas del Lab. 7

#define display1  PTBD_PTBD4          // Por convención y por orden, se toman los 4 pines del puerto 
#define display2  PTBD_PTBD5          // ubicados en la tarjeta  para facilitar
#define display3  PTBD_PTBD6          // el ensamble en la protoboard, desde esta definicion se pueden ubicar
#define display4  PTBD_PTBD7          // en otro puerto distinto

#define enviar    PTDD_PTDD5
#define cambiar   PTDD_PTDD6  

#define datoDisplay     PTDD        // dato para enviar al display (PTA0-PTA3) (32-35)
#define bufferSCI       SCI2D       // Buffer de datos del SCI

// variables en RAM

int datoADC[8];                      // Almacena el dato resultante de ADC
int entrada;

//RAM - Reciclado del Lab7

unsigned char centima, decima, segundo, dsegundo;   //Variables usadas para el numero visto en el display
unsigned char cronometro;                           //Determina si el cronometro es ascendente (1) o descendente (0)
unsigned char bandera;                              //Permite detener el cronometro con ambos botones 
unsigned int display;

unsigned char flag_rx;                              //Variable bandera de la interrupcion SCI_RX
volatile unsigned int tiempo;
volatile unsigned char contDato = 2;

//Variables en ROM

unsigned const time=10;             //Constante en ROM que determina el numero de ciclos del retardo

// Prototipos de Funciones

void setDisplay(unsigned int);      //prototipos de las funciones para que el compilador
void retardo(unsigned short);       //entienda el nombre y los parametros que reciben/retornan
void enviarTodo(void);              //


void setPrograma()                  // Inicializacion del Programa
{
    SOPT1 = 0x02;                   // deshabilitar el watchdog
    
    PTDDD = 0x0f;                   // configuracion de pines para manejo del display 7 segmentos, Puerto D
    PTBDD = 0xf0;                   // configuracion de pines para manejo del display, seleccion de digito  

    dsegundo = 2;                   // Inicializa con un valor predefinido, en este caso se coloco
    segundo = 0;                    // el año actual (2019) para ser visualizado
    decima = 1;                     // como prueba de que el boton reset esta funcionando correctamente
    centima = 9;
    
    display=6666;
    
    EnableInterrupts;               //Macro para habilitar interrupciones
}

// Configuracion KBI + Interrupcion KBI

void setKBI()
{
    PTDPE_PTDPE5 = 1;           // Habilita la resistencia Pull en PTD0, boton "start"
    PTDPE_PTDPE6 = 1;           // Habilita la resistencia Pull en PTD1, boton "stop"   
    
    KBI2SC_KBIE = 1;            // Habilita las interrupciones en KBI2
    KBI2SC_KBIMOD = 0;          // Habilita la operacion solo por flancos
    KBI2SC_KBACK = 0;           // Limpia la bandera de Ejecucion de KBI2 
    
    KBI2PE_KBIPE5 = 1;          // Habilita KBI2P5 (pin 18)
    KBI2PE_KBIPE6 = 1;          // Habilita KBI2P6 (pin 17)
    KBI2ES_KBEDG5 = 0;          // Habilita interrupción por flanco de bajada en la entrada KBI2P0
    KBI2ES_KBEDG6 = 0;          // Habilita interrupción por flanco de bajada en ls entrada KBI2P1
}
interrupt VectorNumber_Vkeyboard void KBI_ISR()
{
    KBI2SC_KBACK = 1;           // Limpia la bandera de Interrupción
    
    //Boton Enviar
    if(enviar==0)
    {
        display++;
    }
    
    //Boton Cambiar
    if(cambiar==0)
    {
        display--;
    }
}

// Configuracion SCI + Interrupcion SCI

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

// Configuracion ADC + Interrupcion ADC

void setADC()
{
    SCGC1_ADC = 1;                  // Asegura que el modulo ADC reciba señal de reloj del BUSCLK
    
    ADCSC1_AIEN=1;                  // Habilita/Deshabilita la conversion ADC
    ADCSC1_ADCO=0;                  // deshabilita la conversion continua, asi tomara dato a dato que se requiera y activara las banderas
    ADCSC1_ADCH=0x1f;               // Activa/Desactiva la conversion ADC, 11111 la desactiva, otro valor cambia el canal (0-7 en este caso)

    ADCSC2_ADTRG=0;                 // Establece el disparador del ADC, 0 software, 1 hardware
    ADCSC2_ACFE=0;                  // deshabilita la comparacion de valores en ADC
    ADCSC2_ACFGT=0;                 // selecciona el disparo de comp. por hardware, 0 menor que, 1 mayor que
    
    ADCCFG_ADLPC=0;                 // Modo Ahorro de energia, 0 deshabilitado
    ADCCFG_ADIV=0;                  // Divisor de reloj de entrada, 00 sin division, 11 div. 8
    ADCCFG_MODE=1;                  // Habilita la conversion de 12 bits
    ADCCFG_ADICLK=0;                // Selecciona el reloj de uso del ADC, 00=Busclk, 01=busclk/2
    
    APCTL1 = 0x00;                  // Habilita todos los pines de entrada ADCP0-ADCP7
    APCTL2 = 0x00;                  // Habilita todos los pines de entrada ADCP9-ADCP15
}
interrupt VectorNumber_Vadc void servicioADC()
{
    //Entradas=0;
    switch(canalEntrada)
    {
        case 0:
            //Entrada0=1;
            datoADC[0]=bufferADCH;
            datoADC[0]<<8;
            datoADC[0]=datoADC[0]+bufferADCL;
        break;
        case 1:
            //Entrada1=1;
            datoADC[1]=bufferADCH;
            datoADC[1]<<8;
            datoADC[1]=datoADC[1]+bufferADCL;
        break;
        case 2:
            //Entrada2=1;
            datoADC[2]=bufferADCH;
            datoADC[2]<<8;
            datoADC[2]=datoADC[2]+bufferADCL;
        break;
        case 3:
            //Entrada3=1;
            datoADC[3]=bufferADCH;
            datoADC[3]<<8;
            datoADC[3]=datoADC[3]+bufferADCL;
        break;
        case 4:
            //Entrada4=1;
            datoADC[4]=bufferADCH;
            datoADC[4]<<8;
            datoADC[4]=datoADC[4]+bufferADCL;
        break;
        case 5:
            //Entrada5=1;
            datoADC[5]=bufferADCH;
            datoADC[5]<<8;
            datoADC[5]=datoADC[3]+bufferADCL;
        break;
        case 6:
            //Entrada6=1;
            datoADC[6]=bufferADCH;
            datoADC[6]<<8;
            datoADC[6]=datoADC[6]+bufferADCL;
        break;
        case 7:
            //Entrada7=1;
            datoADC[7]=bufferADCH;
            datoADC[7]<<8;
            datoADC[7]=datoADC[7]+bufferADCL;
        break;
    }
    Entradas=0;
}

void main(void)
{
    setPrograma();                  // Inicializa las variables y parametros del programa
    setADC();                       // Inicializa ADC
    setKBI();                       // Inicializa KBI
    setSCI();                       // Inicializa SCI
   
    for (;;) 
    {
        // Prueba ADC
        
        canalEntrada=2;
        Entrada2=1;
        
        display=datoADC[2];
        
        setDisplay(display);                    //llamar a display constantemente
        //enviarTodo();
    } 
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
        retardo(time);
        SCI_send(bufferADCL);
        Entradas<<1;
    }
    Entradas=0;
}

// Reciclado del Lab7

void setDisplay(unsigned int var)                   
{
    centima=var%10;                //centesimas de s
    decima=var/10%10;             //decimas de s
    segundo=var/100%10;            //unidades
    dsegundo=var/1000;              //decenas
    
    datoDisplay = dsegundo;         //cargar numero del digito 1 en PTA
    display1 = 1;                 //encender el digito 1 con el anodo 1
    retardo(time);              //llamar funcion retardo pasandole valor time para uso en ciclo for
    display1 = 0;                 //apagar el digito 1 para pasar al siguiente
    datoDisplay = segundo;
    display2 = 1;
    retardo(time);
    display2 = 0;
    datoDisplay = decima;
    display3 = 1;
    retardo(time);
    display3 = 0;
    datoDisplay = centima;
    display4 = 1;
    retardo(time);
    display4 = 0;
}

void retardo(unsigned short max)
{
    unsigned volatile int ciclo;
    for (ciclo = 0; ciclo < max; ciclo++) 
    {
        //funcion recibe un parametro "max" utilizado para el ciclo for
    }
}
