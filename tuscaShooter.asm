;call menu

	jmp main

	; ================== Variáveis ===================

lifesCaaso:
	var #1; Vidas do jogador do CAASO

lifesFederupa:
	var #1; Vidas do jogador da Federal

posCaasoLeft:
	var #1; Coordenada do jogador do CAASO (Parte da Esquerda)

posCaasoRight:
	var #1; Coordenada do jogador do CAASO (Parte da Direita)

posFederupaLeft:
	var #1; Coordenadas do jogador da Federal (Parte da Esquerda)

posFederupaRight:
	var #1; Coordenadas do jogador da Federal (Parte da Direita)

flagChineladaCaaso:
	var #1; Flag se o CAASO tomou chinelada

posChineloCaaso:
	var #1; Posição do chinelo do CAASO

flagChineladaFederupa:
	var #1; Flag se a Federal tomou chinelada

posChineloFederupa:
	var #1; Posição do chinelo da Federal

	; ============== Funções Auxiliares ==============

	; --- Imprime string na tela: ---

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

	; --- Printa uma tela ---

PrintScreen:
	push r0; Salva valor da posição inicial
	push r1; Endereço do começo do cenário
	push r2; Cor do cenário
	push r3; Incremento da posição da tela para pular linha
	push r4; Incremento do ponteiro das linhas da tela
	push r5; Salva valor do limite da tela

	loadn r0, #0
	loadn r3, #40
	loadn r4, #41; -> 40 + 1 ('\0')
	loadn r5, #1200

PrintScreen_loop:
	call PrintStr
	add  r0, r0, r3; Pula uma linha
	add  r1, r1, r4; Incrementa o ponteiro para a próxima linha

	;   Verifica se chegou ao final da tela
	cmp r0, r5
	jne PrintScreen_loop

	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

	; --- Limpa a Tela ---

CleanScreen:
	push r0; Posição a ser limpa
	push r1; Guarda ' ' (espaço)

	loadn r0, #1201; -> 1200 + 1 (A função começara decrementando r0)
	loadn r1, #' '

CleanScreen_loop:
	dec     r0
	outchar r1, r0
	jnz     CleanScreen_loop

	pop r1
	pop r0
	rts

	; --- Causa Delay no jogo para controlar o fps ---

Delay:
	push r0; Armazena quantidade de clocks ignorados

	loadn r0, #1000000; 1 segundo em clock de 1 MHz

Delay_loop:
	dec r0
	jnz Delay_loop

	pop r0
	rts

	; Printa HUD

PrintHud:
	push r0; Armazena posição para começar a printar
	push r1; Armazena endereço da sting da HUD

	loadn r0, #1160
	lodan r1, #hud
	call  PrintStr

	pop r1
	pop r0
	rts

main:

	halt

