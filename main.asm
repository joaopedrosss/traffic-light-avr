;
; led.asm


.include "m328pdef.inc"

.cseg
.org 	0x00

.def tudosaida = r20 
.def sema12 = r21 ; semáforo 1 e 2
.def sema34 = r23 ; semáforo 3 e 4

ldi tudosaida, 255; 0b00000111 - constante para setar os pinos como saída

; SETAR OS PINOS DOS SEMÁFOROS COMO SAÍDA
out  DDRB,tudosaida		
out  DDRC,tudosaida		


ldi	sema12,(1<<PINB0) | (1<<PINB1)| (1<<PINB2) | (1<<PINB3)| (1<<PINB4) | (1<<PINB5)
out  PORTB,sema12	


ldi	sema34,(1<<PINC0) | (1<<PINC1)| (1<<PINC2) | (1<<PINC3)| (1<<PINC4) | (1<<PINC5)
out  PORTC,sema34	

loop:	rjmp    loop