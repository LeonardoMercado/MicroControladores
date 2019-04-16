;****************************************************************************
;*UNIVERSIDAD NACIONAL DE COLOMBIA - FACULTAD DE INGENIERÍA - SEDE BOGOTÁ   *
;****************************************************************************
;*Departamento de Ingeniería Mecánica y Mecatrónoca  -  Microcontroladores  *
;*Primer Semestre 2019                                                      *
;****************************************************************************
;*Fecha: 15/04/2019                                                         *
;*                                                                          *
;*Autores: Alejandra Arias Torres                                           *
;*         Leonardo Fabio Mercado                                           *
;*                                                                          *
;*Descripción:  Uso de retardos                                             *
;*                                                                          *
;*Documentación:  Hoja de datos para MCU QG8 NXP                            *
;*                                                                          *
;*Archivos Adicionales:                                                     *
;*                                                                          *
;*Versión 1.0 realizada en CodeWarrior (Eclipse) V11                        *
;****************************************************************************

; Include derivative-specific definitions
            INCLUDE 'derivative.inc'
;           INCLUDE 'macros.inc' 

; export symbols
            XDEF _Startup, main
            ; we export both '_Startup' and 'main' as symbols. Either can
            ; be referenced in the linker .prm file or from C/C++ later on
                                    
            XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack

; variable/data section
MY_ZEROPAGE: SECTION  SHORT         ; Sección para definición de variables en la RAM, página cero

; code section
MyCode:      SECTION
main:
_Startup:
            LDHX  #__SEG_END_SSTACK ; cargar la dirección del final del stack a H:X
            TXS                     ; SP apunta a H:X-1 (inicializar SP)
            lda   #$02              ; cargar hex 02 en acumulador
            sta   SOPT1             ; activar background debug mode
mainLoop:
            lda   #$ff              ; cargar hex FF en acumulador
rt1:
            psha                    ; guardar acumulador en el stack
            lda   #$ff              ; cargar hex FF en acumulador
rt2:
            dbnza rt2               ; decrementar acumulador, branch a rt2 si acumulador != 0
            pula                    ; Almacenar en el acumulador el dato tomado del stack
            dbnza rt1               ; decrementar acumulador, branch a rt1 si acumulador != 0
            bra   mainLoop          ; branch a mainLoop
