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
            XDEF _Startup, main, KBI_ISR, IRQ_ISR, RTI_ISR
            ; we export both '_Startup' and 'main' as symbols. Either can
            ; be referenced in the linker .prm file or from C/C++ later on
            
            
            
            XREF __SEG_END_SSTACK    ; symbol defined by the linker for the end of the stack


; variable/data section
MY_ZEROPAGE: SECTION  SHORT           ; Insert here your data definition

cont1:       ds.b    1                ; variable contador para retardo
pisoAct:     ds.b    1                ; Piso actual del ascensor
pisoDest:    ds.b    1                ; Piso de destino del ascensor

; constant/data section
ROM_VAR:   section
 
nums:        DC.B $00,$10,$20,$30,$40   ; Datos display
leds:        DC.B $00,$01,$02,$04,$08   ; Datos  leds

; code section
MyCode:     SECTION
main:
_Startup:
            LDHX   #__SEG_END_SSTACK ;initialize the stack pointer
            TXS
			CLI			             ;enable interrupts
            lda   #$02
            sta   SOPT1              ;deshabilitar watchdog
            lda   #$01
            sta   pisoAct            ;Inicializar piso actual en 1
            sta   pisoDest           ;Inicializar piso destino en 1
            mov   #$ff, PTBDD        ;todos los bits del PTB como salida
            mov   #%00010001, PTBD   ;iniciar en piso 1 7seg [7:4] y leds[3:0]  
            bset  3,PTADD            ;puerto A bit 3 como salida (alarma)            
            
;Configurar interrupción por KBI (up,down)
kbi_cfg:                            
            lda   #%00000011        ;PTA Pull Enable
            sta   PTAPE             ;activar resistencias internas de Pull-up
            
            lda   #%00000000        ;KBI Edge Select
            sta   KBIES             ;interrupción por flanco de bajada en las entradas KBI
            
            lda   #%00000011        ;KBI Pin Enable
            sta   KBIPE             ;habilitacion solo de pines 0,1 como fuentes de KBI (up,down)
            
            ;KBI Status and Control
            bset  2,KBISC           ;1 en KBACK (acknowledge) para evitar falsas interrupciones antes de iniciar el modulo
            bclr  0,KBISC           ;0 en KBMOD para generar interrupcion solo por flancos
            bset  1,KBISC           ;1 en KBIE para activar las interrupciones por KBI
            
;configuracion interrupción por IRQ (play)
irq_cfg:
            mov   #%00010010,IRQSC  ;configuracion registro IRQ Status and Control
                   ; | |||||________IRMOD, interrupción generada solo por flanco de bajada
                   ; | ||||_________IRQIE, habilitar interrupcion por IRQ
                   ; | |||__________IRQACK, acknowledge de interrucpión, para limpiar bandera IRQF
                   ; | ||___________IRQF, bit de solo lectura, bandera que indica cuando ocurre un evento IRQ
                   ; | |____________IRQPE, habilitar la función IRQ en el pin designado, pin 1 en el QG8
                   ; |
                   ; |______________IRQPDD, pull-up del pin habilitado por defecto cuando IRQPE es 1
                   
mainLoop:
            
            NOP                     ; ejecución normal del programa
            NOP 
            bclr  3,PTAD            ;apagar alarma
            BRA   mainLoop
            
;interrupción up and down
KBI_ISR:                            
            bset  2,KBISC           ;limpiar bandera al poner en 1 el bit, acknowledge interrupcion
                                    ;para permitir alguna interrupción futura
            brclr 0,PTAD,inc_dest   ;interrupción generada por boton up
            brclr 1,PTAD,dec_dest   ;interrupción generada por boton down
            rti
            
inc_dest:   ;incrementar destino
            lda   pisoDest         
            cmp   #$04              ;comparar destino con valor 4
            beq   salir_KBI         ;no ejecutar ninguna acción si el destino es 4
            inca                    
            sta   pisoDest          ;incrementar destino en 1
            bra   act_dest          ;ir a rutina actualizar destino            

dec_dest:   ;decrementar destino
            lda   pisoDest         
            cmp   #$01              ;comparar destino con valor 1
            beq   salir_KBI         ;no ejecutar ninguna acción si el destino es 1
            deca                    
            sta   pisoDest          ;decrementar destino en 1 
            bra   act_dest          ;ir a rutina actualizar destino

act_dest:   ;actualizar destino en display 
            clrx
            clrh
            ldhx   #nums            ;apuntar a arreglo de números del display  
            txa                     ;transferir valor de X a A
            add    pisoDest         ;apuntar a pisción del nuevo dato para el display            
            tax                     ;transferir valor de A a X (almacenar la posición de memoria del nuevo destino)
            lda    #$00   
            add    ,x               ;tomar el valor del número a mostrar en el display
            add    pisoAct          ;concatenar los valores de piso destino y piso actual
            sta    PTBD             ;Mostrar nuevo piso destino en 7seg
            rti   
            
salir_KBI:
            rti            
            
;interrupción play            
IRQ_ISR:                      
            bset  2,IRQSC           ;limpiar bandera al poner en 1 el bit, acknowledge interrupcion
                                    ;para permitir alguna interrupción futura
            bra   comparar                    
            rti

comparar:   
            lda   pisoAct
            cmp   pisoDest          ;comparar piso actual con piso de destino            
            blt   inc_act           ;subir un piso si actual menor a destino(branch if less than)
            bgt   dec_act           ;bajar un piso si actual mayor a destino(branch if grater than)
            beq   salir_IRQ         ;salir de interrupción si destino = actual (branch if equal)
                        
inc_act:    ;incrementar piso actual

            inc    pisoAct          ;incrementar en 1 piso actual
            bra    act_piso        
             
            
dec_act:    ;decrementar piso actual
                  
            dec   pisoAct          ;decrementar en 1 piso actual            
            bra    act_piso          

act_piso:   ;actualizar piso actual

            clrx
            clrh                    ;limpiar registro H:X
            ldhx   #leds            ;cargar dirección de memoria de la variable leds en H:X
            txa                     ;transferir X al acumulador
            add    pisoAct          ;desplazarse en la memoria a la dirección del dato para los leds
            tax                     ;apuntar con H:X al piso siguiente 
            lda    #$00             
            add    ,x               ;almacenar valor a mostrar en leds
            nsa                     
            add    pisoDest         ;almacenar valor para 7seg
            nsa                     ;(Nibble Swap)intercambiar posición de datos para leds y 7seg
            sta   PTBD              ;Mostrar nuevo piso actual en leds durante retardo
            bra   retardo
             
                           
retardo:        
            lda   #$10         ; cargar hex 16 en acumulador  [IMM]
            sta   cont1             ; cont1=16(dec) (1 segundo)  [DIR]  
rt3:        
            lda   #$ff         ; cargar hex FF en acumulador     [IMM]  (2 ciclos)*rt3(16)                   
rt1:
            psha                    ; guardar acumulador en el stack  [INH]  (2 ciclos)*rt1(256)
            lda   #$ff ;#$02   ; cargar hex ff en acumulador     [IMM]  (2 ciclos)*rt1(256)
rt2:
            dbnza rt2               ; decrementar acum, branch a rt2 si acum!= 0    [INH]  (4 ciclos)*rt2(256)
            pula                    ; tomar del stack y asignar al acumulador       [INH]  (3 ciclos)*rt1(256)
            dbnza rt1               ; decrementar acum, branch a rt1 si acum != 0   [INH]  (4 ciclos)*rt1(256)
            dbnz  cont1,rt3         ; decrementar cont1, branch a rt3 si cont1 != 0 [DIR]  (7 ciclos)*rt3(16)
            bra   comparar          ; revisar si llegó al piso de destino 
 
salir_IRQ:  
            ;bset  3,PTAD           ; encender alarma
            bra   RTI_cfg           ; Configurar interrupción por RTI
            rti           
                                  
;interrupción alarma

RTI_cfg:
            lda   #%00010111
                   ;|||| |||________RTIS, arreglo de 3 bits para seleccionar el tiempo entre interrupcion,
                   ;|||| ||_________usando un reloj interno dedicado de 1khz,
                   ;|||| |__________111 para interrupción cada 1.024 segundos (segun tabla datasheet)
                   ;||||
                   ;||||____________RTIE, habilitar interrupcion por RTI
                   ;|||_____________RTICLKS, seleccion clock fuente de RTI, 0 para seleccionar reloj 1 khz dedicado
                   ;||______________RTIACK, acknowledge de interrucpión, para limpiar bandera RTIF
                   ;|_______________RTIF, bit de solo lectura, bandera que indica cuando ocurre un evento RTI
            sta   SRTISC            ;System Real Time Interrupt Status and Control
            rti            
RTI_ISR:    
            lda   #%01000000        ;limpiar bandera al poner en 1 el bit, acknowledge interrupcion  
            bset  3,PTAD            ;encender alarma               
            rti

            
            
