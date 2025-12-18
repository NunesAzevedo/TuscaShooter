; REGRAS DE OURO PARA FAZER JOGOS: Desenhar somente no Render; Mover so atualiza posicao; Posicao antiga salva uma vez por frame

inicio:
    jmp main
    
GameOverA:
	call ApagaTela
	halt
	
GameOverB:
    call ApagaTela
    halt

; Estado do jogo

teclaAtual: var #1

; Jogador 1
posJogador: var #1
posJogador_2: var #1
posJogadorAnt: var #1
posJogadorAnt_2: var #1

; Jogador 2
posJogadorB: var #1
posJogadorB_2: var #1
posJogadorBAnt: var #1
posJogadorBAnt_2: var #1

; -------- TIRO JOGADOR A --------
tiroA_pos: var #1
tiroA_ant: var #1
tiroA_ativo: var #1

; -------- TIRO JOGADOR B --------
tiroB_pos: var #1
tiroB_ant: var #1
tiroB_ativo: var #1

; -------- VIDAS --------
vidasA: var #1
vidasB: var #1

; -------- PAREDES --------
numParedes: var #1

parede0: var #1
parede1: var #1
parede2: var #1
parede3: var #1

; Controle de frame
frame: var #1

main:
	call ImprimeMenu
    call ApagaTela
    
    loadn r0, #4
    store numParedes, r0

    loadn r0, #420
    store parede0, r0

    loadn r0, #460
    store parede1, r0

    loadn r0, #700
    store parede2, r0

    loadn r0, #740
    store parede3, r0

    call DesenhaParedes


    loadn r0, #0
    store teclaAtual, r0
    store frame, r0
    
	store tiroA_ativo, r0
	store tiroB_ativo, r0
	
	loadn r0, #3
	store vidasA, r0
	store vidasB, r0
	
	; Jogador A
    loadn r0, #600
	store posJogador, r0
	load r0, posJogador
	loadn r1, #40
	add r0, r0, r1
	store posJogador_2, r0
	
	; Jogador B
	loadn r0, #650
	store posJogadorB, r0
	load r0, posJogadorB
	loadn r1, #40
	add r0, r0, r1
	store posJogadorB_2, r0


    jmp loop

loop:
    call LeTecladoNB       ; input (não bloqueante)
    call AtualizaEstado    ; lógica
        
    call ChecaJogadorA_Paredes
    call ChecaJogadorB_Paredes
    
    call AtualizaTiroA
	call AtualizaTiroB
	
	call ChecaTiroA_Paredes
    call ChecaTiroB_Paredes
    
	call ChecaColisoes
    call Render            ; desenha
    call Delay             ; controla FPS

    load r0, frame
    inc r0
    store frame, r0

    jmp loop

LeTecladoNB:
    push r0
    push r1

    inchar r0
    loadn r1, #0
    cmp r0, r1
    jeq LeTecladoNB_Skip

    store teclaAtual, r0

LeTecladoNB_Skip:
    pop r1
    pop r0
    rts

AtualizaEstado:
    push r0
    push r1
    
    ; Jogador A
    load r0, posJogador
	store posJogadorAnt, r0
	load r0, posJogador_2
	store posJogadorAnt_2, r0
	
	; Jogador B
	load r0, posJogadorB
    store posJogadorBAnt, r0
    load r0, posJogadorB_2
    store posJogadorBAnt_2, r0


    load r0, teclaAtual
	
	; --- Jogador A ---
    loadn r1, #'a'
    cmp r0, r1
    ceq MoveEsq

    loadn r1, #'d'
    cmp r0, r1
    ceq MoveDir

    loadn r1, #'w'
    cmp r0, r1
    ceq MoveCima
    
    loadn r1, #'s'
    cmp r0, r1
    ceq MoveBaixo
    
    ; --- Jogador B ---
    loadn r1, #'j'
    cmp r0, r1
    ceq MoveEsqB

    loadn r1, #'l'
    cmp r0, r1
    ceq MoveDirB

    loadn r1, #'i'
    cmp r0, r1
    ceq MoveCimaB

    loadn r1, #'k'
    cmp r0, r1
    ceq MoveBaixoB
    
    ; ===== TIRO JOGADOR A =====
	loadn r1, #' '
	cmp r0, r1
	ceq DisparaTiroA

	; ===== TIRO JOGADOR B =====
	loadn r1, #'p'
	cmp r0, r1
	ceq DisparaTiroB



    ; consome a tecla
    loadn r0, #0
    store teclaAtual, r0
	
    pop r1
    pop r0
    rts

AtualizaTiroA:
    push r0
    push r1
    push r2

    load r0, tiroA_ativo
    loadn r1, #0
    cmp r0, r1
    jeq AtualizaTiroA_fim

    ; verifica coluna
    load r0, tiroA_pos
    loadn r1, #40
    div r2, r0, r1
    mul r2, r2, r1
    sub r2, r0, r2

    loadn r1, #39
    cmp r2, r1
    jeq TiroA_Morre

    ; apaga posição atual ANTES de mover
    loadn r1, #' '
    outchar r1, r0

    inc r0
    store tiroA_pos, r0

    jmp AtualizaTiroA_fim

TiroA_Morre:
    loadn r1, #' '
    outchar r1, r0

    loadn r0, #0
    store tiroA_ativo, r0

AtualizaTiroA_fim:
    pop r2
    pop r1
    pop r0
    rts

AtualizaTiroB:
    push r0
    push r1
    push r2

    load r0, tiroB_ativo
    loadn r1, #0
    cmp r0, r1
    jeq AtualizaTiroB_fim

    load r0, tiroB_pos
    loadn r1, #40
    div r2, r0, r1
    mul r2, r2, r1
    sub r2, r0, r2

    loadn r1, #39
    cmp r2, r1
    jeq TiroB_Morre

    loadn r1, #' '
    outchar r1, r0

    inc r0
    store tiroB_pos, r0

    jmp AtualizaTiroB_fim

TiroB_Morre:
    loadn r1, #' '
    outchar r1, r0

    loadn r0, #0
    store tiroB_ativo, r0

AtualizaTiroB_fim:
    pop r2
    pop r1
    pop r0
    rts
    
ChecaColisoes:
    push r0
    push r1
    push r2

    ; =========================
    ; TIRO A ATINGE JOGADOR B
    ; =========================
    load r0, tiroA_ativo
    loadn r1, #0
    cmp r0, r1
    jeq Colisao_TiroB   ; pula se tiro A não ativo

    load r0, tiroA_pos

    load r1, posJogadorB
    cmp r0, r1
    jeq AcertoB

    load r1, posJogadorB_2
    cmp r0, r1
    jeq AcertoB

Colisao_TiroB:
    ; =========================
    ; TIRO B ATINGE JOGADOR A
    ; =========================
    load r0, tiroB_ativo
    loadn r1, #0
    cmp r0, r1
    jeq ChecaColisoes_fim

    load r0, tiroB_pos

    load r1, posJogador
    cmp r0, r1
    jeq AcertoA

    load r1, posJogador_2
    cmp r0, r1
    jeq AcertoA

    jmp ChecaColisoes_fim

AcertoB:
    push r0
    push r1

    load r0, tiroA_pos
    loadn r1, #' '
    outchar r1, r0

    loadn r0, #0
    store tiroA_ativo, r0

    load r0, vidasB
    dec r0
    store vidasB, r0

    loadn r1, #0
    cmp r0, r1
    jeq GameOverA

    pop r1
    pop r0
    jmp ChecaColisoes_fim

AcertoA:
    push r0
    push r1

    load r1, tiroB_pos
    loadn r0, #' '
    outchar r0, r1

    store tiroB_ant, r1

    loadn r0, #0
    store tiroB_ativo, r0

    load r0, vidasA
    dec r0
    store vidasA, r0

    loadn r1, #0
    cmp r0, r1
    jeq GameOverB

    pop r1
    pop r0
    jmp ChecaColisoes_fim

ChecaColisoes_fim:
    pop r2
    pop r1
    pop r0
    rts

ChecaTiroA_Paredes:
    push r0
    push r1
    push r2

    load r0, tiroA_ativo
    loadn r1, #0
    cmp r0, r1
    jeq CTAP_fim

    load r0, tiroA_pos

    ; --- parede 0 ---
    load r1, parede0
    cmp r0, r1
    jeq TiroA_Morre_Parede
    inc r1
    cmp r0, r1
    jeq TiroA_Morre_Parede

    ; --- parede 1 ---
    load r1, parede1
    cmp r0, r1
    jeq TiroA_Morre_Parede
    inc r1
    cmp r0, r1
    jeq TiroA_Morre_Parede

    ; --- parede 2 ---
    load r1, parede2
    cmp r0, r1
    jeq TiroA_Morre_Parede
    inc r1
    cmp r0, r1
    jeq TiroA_Morre_Parede

    ; --- parede 3 ---
    load r1, parede3
    cmp r0, r1
    jeq TiroA_Morre_Parede
    inc r1
    cmp r0, r1
    jeq TiroA_Morre_Parede

    jmp CTAP_fim

TiroA_Morre_Parede:

    loadn r0, #0
    store tiroA_ativo, r0

CTAP_fim:
    pop r2
    pop r1
    pop r0
    rts

ChecaTiroB_Paredes:
    push r0
    push r1
    push r2

    load r0, tiroB_ativo
    loadn r1, #0
    cmp r0, r1
    jeq CTBP_fim

    load r0, tiroB_pos

    ; --- parede 0 ---
    load r1, parede0
    cmp r0, r1
    jeq TiroB_Morre_Parede
    inc r1
    cmp r0, r1
    jeq TiroB_Morre_Parede

    ; --- parede 1 ---
    load r1, parede1
    cmp r0, r1
    jeq TiroB_Morre_Parede
    inc r1
    cmp r0, r1
    jeq TiroB_Morre_Parede

    ; --- parede 2 ---
    load r1, parede2
    cmp r0, r1
    jeq TiroB_Morre_Parede
    inc r1
    cmp r0, r1
    jeq TiroB_Morre_Parede

    ; --- parede 3 ---
    load r1, parede3
    cmp r0, r1
    jeq TiroB_Morre_Parede
    inc r1
    cmp r0, r1
    jeq TiroB_Morre_Parede

    jmp CTBP_fim

TiroB_Morre_Parede:

    loadn r0, #0
    store tiroB_ativo, r0

CTBP_fim:
    pop r2
    pop r1
    pop r0
    rts

ChecaJogadorA_Paredes:
    push r0
    push r1

    ; -------- testa parte 1 --------
    load r0, posJogador

    load r1, parede0
    cmp r0, r1
    jeq ColisaoJogA
    inc r1
    cmp r0, r1
    jeq ColisaoJogA

    load r1, parede1
    cmp r0, r1
    jeq ColisaoJogA
    inc r1
    cmp r0, r1
    jeq ColisaoJogA

    load r1, parede2
    cmp r0, r1
    jeq ColisaoJogA
    inc r1
    cmp r0, r1
    jeq ColisaoJogA

    load r1, parede3
    cmp r0, r1
    jeq ColisaoJogA
    inc r1
    cmp r0, r1
    jeq ColisaoJogA

    ; -------- testa parte 2 --------
    load r0, posJogador_2

    load r1, parede0
    cmp r0, r1
    jeq ColisaoJogA
    inc r1
    cmp r0, r1
    jeq ColisaoJogA

    load r1, parede1
    cmp r0, r1
    jeq ColisaoJogA
    inc r1
    cmp r0, r1
    jeq ColisaoJogA

    load r1, parede2
    cmp r0, r1
    jeq ColisaoJogA
    inc r1
    cmp r0, r1
    jeq ColisaoJogA

    load r1, parede3
    cmp r0, r1
    jeq ColisaoJogA
    inc r1
    cmp r0, r1
    jeq ColisaoJogA

    jmp CJAP_fim

ColisaoJogA:
    ; restaura posição anterior
    load r0, posJogadorAnt
    store posJogador, r0

    load r0, posJogadorAnt_2
    store posJogador_2, r0

CJAP_fim:
    pop r1
    pop r0
    rts

ChecaJogadorB_Paredes:
    push r0
    push r1

    load r0, posJogadorB

    load r1, parede0
    cmp r0, r1
    jeq ColisaoJogB
    inc r1
    cmp r0, r1
    jeq ColisaoJogB

    load r1, parede1
    cmp r0, r1
    jeq ColisaoJogB
    inc r1
    cmp r0, r1
    jeq ColisaoJogB

    load r1, parede2
    cmp r0, r1
    jeq ColisaoJogB
    inc r1
    cmp r0, r1
    jeq ColisaoJogB

    load r1, parede3
    cmp r0, r1
    jeq ColisaoJogB
    inc r1
    cmp r0, r1
    jeq ColisaoJogB

    load r0, posJogadorB_2

    load r1, parede0
    cmp r0, r1
    jeq ColisaoJogB
    inc r1
    cmp r0, r1
    jeq ColisaoJogB

    load r1, parede1
    cmp r0, r1
    jeq ColisaoJogB
    inc r1
    cmp r0, r1
    jeq ColisaoJogB

    load r1, parede2
    cmp r0, r1
    jeq ColisaoJogB
    inc r1
    cmp r0, r1
    jeq ColisaoJogB

    load r1, parede3
    cmp r0, r1
    jeq ColisaoJogB
    inc r1
    cmp r0, r1
    jeq ColisaoJogB

    jmp CJBP_fim

ColisaoJogB:
    load r0, posJogadorBAnt
    store posJogadorB, r0

    load r0, posJogadorBAnt_2
    store posJogadorB_2, r0

CJBP_fim:
    pop r1
    pop r0
    rts


MoveEsq:
    push r0
	
    load r0, posJogador
    dec r0
    store posJogador, r0
    load r0, posJogador_2
    dec r0
    store posJogador_2, r0

    pop r0
    rts

MoveEsqB:
    push r0
	
    load r0, posJogadorB
    dec r0
    store posJogadorB, r0
    load r0, posJogadorB_2
    dec r0
    store posJogadorB_2, r0

    pop r0
    rts

MoveDir:
    push r0
	
    load r0, posJogador
    inc r0
    store posJogador, r0
    load r0, posJogador_2
    inc r0
    store posJogador_2, r0

    pop r0
    rts

MoveDirB:
    push r0

    load r0, posJogadorB
    inc r0
    store posJogadorB, r0

    load r0, posJogadorB_2
    inc r0
    store posJogadorB_2, r0

    pop r0
    rts

MoveCima:
    push r0

    load r0, posJogador
    loadn r1, #40
    sub r0, r0, r1
    store posJogador, r0
    load r0, posJogador_2
    loadn r1, #40
    sub r0, r0, r1
    store posJogador_2, r0

    pop r0
    rts

MoveCimaB:
    push r0

    load r0, posJogadorB
    loadn r1, #40
    sub r0, r0, r1
    store posJogadorB, r0
    load r0, posJogadorB_2
    loadn r1, #40
    sub r0, r0, r1
    store posJogadorB_2, r0

    pop r0
    rts
    
MoveBaixo:
    push r0
    push r1

    load r0, posJogador
    loadn r1, #40     ; largura da tela
    add r0, r0, r1
    store posJogador, r0
    load r0, posJogador_2
    loadn r1, #40     ; largura da tela
    add r0, r0, r1
    store posJogador_2, r0

    pop r1
    pop r0
    rts

MoveBaixoB:
    push r0
    push r1

    load r0, posJogadorB
    loadn r1, #40     ; largura da tela
    add r0, r0, r1
    store posJogadorB, r0
    load r0, posJogadorB_2
    loadn r1, #40     ; largura da tela
    add r0, r0, r1
    store posJogadorB_2, r0

    pop r1
    pop r0
    rts

DisparaTiroA:
    push r0

    load r0, tiroA_ativo
    loadn r1, #1
    cmp r0, r1
    jeq DisparaTiroA_fim   ; já existe tiro

    loadn r0, #1
    store tiroA_ativo, r0

    load r0, posJogador
    store tiroA_pos, r0
    store tiroA_ant, r0

DisparaTiroA_fim:
    pop r0
    rts

DisparaTiroB:
    push r0

    load r0, tiroB_ativo
    loadn r1, #1
    cmp r0, r1
    jeq DisparaTiroB_fim

    loadn r0, #1
    store tiroB_ativo, r0

    load r0, posJogadorB
    store tiroB_pos, r0
    store tiroB_ant, r0

DisparaTiroB_fim:
    pop r0
    rts


DesenhaPersonagem:
    push r0
    push r1

    loadn r0, #'@'        ; caractere do personagem
    load r1, posJogador  ; posição atual
    outchar r0, r1
    loadn r0, #'*'
    load r1, posJogador_2
    outchar r0, r1

    pop r1
    pop r0
    rts

DesenhaPersonagemB:
    push r0
    push r1

    loadn r0, #'@'        ; caractere do personagem
    load r1, posJogadorB  ; posição atual
    outchar r0, r1
    loadn r0, #'*'
    load r1, posJogadorB_2
    outchar r0, r1

    pop r1
    pop r0
    rts

DesenhaParedes:
    push r0
    push r1

    ; parede 0
    load r1, parede0
    loadn r0, #'['
    outchar r0, r1
    loadn r0, #']'
    inc r1
    outchar r0, r1

    ; parede 1
    load r1, parede1
    loadn r0, #'['
    outchar r0, r1
    loadn r0, #']'
    inc r1
    outchar r0, r1

    ; parede 2
    load r1, parede2
    loadn r0, #'['
    outchar r0, r1
    loadn r0, #']'
    inc r1
    outchar r0, r1

    ; parede 3
    load r1, parede3
    loadn r0, #'['
    outchar r0, r1
    loadn r0, #']'
    inc r1
    outchar r0, r1

    pop r1
    pop r0
    rts


RenderTiroA:
    push r0
    push r1

    load r0, tiroA_ativo
    loadn r1, #0
    cmp r0, r1
    jeq RenderTiroA_fim

    loadn r0, #'-'
    load r1, tiroA_pos
    outchar r0, r1

RenderTiroA_fim:
    pop r1
    pop r0
    rts

RenderTiroB:
    push r0
    push r1

    load r0, tiroB_ativo
    loadn r1, #0
    cmp r0, r1
    jeq RenderTiroB_fim

    loadn r0, #'-'
    load r1, tiroB_pos
    outchar r0, r1

RenderTiroB_fim:
    pop r1
    pop r0
    rts

Render:
    push r0
    push r1
    
    ;call MapaZero

    ; apaga frame anterior
    call ApagaPersonagem
    call ApagaPersonagemB

    ; desenha jogador
    call DesenhaPersonagem	
    call DesenhaPersonagemB
    call RenderTiroA
    call RenderTiroB

    pop r1
    pop r0
    
    rts

Delay:
						;Utiliza Push e Pop para nao afetar os Ristradores do programa principal
	Push R0
	Push R1
	
	Loadn R1, #50  ; a
   Delay_volta2:				;Quebrou o contador acima em duas partes (dois loops de decremento)
	Loadn R0, #3000	; b
   Delay_volta: 
	Dec R0					; (4*a + 6)b = 1000000  == 1 seg  em um clock de 1MHz
	JNZ Delay_volta	
	Dec R1
	JNZ Delay_volta2
	
	Pop R1
	Pop R0
	
	RTS							;return

ImprimeMenu:
	push r1
	push r2
	
	loadn r1, #tela0Linha0 ; Endereco da primeira linha da tela
	loadn r2, #0  		   ; Cor branca
	call ImprimeTela
	
	loadn r2, #13
	
	lerTecla:
		inchar r1
		cmp r1, r2
		jne lerTecla
	
	pop r2
	pop r1
	rts

MapaZero:
	push r1
	push r2
	
	loadn r1, #telaMapaLinha0
	loadn r2, #0
	call ImprimeTela
	
	pop r2
	pop r1
	rts

ApagaTela:
    push r0
    push r1

    loadn r0, #' '
    loadn r1, #0

ApagaTela_loop:
    outchar r0, r1
    inc r1
    loadn r2, #1200
    cmp r1, r2
    jne ApagaTela_loop

    pop r1
    pop r0
    rts

ApagaPersonagem:
    push r0
    push r1

    loadn r0, #' '
    load r1, posJogadorAnt
    outchar r0, r1
    load r1, posJogadorAnt_2
    outchar r0, r1

    pop r1
    pop r0
    rts

ApagaPersonagemB:
    push r0
    push r1

    loadn r0, #' '
    load r1, posJogadorBAnt
    outchar r0, r1
    load r1, posJogadorBAnt_2
    outchar r0, r1

    pop r1
    pop r0
    rts

ApagaTiroA:
    push r0
    push r1

    load r0, tiroA_ativo
    loadn r1, #0
    cmp r0, r1
    jeq ApagaTiroA_fim   ; <<< NÃO APAGA SE INATIVO

    loadn r0, #' '
    load r1, tiroA_ant
    outchar r0, r1

ApagaTiroA_fim:
    pop r1
    pop r0
    rts

ApagaTiroB:
    push r0
    push r1

    load r0, tiroB_ativo
    loadn r1, #0
    cmp r0, r1
    jeq ApagaTiroB_fim

    loadn r0, #' '
    load r1, tiroB_ant
    outchar r0, r1

ApagaTiroB_fim:
    pop r1
    pop r0
    rts

DesenhaTiros:
    push r0
    push r1

    load r0, tiroA_ativo
    loadn r1, #1
    cmp r0, r1
    jne DT_A_skip

    loadn r0, #'|'
    load r1, tiroA_pos
    outchar r0, r1

DT_A_skip:

    load r0, tiroB_ativo
    loadn r1, #1
    cmp r0, r1
    jne DT_B_skip

    loadn r0, #'!'
    load r1, tiroB_pos
    outchar r0, r1

DT_B_skip:
    pop r1
    pop r0
    rts
    
ImprimeStr:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; Criterio de parada

   ImprimeStr_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq ImprimeStr_Sai
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		jmp ImprimeStr_Loop
	
   ImprimeStr_Sai:	
	pop r4	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0
	rts

    
ImprimeTela: 	;  Rotina de Impresao de Cenario na Tela Inteira
		;  r1 = endereco onde comeca a primeira linha do Cenario
		;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r4 na pilha para ser usado na subrotina

	loadn R0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn R3, #40  	; Incremento da posicao da tela!
	loadn R4, #41  	; incremento do ponteiro das linhas da tela
	loadn R5, #1200 ; Limite da tela!
	
   ImprimeTela_Loop:
		call ImprimeStr
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne ImprimeTela_Loop	; Enquanto r0 < 1200

	pop r5	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
    


; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-TELAS-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;	Menu
tela0Linha0  : string "                                        "
tela0Linha1  : string "                                        "
tela0Linha2  : string "                                        "
tela0Linha3  : string "                                        "
tela0Linha4  : string "                                        "
tela0Linha5  : string "                                        "
tela0Linha6  : string "                                        "
tela0Linha7  : string "                                        "
tela0Linha8  : string "                                        "
tela0Linha9  : string "  ____       ___   __                   "
tela0Linha10 : string " | __ |__ _ _| |_ | | __ _ __        __ "
tela0Linha11 : string " | || ||| ||_   _|| |/ _` || |  __  / / "
tela0Linha12 : string " | || |||_|| | |  | | (_| | | |_||_/ /  "
tela0Linha13 : string " |____||___| |_|  |_||__ _|  |_/  |_/   "
tela0Linha14 : string "                                        "
tela0Linha15 : string "                                        "
tela0Linha16 : string "                                        "
tela0Linha17 : string "                                        "
tela0Linha18 : string "                                        "
tela0Linha19 : string "     Replica do jogo para Atari 2600    "
tela0Linha20 : string "                                        "
tela0Linha21 : string "                                        "
tela0Linha22 : string "                                        "
tela0Linha23 : string "                                        "
tela0Linha24 : string "                                        "
tela0Linha25 : string "                                        "
tela0Linha26 : string "                                        "
tela0Linha27 : string "     Pressione ENTER para continuar!    "
tela0Linha28 : string "                                        "
tela0Linha29 : string "                                        "

telaMapaLinha0  : string "                                        "
telaMapaLinha1  : string "                                        "
telaMapaLinha2  : string "                                        "
telaMapaLinha3  : string "    [][][][][][]                        "
telaMapaLinha4  : string "                                        "
telaMapaLinha5  : string "                                        "
telaMapaLinha6  : string "                                        "
telaMapaLinha7  : string "                                        "
telaMapaLinha8  : string "                                        "
telaMapaLinha9  : string "                                        "
telaMapaLinha10 : string "                                        "
telaMapaLinha11 : string "                                        "
telaMapaLinha12 : string "                                        "
telaMapaLinha13 : string "                                        "
telaMapaLinha14 : string "                                        "
telaMapaLinha15 : string "                                        "
telaMapaLinha16 : string "                                        "
telaMapaLinha17 : string "                                        "
telaMapaLinha18 : string "                                        "
telaMapaLinha19 : string "                                        "
telaMapaLinha20 : string "                                        "
telaMapaLinha21 : string "                                        "
telaMapaLinha22 : string "                                        "
telaMapaLinha23 : string "                                        "
telaMapaLinha24 : string "                                        "
telaMapaLinha25 : string "                                        "
telaMapaLinha26 : string "                                        "
telaMapaLinha27 : string "                                        "
telaMapaLinha28 : string "                                        "
telaMapaLinha29 : string "                                        "

tela1Linha0  : string "                                        "
tela1Linha1  : string "           Selecione o mapa             "
tela1Linha2  : string "     ( Digitar numeros entre 1 e 4  )   "
tela1Linha3  : string "          ________       ________       "
tela1Linha4  : string "         |        |     |        |      "
tela1Linha5  : string "         |        |     |        |      "
tela1Linha6  : string "         |________|     |________|      "
tela1Linha7  : string "                                        "
tela1Linha8  : string "          ________       ________       "                             
tela1Linha9  : string "         |        |     |        |      "
tela1Linha10 : string "         |        |     |        |      "
tela1Linha11 : string "         |________|     |________|      "
tela1Linha12 : string "                                        "
tela1Linha13 : string "                                        "
tela1Linha14 : string "                                        "
tela1Linha15 : string "                                        "    
tela1Linha16 : string "                                        "
tela1Linha17 : string "                                        "
tela1Linha18 : string "                                        "
tela1Linha19 : string "             INSTRUCOES                 "
tela1Linha20 : string "    Use o A, W, S, D, para se mover     "
tela1Linha21 : string "  ESPACO para disparar com o revolver   "
tela1Linha22 : string "                                        "
tela1Linha23 : string "                                        "
tela1Linha24 : string "                                        "
tela1Linha25 : string "                                        "
tela1Linha26 : string "        Pressione S para jogar          "
tela1Linha27 : string "                                        "
tela1Linha28 : string "                                        "
tela1Linha29 : string "                                        "


; Game Over
gameOverLinha0  : string "                                        "
gameOverLinha1  : string "                                        "
gameOverLinha2  : string "                                        "
gameOverLinha3  : string "                                        "
gameOverLinha4  : string "                                        "
gameOverLinha5  : string "                                        "
gameOverLinha6  : string "                                        "
gameOverLinha7  : string "                                        "
gameOverLinha8  : string "                                        "
gameOverLinha9  : string "             Player 1 Wins              "
gameOverLinha10 : string "                                        "
gameOverLinha11 : string "                                        "
gameOverLinha12 : string "                                        "
gameOverLinha13 : string "                                        "
gameOverLinha14 : string "               SCORE:                   "
gameOverLinha15 : string "                                        "
gameOverLinha16 : string "                                        "
gameOverLinha17 : string "                                        "
gameOverLinha18 : string "                                        "
gameOverLinha19 : string "           s - Jogar Novamente          "
gameOverLinha20 : string "                                        "
gameOverLinha21 : string "              SPACE - Sair              "
gameOverLinha22 : string "                                        "
gameOverLinha23 : string "                                        "
gameOverLinha24 : string "                                        "
gameOverLinha25 : string "                                        "
gameOverLinha26 : string "                                        "
gameOverLinha27 : string "                                        "
gameOverLinha28 : string "                                        "
gameOverLinha29 : string "                                        "



; Game Win
gameWinLinha0  : string "                                        "
gameWinLinha1  : string "                                        "
gameWinLinha2  : string "                                        "
gameWinLinha3  : string "                                        "
gameWinLinha4  : string "                                        "
gameWinLinha5  : string "                                        "
gameWinLinha6  : string "                                        "
gameWinLinha7  : string "                                        "
gameWinLinha8  : string "                                        "
gameWinLinha9  : string "              Player 2 Wins             "
gameWinLinha10 : string "                                        "
gameWinLinha11 : string "                                        "
gameWinLinha12 : string "                                        "
gameWinLinha13 : string "                                        "
gameWinLinha14 : string "                                        "
gameWinLinha15 : string "                                        "
gameWinLinha16 : string "                                        "
gameWinLinha17 : string "                                        "
gameWinLinha18 : string "                                        "
gameWinLinha19 : string "           s - Jogar Novamente          "
gameWinLinha20 : string "                                        "
gameWinLinha21 : string "              SPACE - Sair              "
gameWinLinha22 : string "                                        "
gameWinLinha23 : string "                                        "
gameWinLinha24 : string "                                        "
gameWinLinha25 : string "                                        "
gameWinLinha26 : string "                                        "
gameWinLinha27 : string "                                        "
gameWinLinha28 : string "                                        "
gameWinLinha29 : string "                                        "

telaFinalLinha0  : string "                                        "
telaFinalLinha1  : string "                                        "
telaFinalLinha2  : string "                                        "
telaFinalLinha3  : string "                                        "
telaFinalLinha4  : string "                                        "
telaFinalLinha5  : string "                                        "
telaFinalLinha6  : string "                                        "
telaFinalLinha7  : string "                                        "
telaFinalLinha8  : string "                                        "
telaFinalLinha9  : string "                                        "
telaFinalLinha10 : string "                                        "
telaFinalLinha11 : string "                                        "
telaFinalLinha12 : string "                                        "
telaFinalLinha13 : string "                                        "
telaFinalLinha14 : string "                                        "
telaFinalLinha15 : string "           ................             "
telaFinalLinha16 : string "                                        "
telaFinalLinha17 : string "                                        "
telaFinalLinha18 : string "                                        "
telaFinalLinha19 : string "                                        "
telaFinalLinha20 : string "                                        "
telaFinalLinha21 : string "                                        "
telaFinalLinha22 : string "                                        "
telaFinalLinha23 : string "                                        "
telaFinalLinha24 : string "                                        "
telaFinalLinha25 : string "                                        "
telaFinalLinha26 : string "                                        "
telaFinalLinha27 : string "                                        "
telaFinalLinha28 : string "                                        "
telaFinalLinha29 : string "                                        "
