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
GPIO_LOCK_KEY      EQU 0x4C4F434B  ; Desbloquea el registro GPIO_CR 
	
SYSCTL_RCGCGPIO_R  EQU   0x400FE608
	
;-----------------------PUERTO D--------------------------------------
LEDS               EQU 0x4000703C   ; direccion para los puertos PD3-PD0
GPIO_PORTD_DATA_R  EQU 0x400073FC
GPIO_PORTD_DIR_R   EQU 0x40007400
GPIO_PORTD_AFSEL_R EQU 0x40007420
GPIO_PORTD_DR8R_R  EQU 0x40007508
GPIO_PORTD_DEN_R   EQU 0x4000751C
GPIO_PORTD_AMSEL_R EQU 0x40007528
GPIO_PORTD_PCTL_R  EQU 0x4000752C
SYSCTL_RCGC2_GPIOD EQU 0x00000008   ; 


		AREA	codigo, CODE, READONLY, ALIGN=2
		THUMB
		EXPORT Start
			
Start

		BL PuertoF_Init                  ; initialize input and output pins of Port F
		BL PuertoD_Init		
		B Loop
		
PuertoF_Init
		LDR R1, =SYSCTL_RCGCGPIO_R      ; 1) activacion del reloj del puerto F
		LDR R0, [R1]                 
		ORR R0, R0, #0x20               ; setear el bit 5 para encender el reloj
		STR R0, [R1]                  
		NOP
		NOP   
		; allow time for clock to finish
		LDR R1, =GPIO_PORTF_LOCK_R      ; 2) direccion para desbloquear el registro
		LDR R0, =0x4C4F434B             ; desbloquea el  GPIO Port F Commit Register
		STR R0, [R1]  
	
		LDR R1, =GPIO_PORTF_CR_R        ; habilita el commit para el Port F
		MOV R0, #0xFF                   ; 1 significa permitir acceso 
		STR R0, [R1]  
	
		LDR R1, =GPIO_PORTF_AMSEL_R     ; 3) desactiva funciones analogas
		MOV R0, #0                      ; 0 significa que la funcion analoga está desactivada
		STR R0, [R1]
	
		LDR R1, =GPIO_PORTF_PCTL_R      ; 4) configurarlo como GPIO
		MOV R0, #0x00000000             ; 0 significa configurar el puerto como GPIO
		STR R0, [R1]  
	
		LDR R1, =GPIO_PORTF_DIR_R       ; 5) setea el registro de direccion
		MOV R0,#0x0E                    ; PF0 y PF7-4 entradas, PF3-1 salidas
		STR R0, [R1] 
	
		LDR R1, =GPIO_PORTF_AFSEL_R     ; 6) funciones regulares del puerto
		MOV R0, #0   	; 0 significa desactiva funciones alternas
		STR R0, [R1]  
	
		LDR R1, =GPIO_PORTF_PUR_R       ; resistores pull-up para el PF4,PF0
		MOV R0, #0x11                   ; habilita pull up en PF0 and PF4
		STR R0, [R1]  
	
		LDR R1, =GPIO_PORTF_DEN_R       ; 7) activa el puerto digital Port F
		MOV R0, #0xFF                   ; 1 signfica habilita el puerto digital I/O
		STR R0, [R1] 
	
		BX  LR 
	
PuertoD_Init
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
    ORR R0, R0, #0x0F               ; R0 = R0|0x0F (hace el puerto PD3-0 como salida)
    STR R0, [R1]                    ; [R1] = R0
    ; 6) regular port function
    LDR R1, =GPIO_PORTD_AFSEL_R     ; R1 = &GPIO_PORTD_AFSEL_R
    LDR R0, [R1]                    ; R0 = [R1]
    BIC R0, R0, #0x0F               ; R0 = R0&~0x0F (desactiva funciones alternativas en PD3-0)
    STR R0, [R1]                    ; [R1] = R0
    ; 
    LDR R1, =GPIO_PORTD_DR8R_R      ; R1 = &GPIO_PORTD_DR8R_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x0F               ; R0 = R0|0x0F (activa la salida de 8mA en PD3-0)
    STR R0, [R1]                    ; [R1] = R0
    ; 7) enable digital port
    LDR R1, =GPIO_PORTD_DEN_R       ; R1 = &GPIO_PORTD_DEN_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x0F               ; R0 = R0|0x0F (activa funciones digitales I/O on PD3-0)
    STR R0, [R1]                    ; [R1] = R0
    BX  LR

Loop
		LDR R8, =1	;contador del tiempo
		LDR R10, =1066666               ; R0 = FIFTHSEC (delay de 0.2 segundos)
		BL  delay                       ; delay del al menos (3*R0) ciclos
		BL  PortF_Input                 ; lee todos los switches en el puerto F
		CMP R0, #0x01                   ; R0 == 0x01?
		BEQ sw1pressed                  ; si lo es, switch 1 está presionado
		CMP R0, #0x10                   ; R0 == 0x10?
		BEQ sw2pressed                  ; si lo es, switch 2 está presionado
		B Loop

sw1pressed
		ADD R8, #1
		LDR	R1, =LEDS
		MOV R0, #5
		STR	R0, [R1]
		LDR R10, =5333	               	; 5333333/1000 = 1 mili segundo aprox
		BL  delay                       ; delay del al menos (3*R0) ciclos
		B   delay_off
		
delay
		SUB R10, #1	; R10 = R10 - 1 (cont = cont - 1)
		CMP R10, #0	; compara si R10 es 0, si lo es, realiza un return a la siguiente linea
		BNE delay	; si no es cero regresa a delay a seguir restando
		BX LR

delay_off
		LDR	R1, =LEDS
		MOV R0, #6
		STR	R0, [R1]
		LDR R10, =101327              	; 5333 * 18 = 18 mili segundo aprox
		BL  delay		; delay del al menos (3*R0) ciclos
		CMP R8, #12
		BEQ Loop
		B sw1pressed

sw2pressed
		ADD R8, #1
		LDR	R1, =LEDS
		MOV R0, #5
		STR	R0, [R1]
		LDR R10, =10555	               	;10000 funciona a 90 grados
		BL  delay1                       ; delay del al menos (3*R0) ciclos
		B   delay_off1
		
delay1
		SUB R10, #1	; R10 = R10 - 1 (cont = cont - 1)
		CMP R10, #0	; compara si R10 es 0, si lo es, realiza un return a la siguiente linea
		BNE delay1	; si no es cero regresa a delay a seguir restando
		BX LR

delay_off1
		LDR	R1, =LEDS
		MOV R0, #6
		STR	R0, [R1]
		LDR R10, =80000              	; 80000 funciona a 90 grados
		BL  delay1		; delay del al menos (3*R0) ciclos
		CMP R8, #18
		BEQ Reinicio_r8
		B sw2pressed

Reinicio_r8
		LDR R8, =1
		B sw1pressed


PortF_Input
		LDR R1, =GPIO_PORTF_DATA_R ; puntero al puerto F
		LDR R0, [R1]               ; lee todo el puerto F
		AND R0,R0,#0x11            ; lee solo los pines PF0 and PF4
		BX  LR  
	
		ALIGN
		END    