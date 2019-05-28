;****************************************************************************
;*UNIVERSIDAD NACIONAL DE COLOMBIA - FACULTAD DE INGENIER�A - SEDE BOGOT�   *
;****************************************************************************
;*Departamento de Ingenier�a Mec�nica y Mecatr�noca  -  Microcontroladores  *
;*Primer Semestre 2019                                                      *
;****************************************************************************
;*Fecha: 15/04/2019                                                         *
;*                                                                          *
;*Autores: Alejandra Arias Torres                                           *
;*         Leonardo Fabio Mercado                                           *
;*                                                                          *
;*Descripci�n:  encendido LED cada 2.5s                                    *
;*                                                                          *
;*Documentaci�n:  Hoja de datos para MCU QG8 NXP                            *
;*                                                                          *
;*Archivos Adicionales:                                                     *
;*                                                                          *
;*Versi�n 1.0 realizada en CodeWarrior (Eclipse) V11                        *
;*Versi�n 1.1 ajuste retardos y cambio de estado LED                        *
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
MY_ZEROPAGE: SECTION  SHORT         ; Secci�n para definici�n de variables en la RAM, p�gina cero

cont1:     ds.b  2                   ; variable de nombre cont1 de 2 bytes


VAR_ROM:   section
const       dc.b    10

; code section

MyCode:      SECTION


main:
_Startup:
            LDHX  #__SEG_END_SSTACK  ; initialize the stack pointer [IMM]
            TXS                      ; [INH]
            lda   #$02               ; cargar hex 02 en acumulador [IMM]
            sta   SOPT1              ; desactivar watchdog [EXT]
            mov   #$07,PTBDD         ; puerto B bit 0-1-2 como salida [IMM/DIR]
            mov   #$01,PTBD          ; bit 1 del puerto B en alto (iniciar recorido RGB) [IMM/DIR]
  
            
mainLoop:   
            mov   #%00000001,PTBD         ;bit1 del puerto B en 1 logico
            jsr   rt4                 ;salto a subrutina de retardo
            mov   #%00000010,PTBD         ;bit2 del puerto B en 1 logico
            jsr   rt4                 ;salto a subrutina de retardo
            mov   #%00000100,PTBD         ;bit3 del puerto B en 1 logico            
          
rt4:        
            lda   #$10               ; cargar hex en acumulador  [IMM]
            sta   cont1              ; cont1=16(dec) (1 segundo)  [DIR]  
rt3:        
            lda   #$ff               ; cargar hex FF en acumulador     [IMM]  (2 ciclos)*rt3(77)                   
rt1:
            psha                     ; guardar acumulador en el stack  [INH]  (2 ciclos)*rt1(256)
            lda   #$ff                ; cargar dec 15 en acumulador    [IMM]  (2 ciclos)*rt1(256)
rt2:
            dbnza rt2                ; decrementar acum, branch a rt2 si acum!= 0    [INH]  (4 ciclos)*rt2(256)
            pula                     ; tomar del stack y asignar al acumulador       [INH]  (3 ciclos)*rt1(256)
            dbnza rt1                ; decrementar acum, branch a rt1 si acum != 0   [INH]  (4 ciclos)*rt1(256)
            dbnz  cont1,rt3          ; decrementar cont1, branch a rt3 si cont1 != 0 [DIR]  (7 ciclos)*rt3(77)
            rts                      ; return form subroutine                                 
            

  
