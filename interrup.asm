;
; led.asm

; ----- SETUP -----
.include "m328pdef.inc"

.cseg

jmp reset
.org OC1Aaddr
jmp OCI1A_Interrupt

OCI1A_Interrupt:
	push r20
	in r20, SREG
	push r20
	
	subi r24, 1 ; contador - 1


	pop r20
	out SREG, r20
	pop r20
	reti


reset:


	;.org 	0x00

	; NOMEAR SEMaFOROS
	.def temp = r20 
	.def sema12 = r21 ; semaforo 1 e 2
	.def sema34 = r23 ; semaforo 3 e 4
	.def count = r24;
	.def state = r25
	.def stateaux = r19

	ldi count, 60
	ldi state, 0
	ldi stateaux,0


	; ARMAZENAR ESTADOS
	; semaforos 1 e 2
	;estados12: .db 0x0C,0x0C,0x0C,0x14, 0x24, 0x24, 0x21, 0x22,0x22,0x0C
	;estados34: .db 0x0C,0x14,0x24,0x24, 0x24, 0x21, 0x21, 0x21, 0x22, 0x22

	estado:
	  .dw 0x0C0C
	  .dw 0x140C
	  .dw 0x240C
	  .dw 0x2414
	  .dw 0x2424
	  .dw 0x2124
	  .dw 0x2121
	  .dw 0x2122
	  .dw 0x2222
	  .dw 0x220C

	.equ TAMANHO_ARRAY = 20; bytes ou 10 posições de elementos de 2 bytes cada
	.equ ENDERECO_FINAL = estado + TAMANHO_ARRAY

	; INICIALIZAR STACK

	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	; SETAR OS PINOS DOS SEMAFOROS COMO SAIDA
	ldi temp, 255 ; 0b1111111 - constante para setar os pinos como saida
	out  DDRB,temp		
	out  DDRC,temp	

	; CONFIGURAR O DELAY

	#define CLOCK 16.0e6 ;clock speed
	#define DELAY 1.0e-3 ;seconds
	.equ PRESCALE = 0b100 ;/256 prescale
	.equ PRESCALE_DIV = 256
	.equ WGM = 0b0100 ;Waveform generation mode: CTC - you must ensure this value is between 0 and 65535
	.equ TOP = int(0.5 + ((CLOCK/PRESCALE_DIV)*DELAY))
	.if TOP > 65535
	.error "TOP is out of range"
	.endif

	; AJUSTES FINAIS NO TIMER
	ldi temp, high(TOP) 
	sts OCR1AH, temp
	ldi temp, low(TOP)
	sts OCR1AL, temp
	ldi temp, ((WGM&0b11) << WGM10) 
	sts TCCR1A, temp
	ldi temp, ((WGM>> 2) << WGM12)|(PRESCALE << CS10)
	sts TCCR1B, temp 


	; ENDEREÇO DOS ESTADOS
	ldi ZL, low(estado*2)
	ldi ZH, high(estado*2)


	; habilitar interrupcoes do timer
	lds	 temp, TIMSK1
	sbr temp, 1 <<OCIE1A
	sts TIMSK1, temp

	sei ; habilitar interrupcoes globais

	; --- MAIN LOOP ---
	main:

		; ACENDA OS LEDS
		
		; z = z + state*2
		add state, state

		add ZL, state
		adc ZH,stateaux 

		lpm sema12, Z+ ;JA VAI PARA O PROXIMO
		out PORTB,sema12

		lpm sema34, Z
		out PORTC,sema34

		; Para fazer Z voltar ao LSB do elemento que ele acabou de ler:
		subi ZL, 1       ; Decrementa ZL em 1
		sbci ZH, 0       ; Decrementa ZH em 0 com carry (se ZL "emprestou")

		; QUAL ESTADO DO LED?

		; Testa state = 0
		cpi state, 0
		brne test_state_1 ; Se state != 0, testa o próximo valor
		jmp state_0      ; Se state == 0, vai para state_0

		test_state_1:
			; Testa state = 1
			cpi state, 1
			brne test_state_2 
			jmp state_1

		test_state_2:
			; Testa state = 2
			cpi state, 2
			brne test_state_3
			jmp state_2

		test_state_3:
			; Testa state = 3
			cpi state, 3
			brne test_state_4
			jmp state_3

		test_state_4:
			; Testa state = 4
			cpi state, 4
			brne test_state_5
			jmp state_4

		test_state_5:
			; Testa state = 5
			cpi state, 5
			brne test_state_6
			rjmp state_5

		test_state_6:
			; Testa state = 6
			cpi state, 6
			brne test_state_7
			rjmp state_6

		test_state_7:
			; Testa state = 7
			cpi state, 7
			brne test_state_8
			rjmp state_7

		test_state_8:
			; Testa state = 8
			cpi state, 8
			brne test_state_9
			rjmp state_8

		test_state_9:
			; Testa state = 9
			cpi state, 9
			brne main ; Se state != 0..9, trata erro
			rjmp state_9

		
		state_0:
			; Ações específicas para STATE 0
			cpi count, 0
			brne main           
			; Transição para STATE 1:
			ldi state, 1
			ldi count, 4      
			 
			      
			rjmp main

		state_1:
			; Ações específicas para STATE 1
			cpi count, 0
			brne main
	
			; Transição para STATE 2:

			ldi state, 2  
			ldi count, 23     
			     
			rjmp main

		state_2:
			; Ações específicas para STATE 2
			cpi count, 0
			brne main
	
			; Transição para STATE 3:
			ldi count, 4      
			ldi state, 3
			rjmp main

		state_3:
			; Ações específicas para STATE 3
			cpi count, 0
			brne main
	
			; Transição para STATE 4:
			ldi count, 20
			ldi state, 4
			rjmp main

		state_4:
			; Ações específicas para STATE 4
			cpi count, 0
			brne main
	
			; Transição para STATE 5:
			ldi count, 3
			ldi state, 5
			rjmp main

		state_5:
			; Ações específicas para STATE 5
			cpi count, 0
			brne main
	
			; Transição para STATE 6:
			ldi count, 21
			ldi state, 6
			rjmp main

		state_6:
			; Ações específicas para STATE 6
			cpi count, 0
			brne main
	
			; Transição para STATE 7:
			ldi count, 1
			ldi state, 7
			rjmp main

		state_7:
			; Ações específicas para STATE 7
			cpi count, 0
			brne main
	
			; Transição para STATE 8:
			ldi count, 3
			ldi state, 8
			rjmp main

		state_8:
			; Ações específicas para STATE 8
			cpi count, 0
			brne main
	
			; Transição para STATE 9:
			ldi count, 1
			ldi state, 9
			rjmp main

		state_9: 
			; Ações específicas para STATE 9 (Último estado)
			cpi count, 0
			brne main
	
			; Transição para o estado inicial (STATE 0):
			ldi count, 60      
			ldi state, 0       
			jmp main


		jmp main


	;loop:	rjmp    loop