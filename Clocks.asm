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
            XDEF _Startup, main, MTIM_ISR
            ; we export both '_Startup' and 'main' as symbols. Either can
            ; be referenced in the linker .prm file or from C/C++ later on
            
            
            
            XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack


; variable/data section
MY_ZEROPAGE: SECTION  SHORT         ; Insert here your data definition
var:   ds.b   1
  
ROM_VAR:     SECTION
limite:   dc.b  62
; code section
MyCode:     SECTION
main:
_Startup:

            LDHX   #__SEG_END_SSTACK ; initialize the stack pointer
            TXS            
            lda    #$02               ; cargar hex 02 en acumulador
            sta    SOPT1              ; desactivar watchdog
            lda    #%00000100
			sta    ICSC1
			lda    #%11000000
			sta    ICSC2		
			CLI	   ;enable interrupts
			mov    #$01,PTBDD         ; puerto B bit0 como salida
			mov    #$01,PTBD          ; puerto B bit0 en 1
mtim_cfg:
			lda    #%00001000
			sta    MTIMCLK
			lda    #$7e
			sta    MTIMMOD
			lda    #%01100000
			sta    MTIMSC

mainLoop:   ; Insert your code here
            NOP 
            WAIT
            inc    var
            lda    limite            
            cbeq   var,led_toggle    
            BRA    mainLoop

led_toggle:
            lda    #$00
            sta    var
            lda    PTBD
            eor    #$01
            sta    PTBD
            BRA    mainLoop

MTIM_ISR:
            bset     5,MTIMSC
            rti
