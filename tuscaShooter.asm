call menu

	jmp main

stringTeste : string "Test string in assembly"

	; Imprime string na tela:

PrintStr:
	push r0; Posição onde o primeiro caracter será impresso
	push r1; Endereço do primeiro caracter das string
	push r2; Cor da mensagem
	push r3; Guarda critério de parada: '\0'
	push r4; Guarda variável auxiliar

	loadn r3, #'\0'

PrintStr_loop:
	loadi r4, r1

	;   Verifica se chegou ao final da string
	cmp r4, r3
	jeq PrintStr_Final

	add     r4, r2, r4; Adiciona cor à string
	outchar r4, r0
	inc     r0
	inc     r1
	jmp     PrintStr_loop

PrintStr_Final:
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

main:

	halt

