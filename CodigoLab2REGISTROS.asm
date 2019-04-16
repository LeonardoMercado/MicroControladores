;********************************************************************************************
;* UNIVERSIDAD NACIONAL DE COLOMBIA SEDE BOGOTÁ - DEP MECÁNICA Y MECATRÓNICA.
;********************************************************************************************
;*
;* Title: Código para la implementación del laboratorío #2 de microcontroladores Unal 2019-I
;*
;* Author: Maria Alejandra Arias Torres, Leonardo Fabio Mercado Benítez.
;*
;* Description: Se implementa el código enviado y se verifica el funcionamiento linea a linea
;*
;* Documentation: Guía GQ8 Cap 7
;*
;* Include Files: Ninguno
;*
;* Revision History:
;
;* Rev #      Date           Who             Comments
;* ----- ------------ ------------------- --------------------------------------------
;* 1.0    15-Apr-2019 Leonardo M. Benítez  Se examina cada linea del código y se comenta su acción sobre los registros
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
            LDHX   #__SEG_END_SSTACK ; Se cargan los registros indices H y X con el numero que se
            						 ; encuentre en __SEG_END_SSTACK  H = 0X01 y X = 0X40
            TXS						 ; Transfiere lo que haya en (H:X-1) al STACK 
			lda    #$02				 ; Carga el acumulador A con un 2
			sta    SOPT1             ;Almacena lo que hay en el acumulador en 0x1802

mainLoop:
            
            lda    #$ff      		 ;Carga el Acumulador A con Hex FF y modifica el CCR de 0x68 a 0x6c

rt1: 
			psha					 ;Resta en 1 lo que halla en el STACK
			lda    #$ff

rt2: 		
			dbnza  rt2				 ;Decrementa el Acumulador en 1, hasta que sea 0 y salta a la rutina
			pula					 ;Lo que halla en la pila le suma 1 y el acumulador lo manda a 0xfd
			dbnza  rt1				 ;Incrementa la pila en 1 
			BRA  mainLoop


