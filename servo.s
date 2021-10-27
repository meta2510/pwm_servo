;-----------------------PUERTO F--------------------------------------	
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
	
GPIO_PORTF_LOCK_R  EQU 0x40025520
GPIO_PORTF_CR_R    EQU 0x40025524
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
GPIO_LOCK_KEY      EQU 0x4C4F434B  ; Unlocks the GPIO_CR register
;-----------------------PUERTO E-------------------------------------
GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_AFSEL_R EQU 0x40024420
GPIO_PORTE_PUR_R   EQU 0x40024510
GPIO_PORTE_DEN_R   EQU 0x4002451C
GPIO_PORTE_LOCK_R  EQU 0x40024520
GPIO_PORTE_CR_R    EQU 0x40024524
GPIO_PORTE_AMSEL_R EQU 0x40024528
GPIO_PORTE_PCTL_R  EQU 0x4002452C

;-----------------------PUERTO A--------------------------------------	
GPIO_PORTA_DATA_R  EQU 0x400043FC
GPIO_PORTA_DIR_R   EQU 0x40004400
GPIO_PORTA_AFSEL_R EQU 0x40004420
GPIO_PORTA_PUR_R   EQU 0x40004510
GPIO_PORTA_DEN_R   EQU 0x4000451C
GPIO_PORTA_LOCK_R  EQU 0x40004520
GPIO_PORTA_CR_R    EQU 0x40004524
GPIO_PORTA_AMSEL_R EQU 0x40004528
GPIO_PORTA_PCTL_R  EQU 0x4000452C

;-----------------------PUERTO D--------------------------------------
GPIO_PORTD_DATA_R  EQU 0x400073FC
GPIO_PORTD_DIR_R   EQU 0x40007400
GPIO_PORTD_AFSEL_R EQU 0x40007420
GPIO_PORTD_DR8R_R  EQU 0x40007508
GPIO_PORTD_DEN_R   EQU 0x4000751C
GPIO_PORTD_AMSEL_R EQU 0x40007528
GPIO_PORTD_PCTL_R  EQU 0x4000752C
SYSCTL_RCGC2_GPIOD EQU 0x00000008
;----------------------------------------------------------------------
SYSCTL_RCGCGPIO_R  EQU   0x400FE608
Cont		EQU 5333333	;%tiempo para el delay 16Mhz/3 = 1 segundo aprox
LEDS               EQU 0x4000703C   ; direccion para los puertos PD3-PD0
Led_Off   EQU 0x00
PA2		EQU 0x04
PA3		EQU 0x08
PA4		EQU 0x10
PA5		EQU 0x20
PA6		EQU 0x40

PE1		EQU 0x02
PE2		EQU 0x04
PE3		EQU 0x08
PE4		EQU 0x10
PE5		EQU 0x20
	
		AREA	codigo, CODE, READONLY, ALIGN=2
		THUMB
		EXPORT Start

Start
		BL  PortF_Init                  ; initialize input and output pins of Port F
		BL PortA_Init 
		BL PortE_Init
		BL PortD_Init
		B Loop

PortF_Init
    LDR R1, =SYSCTL_RCGCGPIO_R      ; 1) activacion del reloj del puerto F
    LDR R0, [R1]                 
    ORR R0, R0, #0x20               ; set bit 5 to turn on clock
    STR R0, [R1]                  
    NOP
    NOP   
	; allow time for clock to finish
    LDR R1, =GPIO_PORTF_LOCK_R      ; 2) direccion para desbloquear el registro
    LDR R0, =0x4C4F434B             ; unlock GPIO Port F Commit Register
    STR R0, [R1]  
	
    LDR R1, =GPIO_PORTF_CR_R        ; enable commit for Port F
    MOV R0, #0xFF                   ; 1 means allow access
    STR R0, [R1]  
	
    LDR R1, =GPIO_PORTF_AMSEL_R     ; 3) disable analog functionality
    MOV R0, #0                      ; 0 means analog is off
    STR R0, [R1]
	
    LDR R1, =GPIO_PORTF_PCTL_R      ; 4) configure as GPIO
    MOV R0, #0x00000000             ; 0 means configure Port F as GPIO
    STR R0, [R1]  
	
    LDR R1, =GPIO_PORTF_DIR_R       ; 5) set direction register
    MOV R0,#0x0E                    ; PF0 and PF7-4 input, PF3-1 output
    STR R0, [R1] 
	
    LDR R1, =GPIO_PORTF_AFSEL_R     ; 6) regular port function
    MOV R0, #0   	; 0 means disable alternate function 
    STR R0, [R1]  
	
    LDR R1, =GPIO_PORTF_PUR_R       ; pull-up resistors for PF4,PF0
    MOV R0, #0x11                   ; enable weak pull-up on PF0 and PF4
    STR R0, [R1]  
	
    LDR R1, =GPIO_PORTF_DEN_R       ; 7) enable Port F digital port
    MOV R0, #0xFF                   ; 1 means enable digital I/O
    STR R0, [R1] 
	
    BX  LR 

;------------Switch_Init------------
; Initialize GPIO Port A bit 5 as input
; Input: none
; Output: none
; Modifies: R0, R1
PortA_Init
    LDR R1, =SYSCTL_RCGCGPIO_R         ; 1) activate clock for Port A
    LDR R0, [R1]                 
    ORR R0, R0, #0x01               ; set bit 0 to turn on clock
    STR R0, [R1]                  
    NOP
    NOP                             ; allow time for clock to finish
                                    ; 2) no need to unlock Port A                 
    LDR R1, =GPIO_PORTA_AMSEL_R     ; 3) disable analog functionality
    LDR R0, [R1]                    
	MOV R0, #0                      ; 0 means analog is off
    STR R0, [R1]
	
    LDR R1, =GPIO_PORTA_PCTL_R      ; 4) configure as GPIO
    LDR R0, [R1]                    
    MOV R0, #0x00000000             ; 0 means configure Port A as GPIO
    STR R0, [R1]
	
    LDR R1, =GPIO_PORTA_DIR_R       ; 5) set direction register
    LDR R0, [R1]                    
    MOV R0,#0xFF                    ; PA como salida todos sus puertos  11111111 / 1 es salida 0 entrada
    STR R0, [R1] 
	
    LDR R1, =GPIO_PORTA_AFSEL_R     ; 6) regular port function
    LDR R0, [R1]                    
    MOV R0, #0   	; 0 means disable alternate function 
    STR R0, [R1] 
	
    LDR R1, =GPIO_PORTA_DEN_R       ; 7) enable Port A digital port
    LDR R0, [R1]                    
    MOV R0, #0xFF                   ; 1 means enable digital I/O
    STR R0, [R1] 
    BX  LR    
	
PortE_Init	
    LDR R1, =SYSCTL_RCGCGPIO_R         ; 1) activate clock for Port A
    LDR R0, [R1]                 
    ORR R0, R0, #0x10               ; set bit 4 to turn on clock
    STR R0, [R1]                  
    NOP
    NOP                             ; allow time for clock to finish
                                   ; 2) no need to unlock Port A                 
    LDR R1, =GPIO_PORTE_AMSEL_R     ; 3) disable analog functionality
    LDR R0, [R1]                    
	MOV R0, #0                      ; 0 means analog is off
    STR R0, [R1]
	
    LDR R1, =GPIO_PORTE_PCTL_R      ; 4) configure as GPIO
    LDR R0, [R1]                    
    MOV R0, #0x00000000             ; 0 means configure Port A as GPIO
    STR R0, [R1]
	
    LDR R1, =GPIO_PORTE_DIR_R       ; 5) set direction register
    LDR R0, [R1]                    
    MOV R0,#0x3F                    ; PE como salida todos sus puertos  111111 / 1 es salida 0 entrada
    STR R0, [R1] 
	
    LDR R1, =GPIO_PORTE_AFSEL_R     ; 6) regular port function
    LDR R0, [R1]                    
    MOV R0, #0   	; 0 means disable alternate function 
    STR R0, [R1] 
	
    LDR R1, =GPIO_PORTE_DEN_R       ; 7) enable Port A digital port
    LDR R0, [R1]                    
    MOV R0, #0x3F                   ; 1 means enable digital I/O
    STR R0, [R1] 
    BX  LR

PortD_Init
    ; 1) activate clock for Port D
    LDR R1, =SYSCTL_RCGCGPIO_R      ; R1 = &SYSCTL_RCGCGPIO_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #SYSCTL_RCGC2_GPIOD ; R0 = R0|SYSCTL_RCGC2_GPIOD
    STR R0, [R1]                    ; [R1] = R0
    NOP
    NOP                             ; 
    ; 2) no need to unlock PD3-0
    ; 3) disable analog functionality
    LDR R1, =GPIO_PORTD_AMSEL_R     ; R1 = &GPIO_PORTD_AMSEL_R
    LDR R0, [R1]                    ; R0 = [R1]
    BIC R0, R0, #0x0F               ; R0 = R0&~0x0F (desactiva funcioinalidades analogas en PD3-0)
    STR R0, [R1]                    ; [R1] = R0    
    ; 4) configure as GPIO
    LDR R1, =GPIO_PORTD_PCTL_R      ; R1 = &GPIO_PORTD_PCTL_R
    LDR R0, [R1]                    ; R0 = [R1]
    MOV R2, #0x0000FFFF             ; R2 = 0x0000FFFF
    BIC R0, R0, R2                  ; R0 = R0&~0x0000FFFF 
    STR R0, [R1]                    ; [R1] = R0

    ; 5) set direction register
    LDR R1, =GPIO_PORTD_DIR_R       ; R1 = &GPIO_PORTD_DIR_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x0F               ; R0 = R0|0x0F (hace el puerto PD3-0 como salida) 00001111 / 1 es salida 0 es entrada
    STR R0, [R1]                    ; [R1] = R0
    ; 6) regular port function
    LDR R1, =GPIO_PORTD_AFSEL_R     ; R1 = &GPIO_PORTD_AFSEL_R
    LDR R0, [R1]                    ; R0 = [R1]
    BIC R0, R0, #0x0F               ; R0 = R0&~0x0F (desactiva funciones alternativas en PD3-0)
    STR R0, [R1]                    ; [R1] = R0
    ; 
;    LDR R1, =GPIO_PORTD_DR8R_R      ; R1 = &GPIO_PORTD_DR8R_R
;    LDR R0, [R1]                    ; R0 = [R1]
;    ORR R0, R0, #0x0F               ; R0 = R0|0x0F (activa la salida de 8mA en PD3-0)
;    STR R0, [R1]                    ; [R1] = R0
    ; 7) enable digital port
    LDR R1, =GPIO_PORTD_DEN_R       ; R1 = &GPIO_PORTD_DEN_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x0F               ; R0 = R0|0x0F (activa funciones digitales I/O on PD3-0)
    STR R0, [R1]                    ; [R1] = R0
    BX  LR

Loop
		LDR R9, =0 ;Conteo de las cajas
		LDR R3, =0
		LDR R8, =1	;contador del tiempo
		LDR R10, =1066666               ; R0 = FIFTHSEC (delay de 0.2 segundos)
		BL  delay                       ; delay del al menos (3*R0) ciclos
		BL  PortF_Input                 ; lee todos los switches en el puerto F
		CMP R0, #0x01                   ; R0 == 0x01?
		BEQ sw1pressed                  ; si lo es, switch 1 está presionado

		B Loop

Inicio
		CMP R9, #5
		BEQ.W CajaA_Low
		B sw1pressed

sw1pressed
		ADD R8, #1
		LDR	R1, =LEDS
		MOV R0, #5			; 1001 
		STR	R0, [R1]
		LDR R10, =10555	               	;10000 funciona a 90 grados 5333*2 = 10555 2ms en alto
		BL  delay1                       ; delay del al menos (3*R0) ciclos
		B   delay_off1
		
delay1
		SUB R10, #1	; R10 = R10 - 1 (cont = cont - 1)
		CMP R10, #0	; compara si R10 es 0, si lo es, realiza un return a la siguiente linea
		BNE delay1	; si no es cero regresa a delay a seguir restando
		BX LR

delay_off1
		LDR	R1, =LEDS
		MOV R0, #6			; 0110
		STR	R0, [R1]
		LDR R10, =80000              	; 80000 funciona a 90 grados 5333*18 = 80000 18ms en bajo
		BL  delay1		; delay del al menos (3*R0) ciclos
		CMP R8, #18
		BEQ Reinicio_r8
		B sw1pressed

Reinicio_r8
		LDR R8, =1
		ADD R9, #1
		CMP R9, #1
		BEQ CajaA
		CMP R9, #2
		BEQ CajaA1
		CMP R9, #3
		BEQ CajaA2
		CMP R9, #4
		BEQ CajaA3
		CMP R9, #5
		BEQ CajaA4


sw2pressed
		ADD R8, #1
		LDR	R1, =LEDS
		MOV R0, #5					; 1001
		STR	R0, [R1]
		LDR R10, =5333	               	; 5333333/1000 = 1 mili segundo aprox //5333
		BL  delay                       ; delay del al menos (3*R0) ciclos
		B   delay_off
	

delay_off
		LDR	R1, =LEDS
		MOV R0, #6					; 1001
		STR	R0, [R1]
		LDR R10, =101327              	; 5333 * 19 = 19 mili segundo aprox //101327
		BL  delay		; delay del al menos (3*R0) ciclos
		CMP R8, #20
		BEQ ReinicioR8
		B sw2pressed	
		
ReinicioR8
		LDR R8, =1
		;B Inicio
		ADD R3, #1
		CMP R3, #1
		BEQ CajaB
		CMP R3, #2
		BEQ CajaB1
		CMP R3, #3
		BEQ CajaB2
		CMP R3, #4
		BEQ CajaB3
		CMP R3, #5
		BEQ CajaB4

	
delay
		SUB R10, #1	; R10 = R10 - 1 (cont = cont - 1)
		CMP R10, #0	; compara si R10 es 0, si lo es, realiza un return a la siguiente linea
		BNE delay	; si no es cero regresa a delay a seguir restando
		BX LR

CajaA
		LDR R0, =PA2				;00000100
		LDR R1, =GPIO_PORTA_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =Cont				; 533333
		BL delay
		B sw2pressed
		
CajaA1
		LDR R0, =0x0C				;00001100
		LDR R1, =GPIO_PORTA_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =Cont
		BL delay
		B sw2pressed
		
CajaA2
		LDR R0, =0x1C				;00001100
		LDR R1, =GPIO_PORTA_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =Cont
		BL delay
		B sw2pressed
		
CajaA3
		LDR R0, =0x3C				;00001100
		LDR R1, =GPIO_PORTA_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =Cont
		BL delay
		B sw2pressed
		
CajaA4
		LDR R0, =0x7C				;00001100
		LDR R1, =GPIO_PORTA_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =Cont
		BL delay
		B sw2pressed
		
CajaA_Low
		LDR R0, =Led_Off
		LDR R1, =GPIO_PORTA_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =1
		BL delay
		B CajaB_Low
		
CajaB
		LDR R0, =PE1				;00000010
		LDR R1, =GPIO_PORTE_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =Cont
		BL delay
		B Inicio
		
CajaB1
		LDR R0, =0x06				;00001100
		LDR R1, =GPIO_PORTE_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =Cont
		BL delay
		B Inicio
		
CajaB2
		LDR R0, =0x0E				;00001100
		LDR R1, =GPIO_PORTE_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =Cont
		BL delay
		B Inicio
		
CajaB3
		LDR R0, =0x1E				;00001100
		LDR R1, =GPIO_PORTE_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =Cont
		BL delay
		B Inicio
		
CajaB4
		LDR R0, =0x3E				;00001100
		LDR R1, =GPIO_PORTE_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =Cont
		BL delay
		B Inicio
		
CajaB_Low
		LDR R0, =Led_Off
		LDR R1, =GPIO_PORTE_DATA_R ; puntero al puerto A
		STR R0, [R1]               ; escribe al puerto A
		LDR R10, =1
		BL delay
		B Loop

PortF_Input
    LDR R1, =GPIO_PORTF_DATA_R ; puntero al puerto F
    LDR R0, [R1]               ; lee todo el puerto F
    AND R0,R0,#0x11            ; lee solo los pines PF0 and PF4
    BX  LR  
	
	ALIGN
	END
