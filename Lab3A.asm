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
;* ----- ------------ ------------------- --------------------------------------------
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

; code section
MyCode:     SECTION
main:
_Startup:
            LDHX   #__SEG_END_SSTACK ; initialize the stack pointer
            TXS
            mov	   #$f8,PTADD   ;PUERTO A| BIT 0,1,2  COMO INPUT
            lda	   #$07			;CARGA HEX 07 EN EL ACULUMADOR
            					;7 6 5 4 3 2 1 0
            					;0 0 0 0 0 1 1 1
            sta    PTAPE 		;SETEA PULL UP EN EL PUERTO A BIT 0,1,2
            mov    #$0e,PTBDD	;PUERTO B| BIT 1,2,3  COMO OUTPUT
            mov    #$f1,PTBD	;PUERTO B| BIT 1,2,3  EN LOW                        
			

mainLoop:
            
            brclr  2,PTAD,boton ;PREGUNTA SI EL BIT 2 DEL PUERTO A ESTA EN BAJO, SI EVALUA A VERDAD PASA A LA RUTINA BOTON
            mov    #$02,PTBD	;BIT 2 DEL PUERTO B EN HIGHT
            feed_watchdog
            BRA    mainLoop		;RETORNA A LA RUTINA MAINLOOP
            
boton: 		
			mov    #$00,PTBD	;BIT 2 DEL PUERTO B EN LOW (DE HECHO TODOS LOS BITS DEL PUERTO B SE APAGAN) 
			bra    mainLoop 	;RETORNA A LA RUTINA MAINLOOP


