;
; led.asm


.include "m328pdef.inc"

.cseg
.org 	0x00

; NOMEAR SEMÁFOROS
.def tudosaida = r20 
.def sema12 = r21 ; semáforo 1 e 2
.def sema34 = r23 ; semáforo 3 e 4

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

ldi tudosaida, 255 ; 0b00000111 - constante para setar os pinos como saída

; SETAR OS PINOS DOS SEMÁFOROS COMO SAÍDA
out  DDRB,tudosaida		
out  DDRC,tudosaida	

ldi ZL, low(estado*2)
ldi ZH, high(estado*2)

lpm sema12, Z+ ;JÁ VAI PARA O PRÓXIMO
out PORTB,sema12

lpm sema34, Z
out PORTC,sema34


; ESTAODO INICIAL
;ldi	sema12,(1<<PINB2) | (1<<PINB3)
;out  PORTB,sema12	

;ldi	sema34,(1<<PINC2) | (1<<PINC3)
;out  PORTC,sema34	


loop:	rjmp    loop