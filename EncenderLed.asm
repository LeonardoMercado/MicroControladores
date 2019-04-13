;*******************************************************************
;*UNIVERSIDAD NACIONAL DE COLOMBIA SEDE BOGOTÁ
;*09 DE ABRIL DE 2019 
;*AUTOR: LEONARDO FABIO MERCADO BENITEZ
;*DESCRIPCION: HOLA MUNDO CON LED Y PULSADO
;*DOCUMENTACION: DATASHEET GQ8 CAP 2 
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
            mov	   #$fe,PTADD   ;PUERTO A|BIT 0  COMO INPUT Y TODOS LOS DEMAS COMO OUTPUT
            lda	   #$01			;CARGA HEX 01 EN EL ACULUMADOR (pone en alto el bit menos significativo)
            					;7 6 5 4 3 2 1 0
            					;0 0 0 0 0 0 0 1
            sta    PTAPE 		;ALMACENA LO QUE HAY EN EL ACUMULADOR EN EL PUERTO A, HABILITANDO PULL.UP EN PIN 0 DE PTA
            mov    #$04,PTBDD	;PUERTO B|BIT 2  COMO INPUT Y TODOS LOS DEMAS COMO OUTPUT
            mov    #$04,PTBD	;BIT 2 DEL PUERTO B EN HIGHT
                        
			

mainLoop:
            
            brclr  0,PTAD,boton ;PREGUNTA SI EL BIT 0 DEL PUERTO A ESTA EN BAJO, SI EVALUA A VERDAD PASA A LA RUTINA BOTON
            mov    #$02,PTBD	;BIT 2 DEL PUERTO B EN HIGHT
            feed_watchdog
            BRA    mainLoop		;RETORNA A LA RUTINA MAINLOOP
            
boton: 		
			mov    #$00,PTBD	;MANDA LOW A TODOS LOS BITS DEL PUERTO B
			bra    mainLoop 	;RETORNA A LA RUTINA MAINLOOP


