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
;*Descripción:  encendido LED cada 2.5s                                    *
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

cont1:     ds.b  1                   ; variable de nombre cont1 de 2 bytes

; code section

MyCode:      SECTION


main:
_Startup:
            LDHX  #__SEG_END_SSTACK  ; initialize the stack pointer
            TXS
            lda   #$02               ; cargar hex 02 en acumulador
            sta   SOPT1              ; desactivar watchdog
            mov   #$02,PTBDD         ; puerto B bit2 como salida
            
mainLoop:   
            lda   #$11               ; cargar hex 11 en acumulador
            sta   cont1              ; cont1=17(dec)
            lda   #$08               ; cargar hex 8 en acumulador
            CMP   PTBD               ; comparar valor en pto B con acumulador
            blt   next               ; branch a next si dato en pto B < 8
            mov   #$02,PTBD          ; bit 2 del puerto B en 1 lógico (reiniciar recorido RGB)        

rt3:        
            lda   #$ff               ; cargar hex FF en acumulador                               
rt1:
            psha                     ; guardar acumulador en el stack         (2 ciclos)*rt1(256)
            lda   #$f                ; cargar dec 15 en acumulador            (2 ciclos)*rt1(256)
rt2:
            dbnza rt2                ; decrementar acumulador, branch a rt2 si acumulador != 0 (4 ciclos)*rt2(15)
            pula                     ; tomar del stack y asignar al acumulador                 (3 ciclos)*rt1(256)
            dbnza rt1                ; decrementar acumulador, branch a rt1 si acumulador != 0 (4 ciclos)*rt1(256)
            dbnz  cont1,rt3          ; decrementar cont1, branch a rt3 si cont1 != 0           (7 ciclos)*rt3(17)
            bra   mainLoop           ; branch a mainloop                                       
            
next:
            lsl   PTBD               ; corrimiento lógico a la izquierda en pto B (encender siguiente led)
            bra   rt3                ; branch a rt3
  
