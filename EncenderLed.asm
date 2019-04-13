;*******************************************************************
;*UNIVERSIDAD NACIONAL DE COLOMBIA SEDE BOGOTÁ
;
;*12 DE ABRIL DE 2019
; 
;*AUTOR: MARIA ALEJANDRA ARIAS TORRES; LEONARDO FABIO MERCADO BENITEZ
;
;*DESCRIPCION: HOLA MUNDO CON LED Y PULSADO: MODIFICANDO PUERTOS DE ENTRADA Y SALIDA
;
;*DOCUMENTACION: DATASHEET GQ8 
;*******************************************************************

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
            mov	   #$fb,PTADD   ;PUERTO A| BIT 2  COMO INPUT
            lda	   #$04			;CARGA HEX 04 EN EL ACULUMADOR
            					;7 6 5 4 3 2 1 0
            					;0 0 0 0 0 1 0 0
            sta    PTAPE 		;SETEA PULL UP EN EL PUERTO A BIT 2
            mov    #$02,PTBDD	;PUERTO B   BIT 1  COMO OUTPUT
            mov    #$02,PTBD	;BIT 1 DEL PUERTO B EN HIGHT
                        
			

mainLoop:
            
            brclr  2,PTAD,boton ;PREGUNTA SI EL BIT 2 DEL PUERTO A ESTA EN BAJO, SI EVALUA A VERDAD PASA A LA RUTINA BOTON
            mov    #$02,PTBD	;BIT 2 DEL PUERTO B EN HIGHT
            feed_watchdog
            BRA    mainLoop		;RETORNA A LA RUTINA MAINLOOP
            
boton: 		
			mov    #$00,PTBD	;BIT 2 DEL PUERTO B EN LOW (DE HECHO TODOS LOS BITS DEL PUERTO B SE APAGAN) 
			bra    mainLoop 	;RETORNA A LA RUTINA MAINLOOP

