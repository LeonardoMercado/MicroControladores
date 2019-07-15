#include <hidef.h> /* for EnableInterrupts macro */
#include "derivative.h" /* include peripheral declarations */

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

#define buffSCI  SCI2D              // Buffer de datos del SCI

#define CtrlADC  APCTL1             // Bits de control puertos ADC
#define selecADC ADCSC1_ADCH        // Selector de canal ADC
#define pwmDutyLeft   TPM3C1V       // Contador para el ciclo útil de del motor izquierdo
#define pwmDutyRight  TPM3C2V       // Contador para el ciclo útil de del motor derecho

/************************************VARIABLES ADC*************************************/

unsigned long int posicion;         //Variable para almacenar la posición respecto a la línea
signed short int errorPos;          //Variable para almacenar el error de posición
volatile unsigned char canal;       //Variable para seleccionar el canal ADC
volatile unsigned long int sensorHL[8];  //Variable para almacenar el valor de cada sensor
volatile char sensorH[8];           //Arreglo para almacenar la parte alta de la conversión
volatile char sensorL[8];           //Arreglo para almacenar la parte baja de la conversión

/************************************VARIABLES SCI*************************************/

volatile char enviarLectura;        //Funciona como booleano
unsigned char flag_rx;              //Variable bandera de la interrupcion SCI_RX

/************************************VARIABLES TPM*************************************/

volatile unsigned int timerTpmLB;     //Timer de la interrupción para el motor izquierdo
volatile unsigned int timerTpmRA;     //Timer de la interrupción para el motor izquierdo
volatile unsigned int contadorLeft;   //Contador para rampa del motor izquierdo
volatile unsigned int contadorRight;  //Contador para rampa del motor derecho
volatile char LeftOn;                 //Bandera de encendido motor izquierdo
volatile char RightOn;                //Bandera de encendido motor derecho


/************************************VARIABLES PARA LOS CONTROLADORES*******************/
volatile unsigned char wRefmotorR;  //Variable para almacenar la velocidad Angular de referencias del motor R.
volatile unsigned char wRefmotorL;  //Variable para almacenar la velocidad Angular de referencias del motor R.
volatile unsigned char wCrucero;  
volatile signed char errorWmotorR;         //Variable para almacenar el error de velocidad del motor Derecho.
volatile signed char errorWmotorL;         //Variable para almacenar el error de velocidad del motor Izquierdo.
volatile float zRant;      //Variable para el error anterior de W para el motor derecho.
volatile float zLant;      //Variable para el error anterior de W para el motor izquierdo.
volatile short int errorPosAnt;     //Variable para almacenar el error de posción anterior. 
volatile float PID;                 //Variable que almacena el valor de PID para el control de posición.
volatile float Kp;                  //Variable proporcional del controladore de posición.
volatile float Kd;                  //Variable derivativa del controladore de posición.
volatile float Ki;                  //Variable integral del controladore de posición.

//Constantes  

unsigned const time=1000;               //Constante  que determina el numero de ciclos del retardo
//unsigned const short int sensorMax[8]={3906,3914,3910,3926,3900,3886,3877,3869};    //Valores promedio para el valor máximo de cada sensor
//unsigned const short int sensorMin[8]={1232,1436,1076,1425,945,921,797,590};         //Valores promedio el valor mínimo de cada sensor
unsigned const short int sensorMax[8]={3939,3941,3914,3967,4006,4044,3993,4054};    //Valores máximos pista de prueba
unsigned const short int sensorMin[8]={2036,2108,1743,2086,1959,2043,1925,1512};        //Valores mínimos pista de prueba
signed const short int setPoint=14332;   //Posición deseada. Dando a cada sensor un peso de 4095 (SP=4095*7/2)


//Prototipos de funciones
void retardo(unsigned short);       //entienda el nombre y los parametros que reciben/retornan 
void SCI_send(char);
void ADC_send(void);
void calcPosic(void);
void send_pos(void);
void controlPos(void);
void controlWmotorR(void);
void controlWmotorL(void);
void send_errorPos(void);
void calc_Vang(void);

// MODULO SCI
void setSCI()
{
    SCGC1_SCI2 = 1;   //Activar Bus Clock para el módulo SCI2
    SCI2BDH = 0;      //Modulo divisor =0
    SCI2BDL = 13;     // 19600 Baud Rate     
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
        SCI_send ('S');
        retardo(time);
    }else{
        enviarLectura=0;
        //canal=0;
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

interrupt VectorNumber_Vadc void ADC_ISR()  //interrupción generada cuando se completa una conversión 
{   
   sensorHL[canal]=ADCR;
   if(sensorHL[canal]>sensorMax[canal]){
       sensorHL[canal]=sensorMax[canal]; 
   }
   if(sensorHL[canal]<sensorMin[canal]){
       sensorHL[canal]=sensorMin[canal]; 
   }
   sensorHL[canal]=(sensorHL[canal]-sensorMin[canal])*4095/(sensorMax[canal]-sensorMin[canal]);   
   sensorH[canal]=sensorHL[canal]%65536/256; //Almacenar parte baja del dato 
   sensorL[canal]=sensorHL[canal]%256; //Almacenar parte alta del dato         
}


// MODULO TPM

void set_tpm_PWM()
{    
    TPM3SC_CLKSx  = 0b01;   // Clock Source, 01 Buss Clock  4M (00 desactiva TPM)
    TPM3SC_PS = 0b000;      // Preescaler, TPMCLK = BUSCLK/2^(PS) F=Fbus/2^(PS), tiempo pulso TPM=2^(PS)/FBus
    TPM3SC_CPWMS = 0;       // Center PWM, 0 - desactivado, alineado en flanco subida/bajada
    
    //Configuración TPM3CH1 Motor_LB TPM3CH2 Motor_RB 

    TPM3C1SC_MS1x  = 0b10;  // Mode Select, 10 Edge Aligned PWM
    TPM3C2SC_MS2x  = 0b10;  // Mode Select, 10 Edge Aligned PWM  

    TPM3C1SC_ELS1x  = 0b10; // Edge Level Select, 10 - Flanco de subida, 01 - Flanco de bajada
    TPM3C2SC_ELS2x  = 0b10; // Edge Level Select, 10 - Flanco de subida, 01 - Flanco de bajada
    TPM3MOD = 1000;         // Cantidad de cuentas con el reloj, MOD x tcuenta = Periodo señal  F=4K
       
    pwmDutyLeft = 0;            // Ciclo útil = Valor TPMxCnV/TPMxMOD
    pwmDutyRight = 0;           // Ciclo útil = Valor TPMxCnV/TPMxMOD  
}

void set_tmp_input()
{     
    //Configuración TPM2CH1 Encoder_RA
    TPM2SC_CLKSx  = 0b01;   // Clock Source, 01 Buss Clock  4M (00 desactiva TPM)
    TPM2SC_PS = 0b000;      // Preescaler, TPMCLK = BUSCLK/2^(PS)
    TPM2SC_CPWMS = 0;       // Center PWM, 0 - desactivado, alineado en flanco    
    
    TPM2C1SC_MS1x = 0b00;   // Mode Select, 00 Input capture   
    TPM2C1SC_ELS1x = 0b01;  // Edge Level Select, 01 - Captura en flanco de subida unicamente    
    TPM2C1SC_CH1IE = 1;     // Activar Interrupción TPM2CH1 encoder RA       
    TPM2C1SC_CH1F = 0;      //Evitar falsas interrupciones 
}

void set_tmp_input2()
{     
    //Configuración TPM1CH2 Encoder_LB
    TPM1SC_CLKSx  = 0b01;   // Clock Source, 01 Buss Clock  4M (00 desactiva TPM)
    TPM1SC_PS = 0b000;      // Preescaler, TPMCLK = BUSCLK/2^(PS)
    TPM1SC_CPWMS = 0;       // Center PWM, 0 - desactivado, alineado en flanco    
    
    TPM1C2SC_MS2x = 0b00;   // Mode Select, 00 Input capture   
    TPM1C2SC_ELS2x = 0b01;  // Edge Level Select, 01 - Captura en flanco de subida unicamente    
    TPM1C2SC_CH2IE = 1;     // Activar Interrupción TPM2CH1 encoder RA     
    TPM1C2SC_CH2F = 0;      //Evitar falsas interrupciones 
}

//Interrupción TPM2CH1 Encoder_RA
interrupt VectorNumber_Vtpm2ch1 void tpm2_ch1_isr(){
    timerTpmRA = TPM2C1V;
    contadorRight++;
    RightOn=1;
    TPM2CNT=0; 
    TPM2C1SC_CH1F = 0;           //acknowledge interrupt
}

//Interrupción TPM1CH2 Encoder_LA
interrupt VectorNumber_Vtpm1ch2 void tpm1_ch2_isr(){
    timerTpmLB = TPM1C2V;
    LeftOn=1;
    contadorLeft++;    
    TPM1CNT=0;
    TPM1C2SC_CH2F = 0;           //acknowledge interrupt
}

void setPrograma()                  // Inicializacion del Programa
{
    SOPT1 = 0x02;                   //deshabilitar el watchdog      
    ICSTRM = 0xBC;                  // Trim CLk a 231 (busclk = 4k) 
    ICSSC_FTRIM =1;
    setSCI();                       // Inicializa SCI
    set_tpm_PWM();
    set_tmp_input();
    set_tmp_input2();
    setADC();                       // Inicializa ADC
    EnableInterrupts;               //Macro para habilitar interrupciones
    contadorLeft=0;
    contadorRight=0;
    zRant = 0;
    zLant = 0;
    errorPosAnt = 0;
    Kp = 0;
    Kd = 0;
    Ki = 0;   
}

void main(void) 
{   
    setPrograma();                  // Inicializa las variables y parametros del programa   
    enviarLectura=0;
    selecADC=0;  
    canal=0;    
    wCrucero = 200;    
    wRefmotorR = 50;
    wRefmotorL = 20;     
    for (;;)    
    /* please make sure that you never leave main */
    {  //Siempre mostrar  los datos 
    	
        if(enviarLectura){
    	    controlWmotorR();
    	    controlWmotorL();
            controlPos();
            ADC_send(); 
            send_pos();
            send_errorPos();
            calcPosic();
            calc_Vang();             
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

void ADC_send()
{   
    while(canal<8){
    SCI_send(sensorH[canal]); //transmitir parte alta del dato
    retardo(time);
    SCI_send(sensorL[canal]); //transmitir parte baja del dato  
    retardo(time);
    canal++;
    selecADC++; 
    }
    canal=0;
    selecADC=0;
}

void calcPosic(){   
    int i=0;    
    unsigned long int suma=0;
    posicion=0;
    while(i<8){     
        suma=suma+sensorHL[i]%65536;
        posicion=posicion+i*(sensorHL[i]%65536);
        i++;
    }
    posicion=(posicion*4095/suma)%65536;        
}

void send_pos(){
    char posicionH;
    char posicionL;
    posicionH=posicion%65536/256;
    posicionL=posicion%65536%256;
    SCI_send(posicionH);
    retardo(time);
    SCI_send(posicionL);
    retardo(time);
}

void controlPos(){
    errorPos=(posicion%65536-setPoint)%65536;
    
    /*REVISAR DEFINICIÓN DE RANGO PARA EL CUAL SE REQUIERE OBLIGAR A REACCIONAR AL BORDE DE LA LÍNEA*/
    /*
    if(errorPos<-14332){
        wRefmotorR = 100;
        wRefmotorL =  160;
    }
    if(errorPos>14332){
        wRefmotorR =  160;
        wRefmotorL =  100;
    }else{  
        PID = Kp*errorPos + Kd*(errorPos - errorPosAnt) + Ki*(errorPos+errorPosAnt);
        if(PID>wCrucero){
            PID = wCrucero;
        }
        wRefmotorR = wCrucero - PID;
        wRefmotorL = wCrucero + PID;
        errorPosAnt = errorPos;
    }
    */
}

void send_errorPos(){   
    char errorPosL;
    char errorPosH;
    unsigned short int errorPosAux;
    
    if(errorPos<0){
        SCI_send('N');      
        errorPosAux=errorPos*(-1);
    }else{
        SCI_send('P');
        errorPosAux=errorPos;
    }   
    errorPosH=errorPosAux/256;
    errorPosL=errorPosAux%256;
    SCI_send(errorPosH);
    retardo(10*time);
    SCI_send(errorPosL);
    retardo(10*time);
}


void calc_Vang(void){
    
    unsigned long int velAngL;
    
    char velAngLL;  
    
    unsigned long int velAngR;
    
    char velAngRL;
    
    char velAngLH;
    char velAngRH;    
    
    if(LeftOn==0){
        velAngL=0;
        velAngLL=0; 
        velAngLH=0;
    }else{
        velAngL=209440/timerTpmLB;  //velAng=f_s*2pi/(pulsos*rel_transm*contador)
        velAngLL=(velAngL%65536)%256;
    }    
    if(RightOn==0){
        velAngR=0;  
        velAngRL=0; 
        velAngRH=0; 
    }else{
        velAngR=209440/timerTpmRA;  //velAng=f_s*2pi/(pulsos*rel_transm*contador)
        velAngRL=(velAngR%65536)%256;
    }
        
    errorWmotorR = wRefmotorR - velAngRL;
    errorWmotorL = wRefmotorL - velAngLL;
    
    SCI_send(velAngLL);   
    retardo(time);
    SCI_send(velAngRL);
    retardo(time);
};

void controlWmotorR(void){    
    float zR;
    float uR;
    float vMaxR;  //Ajustar aqui el voltaje máximo del motor derecho    
    //Matrices del controlador---------
    const float A=1;
    const float B=0.002652;
    const float C = 1.665;
    const float D= 0.004048;       
    vMaxR = 6,225;   
    zR = A*zRant + B*errorWmotorR; 
    uR = C*zRant + D*errorWmotorR;
    zRant = zR;    
    pwmDutyRight = (uR/vMaxR)*1000;
    if(pwmDutyRight>1000){
        pwmDutyRight = 1000;
    }    
};

void controlWmotorL(void){
    float zL;
    float uL;
    float vMaxL = 6.455; //Ajustar aqui el voltaje máximo del motor izquierdo
    //Matrices del controlador---------
    const float A = 1;
    const float B = 0.002652;
    const float C = 1.656;
    const float D = 0.004026;
    //---------------------------------
    zL = A*zLant + B*errorWmotorL;
    uL = C*zLant + D*errorWmotorL;
    zLant = zL;    
    pwmDutyLeft = (uL/vMaxL)*1000;
    if(pwmDutyLeft>1000){
        pwmDutyLeft = 1000;
    }   
};



