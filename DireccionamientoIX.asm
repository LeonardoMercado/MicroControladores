;*******************************************************************
;* This stationery serves as the framework for a user application. *
;* For a more comprehensive program that demonstrates the more     *
;* advanced functionality of this processor, please see the        *
;* demonstration applications, located in the examples             *
;* subdirectory of the "Freescale CodeWarrior for HC08" program    *
;* directory.                                                      *
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
salida:     DC.B    1 
pisoact:    DC.B    1
pisodest:   DC.B    1
; code section

ROM_VAR: SECTION                    ; Insert here your data definition
nums:    DC.B $00,$10,$20,$30,$40   ; Datos display

MyCode:     SECTION
main:
_Startup:
            LDHX   #__SEG_END_SSTACK ; initialize the stack pointer
            TXS
			CLI			; enable interrupts
			lda   #$01
			sta   pisoact
			lda   #$03
			sta   pisodest

mainLoop:
            ; Insert your code here
            clrx
            clrh
            ldhx   #nums
            txa
            add    pisodest
            tax
            ;sthx 
            lda    #$00  
            add    ,x        

sumar:
            lda    pisoact
            inca
            sta    pisoact
            BRA    mainLoop
salir:
            lda   salida
            inca
            sta   salida
            BRA    mainLoop
restar:
            lda    pisoact
            deca
            sta    pisoact
            BRA    mainLoop                        
          
            


