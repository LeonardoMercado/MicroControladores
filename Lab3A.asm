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
;* 1.3	 02-may-2019 Leonardo M. Benpitez Se implementa el debugger de la etiqueta antirrebote
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
MY_ZEROPAGE: SECTION  SHORT         ;seccion de la pagina zero de la RAM
btnst0:   dc.b  1                    ;variable para estado de boton
btnst1:   dc.b  1 
btnst2:   dc.b  1 
; code section
MyCode:     SECTION
main:
_Startup:
            LDHX   #__SEG_END_SSTACK ; initialize the stack pointer
            TXS
            lda   #$02              ;desactivar watchdog, dejar modo BKGD enabled
            sta   SOPT1             ;BKGD jamas disabled
            mov   #%11111000,PTADD  ;puerto A bit 0, 1 y 2 como input
            lda   #$07              ;cargar hex 07 Bin 0000|0111 en acumulador
            sta   PTAPE             ;habilitar pull-up en pin 0, 1 y 2 de PTA
                                    ;puerto en estado natural en 1 logico
                                    ;boton presionado lo pone en 0 logico
            mov   #$01,btnst0       ;dar un estado inicial a variable de boton0
            mov   #$01,btnst1       ;dar un estado inicial a variable de boton1
            mov   #$01,btnst2       ;dar un estado inicial a variable de boton2
            mov   #%00000111,PTBDD  ;puerto B bit 0, 1 y 2 como output
            mov   #%00000111,PTBD   ;bit 0, 1 y 2 del puerto B en 1 logico
            
mainLoop:   
            brclr 0,PTAD,boton0     ;pregunta si boton esta presionado, osea bit en 0, 
                                    ;dado el caso salta a rutina boton
            brclr 1,PTAD,boton1
            
            brclr 2,PTAD,boton2    
                                    
            BRA    mainLoop
            
;_________________________________________________________________________________________________________________________
;*RUTINA DE ANTIREBOTE PARA EL BOTON0            
boton0:
            mov   #%00000110,btnst0       ;atualizar variable estado boton.
            lda   PTBD              ;cargar estado actual del puerto B en acumulador.
            eor   #%00000001        ;operación XOR entre el acumulador y el numero indicado
                                    ;hacer esta operación con ese bit en especifico resulta en alternar el bit
                                    ;correspondiente, resultado se guarda en el acumulador.
            sta   PTBD              ;guardar en PTBD lo presente en el acumulador
still0:
            lda   PTAD              ;cargar el estado actual del puerto A
            cbeq  btnst0,still0       ;compare el acumulador con btnst, branch if equal a etiqueta still
                                    ;haciendo esta comparacion le decimos a el MCU que espere a que dejemos de
                                    ;pulsar el boton para continuar y asi completar la acción de alternar el estado
                                    ;del puerto o del LED en este caso
            nop                     ;no operation para tener una pequqeña pausa
            bra   mainLoop          ;devuelta al mainLoop.
;_________________________________________________________________________________________________________________________

;_________________________________________________________________________________________________________________________
;*RUTINA DE ANTIREBOTE PARA EL BOTON1            
boton1:
            mov   #%00000101,btnst1        ;atualizar variable estado boton.
            lda   PTBD              ;cargar estado actual del puerto B en acumulador.
            eor   #%00000010        ;operación XOR entre el acumulador y el numero indicado
                                    ;hacer esta operación con ese bit en especifico resulta en alternar el bit
                                    ;correspondiente, resultado se guarda en el acumulador.
            sta   PTBD              ;guardar en PTBD lo presente en el acumulador
still1:
            lda   PTAD              ;cargar el estado actual del puerto A
            cbeq  btnst1,still1     ;compare el acumulador con btnst, branch if equal a etiqueta still
                                    ;haciendo esta comparacion le decimos a el MCU que espere a que dejemos de
                                    ;pulsar el boton para continuar y asi completar la acción de alternar el estado
                                    ;del puerto o del LED en este caso
            nop                     ;no operation para tener una pequqeña pausa
            bra   mainLoop          ;devuelta al mainLoop.
;_________________________________________________________________________________________________________________________

;_________________________________________________________________________________________________________________________
;*RUTINA DE ANTIREBOTE PARA EL BOTON2            
boton2:
            mov   #%00000011,btnst2        ;atualizar variable estado boton.
            lda   PTBD              ;cargar estado actual del puerto B en acumulador.
            eor   #%00000100        ;operación XOR entre el acumulador y el numero indicado
                                    ;hacer esta operación con ese bit en especifico resulta en alternar el bit
                                    ;correspondiente, resultado se guarda en el acumulador.
            sta   PTBD              ;guardar en PTBD lo presente en el acumulador
still2:
            lda   PTAD              ;cargar el estado actual del puerto A
            cbeq  btnst2,still2       ;compare el acumulador con btnst, branch if equal a etiqueta still
                                    ;haciendo esta comparacion le decimos a el MCU que espere a que dejemos de
                                    ;pulsar el boton para continuar y asi completar la acción de alternar el estado
                                    ;del puerto o del LED en este caso
            nop                     ;no operation para tener una pequqeña pausa
            bra   mainLoop          ;devuelta al mainLoop.
;_________________________________________________________________________________________________________________________
