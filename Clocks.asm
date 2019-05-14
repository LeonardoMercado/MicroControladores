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
limite:   dc.b  62                  ;variable para contar interrupciones f=31.002/62=0.5Hz   T=2*(1/f)=4s
; code section
MyCode:     SECTION
main:
_Startup:

            LDHX   #__SEG_END_SSTACK ; initialize the stack pointer
            TXS            
            lda    #$02               ; cargar hex 02 en acumulador
            sta    SOPT1              ; desactivar watchdog
            lda    #%00000100
			sta    ICSC1              ;Fuente de reloj interno f=31.25kHz (RDIV=1)
			lda    #%11000000  
			sta    ICSC2		      ;Divisor de freq bus 31.25*512/8*2=1000kHz
			CLI	   ;enable interrupts 
			mov    #$01,PTBDD         ; puerto B bit0 como salida
			mov    #$01,PTBD          ; puerto B bit0 en 1
mtim_cfg:
			lda    #%00001000         ; bit 5=0 frecuencia de bus de bus , PS=1000  divisor 256 f=3906.25
			sta    MTIMCLK
			lda    #$7e
			sta    MTIMMOD            ; contador en 126 f=3906.25/126=31.002 Hz 
			lda    #%01100000
			sta    MTIMSC             ; enable MTIM interrupt (bit 6), Counter reset (bit 5)

mainLoop:   ; Insert your code here
            NOP 
            WAIT
            inc    var               ;incrementar el contador de interrupciones
            lda    limite            ;comparar con el límite de interrupciones
            cbeq   var,led_toggle    ;cambiar estado de led si var llega al límite
            BRA    mainLoop

led_toggle:
            lda    #$00
            sta    var               ; reiniciar conteo de interrupciones
            lda    PTBD
            eor    #$01              ;cambiar estado del led
            sta    PTBD
            BRA    mainLoop

MTIM_ISR:
            bset   5,MTIMSC        ; reiniciar el contador del MTIM
            rti
