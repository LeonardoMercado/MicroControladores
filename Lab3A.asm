;********************************************************************************************
;* UNIVERSIDAD NACIONAL DE COLOMBIA SEDE BOGOTÁ - DEP MECÁNICA Y MECATRÓNICA.
;********************************************************************************************
;*
;* Title: Código para la implementación del laboratorío #3 A de microcontroladores Unal 2019-I
;*
;* Author: Maria Alejandra Arias Torres, Leonardo Fabio Mercado Benítez.
;*
;* Description: Encendido de led RGB con switch independiente para cada canal de color.
;*
;* Documentation: Guía GQ8 Cap 7
;*
;* Include Files: Ninguno
;*
;* Revision History:
;
;* Rev #      Date           Who             Comments
;* ----- ------------ ------------------- ---------------------------------------------------
;* 1.2   24-Apr-2019 Leonardo M. Benítez  Se implementa antirebote por software para cada switch.
;* 1.1   23-Apr-2019 Maria A. Leonardo    Se implementa modificaciones  al código y queda 
;*										  disponible para su primera prueba de funcionamiento.
;* 1.0   23-Apr-2019 Leonardo M. Benítez  Se implementa el código básico para encender un led
;********************************************************************************************

; Include derivative-specific definitions
            INCLUDE 'derivative.inc'
            

; export symbols
            XDEF _Startup, main
            ; we export both '_Startup' and 'main' as symbols. Either can
            ; be referenced in the linker .prm file or from C/C++ later on
            
            
            
            XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack


; variable/data section
MY_ZEROPAGE: SECTION  SHORT         ; Insert here your data definition

btnst0:   dc.b  1					;Definición de variables de 1 byte 
btnst1:   dc.b  1					;Definición de variables de 1 byte
btnst2:   dc.b  1					;Definición de variables de 1 byte

; code section
MyCode:     SECTION
main:
_Startup:
            LDHX   #__SEG_END_SSTACK ;Inicializa los punteros H y X   DIRECCIONAMIENO(IMM)
            TXS					;inicializa el puntero del stack DIRECCIONAMIENO(INH)
            mov	   #$f8,PTADD   ;PUERTO A| BIT 0,1,2  COMO INPUT DIRECCIONAMIENO(IMM/DIR)
            lda	   #$07			;CARGA HEX 07 EN EL ACULUMADOR   DIRECCIONAMIENO(IMM)
            					;7 6 5 4 3 2 1 0
            					;0 0 0 0 0 1 1 1
            sta    PTAPE 		;CONFIGURA PULL UP EN EL PUERTO A BIT 0,1,2      DIRECCIONAMIENO(DIR)
            mov    #$01,btnst0	;INICIALIZACIÓN DEL ESTADO DEL SWITCH 0 EN ALTO  DIRECCIONAMIENO(IMM/DIR)
            mov    #$01,btnst1  ;INICIALIZACIÓN DEL ESTADO DEL SWITCH 1 EN ALTO  DIRECCIONAMIENO(IMM/DIR)
            mov    #$01,btnst2  ;INICIALIZACIÓN DEL ESTADO DEL SWITCH 2 EN ALTO  DIRECCIONAMIENO(IMM/DIR)
            mov    #$0e,PTBDD	;PUERTO B| BIT 1,2,3  COMO OUTPUT                DIRECCIONAMIENO(IMM/DIR)
            mov    #$0e,PTBD	;PUERTO B| BIT 1,2,3  EN ALTO                    DIRECCIONAMIENO(IMM/DIR)   
			

mainLoop:						;ETIQUETA QUE SE EJECUTA EN LOOP
            
            brclr  0,PTAD,boton0 ;PREGUNTA SI EL BIT 0 DEL PUERTO A ESTA EN BAJO, SI EVALUA A VERDAD PASA A LA RUTINA BOTON0 DIRECCIONAMIENO(DIR)
            brclr  1,PTAD,boton1 ;PREGUNTA SI EL BIT 1 DEL PUERTO A ESTA EN BAJO, SI EVALUA A VERDAD PASA A LA RUTINA BOTON1 DIRECCIONAMIENO(DIR)
            brclr  2,PTAD,boton2 ;PREGUNTA SI EL BIT 2 DEL PUERTO A ESTA EN BAJO, SI EVALUA A VERDAD PASA A LA RUTINA BOTON2 DIRECCIONAMIENO(DIR)
            feed_watchdog		 ;LLAMADA A MAMÁ PARA QUE NO REINICIE LA RUTINA.
            BRA    mainLoop		 ;RETORNA A LA RUTINA MAINLOOP  DIRECCIONAMIENO(REL)
            
            
;_____________________________________________________________________________________________________________________________ 
;RUTINA PARA COMPLEMENTO DEL ESTADO SALIDA DEL LED EN EL PUERTO B BIT 1           
boton0:
			mov   #$00,btnst0  	 ;REFRESCA EL ESTADO DE LA VARIABLE BTNST0  DIRECCIONAMIENO(IMM/DIR)		
			lda    PTBD			 ;CARGA EN EL ACUMULADOR EL RESGISTRO PTBD(ALMACENA EL ESTADO DEL PUERTO DE SALIDA)  DIRECCIONAMIENO(DIR)
			eor    #%00000010	 ;OPERACIÓN XOR SOBRE LO QUE HAYA EN EL ACUMULADOR(COMPLEMENTA EL ESTADO DEL PUESTO B BIT 1) DIRECCIONAMIENO(IMM)	
			sta    PTBD          ;CARGA EL ACUMULADOR EN EL REGISTRO DE PTBD(ACTUALIZA EL ESTADO DEL PUERTO DE SALIDA)  DIRECCIONAMIENO(DIR)
still0:							 ;INICIO DEL ANTIREBORE SW
            lda    PTAD          ;CARGA EN EL ACUMULADOR EL RESGISTRO PTAD(ALMACENA EL ESTADO DEL PUERTO DE ENTRADA)  DIRECCIONAMIENO(DIR)
            cbeq   btnst0,still0 ;COMPARA EL ESTADO DEL BTN0 CON EL ACUMULADOR Y SALTA A STILL0 SI SON IGUALES.  DIRECCIONAMIENO(DIR)
            nop					 ;SIN OPERACIÓN (PEQUEÑO RETARDO) DIRECCIONAMIENO(INH)                         
			bra    mainLoop 	 ;RETORNA A LA RUTINA MAINLOOP DIRECCIONAMIENO(REL)
;_____________________________________________________________________________________________________________________________


;_____________________________________________________________________________________________________________________________
;RUTINA PARA COMPLEMENTO DEL ESTADO SALIDA DEL LED EN EL PUERTO B BIT 2
boton1:
			mov   #$00,btnst1  	 ;REFRESCA EL ESTADO DE LA VARIABLE BTNST1  DIRECCIONAMIENO(IMM/DIR) 	
			lda    PTBD          ;CARGA EN EL ACUMULADOR EL RESGISTRO PTBD(ALMACENA EL ESTADO DEL PUERTO DE SALIDA)  DIRECCIONAMIENO(DIR)
			eor    #%00000100	 ;OPERACIÓN XOR SOBRE LO QUE HAYA EN EL ACUMULADOR(COMPLEMENTA EL ESTADO DEL PUESTO B BIT 2) DIRECCIONAMIENO(IMM)	
			sta    PTBD			 ;CARGA EL ACUMULADOR EN EL REGISTRO DE PTBD(ACTUALIZA EL ESTADO DEL PUERTO DE SALIDA)  DIRECCIONAMIENO(DIR)
still1:							 ;INICIO DEL ANTIREBORE SW
            lda   PTAD           ;CARGA EN EL ACUMULADOR EL RESGISTRO PTAD(ALMACENA EL ESTADO DEL PUERTO DE ENTRADA)  DIRECCIONAMIENO(DIR)
            cbeq  btnst1,still1  ;COMPARA EL ESTADO DEL BTN1 CON EL ACUMULADOR Y SALTA A STILL1 SI SON IGUALES.  DIRECCIONAMIENO(DIR)
                                  
            nop					 ;SIN OPERACIÓN (PEQUEÑO RETARDO) DIRECCIONAMIENO(INH)           
			bra    mainLoop 	 ;RETORNA A LA RUTINA MAINLOOP DIRECCIONAMIENO(REL)
			
;_____________________________________________________________________________________________________________________________
;RUTINA PARA COMPLEMENTO DEL ESTADO SALIDA DEL LED EN EL PUERTO B BIT 3

boton2:
			mov   #$00,btnst2  	 ;REFRESCA EL ESTADO DE LA VARIABLE BTNST1  DIRECCIONAMIENO(IMM/DIR) 	
			lda    PTBD          ;CARGA EN EL ACUMULADOR EL RESGISTRO PTBD(ALMACENA EL ESTADO DEL PUERTO DE SALIDA)  DIRECCIONAMIENO(DIR)
			eor    #%00001000	 ;OPERACIÓN XOR SOBRE LO QUE HAYA EN EL ACUMULADOR(COMPLEMENTA EL ESTADO DEL PUESTO B BIT 3) DIRECCIONAMIENO(IMM)		
			sta    PTBD			 ;CARGA EL ACUMULADOR EN EL REGISTRO DE PTBD(ACTUALIZA EL ESTADO DEL PUERTO DE SALIDA)  DIRECCIONAMIENO(DIR)
still2:							 ;INICIO DEL ANTIREBORE SW
            lda   PTAD           ;CARGA EN EL ACUMULADOR EL RESGISTRO PTAD(ALMACENA EL ESTADO DEL PUERTO DE ENTRADA)  DIRECCIONAMIENO(DIR)
            cbeq  btnst2,still2  ;COMPARA EL ESTADO DEL BTN2 CON EL ACUMULADOR Y SALTA A STILL2 SI SON IGUALES.  DIRECCIONAMIENO(DIR)
            nop					 ;SIN OPERACIÓN (PEQUEÑO RETARDO) DIRECCIONAMIENO(INH)                                              
			bra    mainLoop 	 ;RETORNA A LA RUTINA MAINLOOP DIRECCIONAMIENO(REL)
;_____________________________________________________________________________________________________________________________
