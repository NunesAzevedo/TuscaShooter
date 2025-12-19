; REGRAS DE OURO PARA FAZER JOGOS: Desenhar somente no Render; Mover so atualiza posicao; Posicao antiga salva uma vez por frame
; FLuxo da execucao programa : 
; inicio
;	L main		(<call>, teclaAtual = 0, frame = 0, flagChineladaCaaso = flagChineladaFederupa = 0)
;	    |		(lifesCaaso = 3, lifesFederupa = 3, posCaasoUp = 600, posCaasoDown = , posFederupaUp = 710, posFederupaDown = )
;		|
;		L StartGameScreen
;		|			|
;		|			L ImprimeTela
;		|
;		L CleanScreen
;		L DesenhaParedes
;		L loop		(frame = frame + 1)
;			|
;			L leTecladoNB
;			L AtualizaEstado ( posCaasoUpAnt = posCaasoUp, teclaAtual =? 'w','a','s','d','i','j','k','l',' ', 'p', teclaAtual = 0 )
;			|		L MoveCaasoLeft
;			|		L MoveCaasoRight
;			|		L MoveCaasoUp
;			|		L MoveCaasoDown
;			|		L MoveFederupaLeft
;			|		L MoveFederupaRight
;			|		L MoveFederupaUp
;			|		L MoveFederupaDown
;			|		L DisparaTiroCaaso
;			|		L DisparaTiroFederupa
;			L ChecaColisoes
;			L Render
;				|
;				L EraseCaaso
;				L DesenhaChinelos
;			L Delay
;			L loop

; funcoes principais do programa (inicio, main, loop, LeTecladoNB, AtualizaEstado, 
;								 (ChecaColisoes, Render, Delay)


; ====== DECLARACAO DE VARIAVEIS ===================

; Vidas do jogador
lifesCaaso: var #1
lifesFederupa: var #1

posCaasoUp: var #1; Coordenada do jogador do CAASO (Parte de Cima) 		posCaasoUp: var #1
posCaasoDown: var #1; Coordenada do jogador do CAASO (Parte de Baixo)	posCaasoDown: var #1

posCaasoUpAnt: var #1 ; posicao anterior
posCaasoDownAnt: var #1

posFederupaUp: var #1; Coordenadas do jogador da Federal (Parte de Cima) posFederupaUp: var #1
posFederupaDown: var #1; Coordenadas do jogador da Federal (Parte de Baixo) posFederupaDown: var #1

posFederupaUpAnt: var #1 ; posicao anterior
posFederupaDownAnt: var #1

flagChineladaCaaso: var #1; Flag se o CAASO tomou chinelada		flagChineladaCaaso: var #1
flagChineladaFederupa: var #1; Flag se a Federal tomou chinelada	flagChineladaFederupa: var #1

posChineloCaaso: var #1; Posição do chinelo do CAASO		posChineloCaaso: var #1
posChineloFederupa: var #1; Posição do chinelo da Federal	posChineloFederupa: var #1

posChineloCaasoAnt: var #1; 		posChineloCaasoAnt: var #1
posChineloFederupaAnt: var #1;		posChineloFederupaAnt: var #1

; Estado do jogo
teclaAtual: var #1

; Controle de frame
frame: var #1

inicio:
	call StartGameScreen
	call Tutorial
    call CleanScreen
    jmp main
    
main:
	push r0
	push r1

    loadn r0, #0
    store teclaAtual, r0
    store frame, r0
    
	store flagChineladaCaaso, r0
	store flagChineladaFederupa, r0
	
	loadn r0, #3
	store lifesCaaso, r0
	store lifesFederupa, r0
	
	; Jogador CAASO
    loadn r0, #600
	store posCaasoUp, r0
	loadn r1, #40
	add r0, r0, r1
	store posCaasoDown, r0
	
	; Jogador FEDERUPA
	loadn r0, #710
	store posFederupaUp, r0
	loadn r1, #40
	add r0, r0, r1
	store posFederupaDown, r0
	
	pop r1
	pop r0

    jmp loop

loop:
    call LeTecladoNB       ; input (não bloqueante)
    call AtualizaEstado    ; lógica
       
    call AtualizaTiroCaaso
    call AtualizaTiroFederupa
    
	call ChecaColisoes
    call Render            ; desenha
    call Delay             ; controla FPS
	
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
    load r0, posCaasoUp
	store posCaasoUpAnt, r0
	load r0, posCaasoDown
	store posCaasoDownAnt, r0
	
	; Jogador B
	load r0, posFederupaUp
    store posFederupaUpAnt, r0
    load r0, posFederupaDown
    store posFederupaDownAnt, r0


    load r0, teclaAtual
	
	; --- Jogador A ---
    loadn r1, #'a'
    cmp r0, r1
    ceq MoveCaasoLeft

    loadn r1, #'d'
    cmp r0, r1
    ceq MoveCaasoRight

    loadn r1, #'w'
    cmp r0, r1
    ceq MoveCaasoUp
    
    loadn r1, #'s'
    cmp r0, r1
    ceq MoveCaasoDown
    
    ; --- Jogador B ---
    loadn r1, #'j'
    cmp r0, r1
    ceq MoveFederupaLeft

    loadn r1, #'l'
    cmp r0, r1
    ceq MoveFederupaRight

    loadn r1, #'i'
    cmp r0, r1
    ceq MoveFederupaUp

    loadn r1, #'k'
    cmp r0, r1
    ceq MoveFederupaDown
    
    ; ===== TIRO JOGADOR A =====
	loadn r1, #' '
	cmp r0, r1
	ceq DisparaTiroCaaso

	; ===== TIRO JOGADOR B =====
	loadn r1, #'p'
	cmp r0, r1
	ceq DisparaTiroFederupa

    ; consome a tecla
    loadn r0, #0
    store teclaAtual, r0
	
    pop r1
    pop r0
    rts

AtualizaTiroCaaso:
    push r0
    push r1
    push r2

    load r0, flagChineladaCaaso
    loadn r1, #1
    cmp r0, r1
    jne ATA_fim

    ; salva posição anterior
    load r0, posChineloCaaso
    store posChineloCaasoAnt, r0

    ; move para a direita
    inc r0
    store posChineloCaaso, r0

    ; ===============================
    ; CHECA LIMITE DIREITO DA TELA
    ; ===============================
    loadn r1, #40
    mod r2, r0, r1       ; r2 = posChineloCaaso % 40
    loadn r1, #39
    cmp r2, r1
    jne ATA_fim

    ; saiu da tela → mata o tiro
    loadn r0, #0
    store flagChineladaCaaso, r0

ATA_fim:
    pop r2
    pop r1
    pop r0
    rts

AtualizaTiroFederupa:
    push r0
    push r1
    push r2

    load r0, flagChineladaFederupa
    loadn r1, #1
    cmp r0, r1
    jne ATB_fim

    ; salva posição anterior
    load r0, posChineloFederupa
    store posChineloFederupaAnt, r0

    ; ===============================
    ; MOVE PARA A ESQUERDA
    ; ===============================
    dec r0
    store posChineloFederupa, r0

    ; ===============================
    ; CHECA LIMITE ESQUERDO DA TELA
    ; ===============================
    loadn r1, #40
    mod r2, r0, r1       ; r2 = posChineloFederupa % 40
    loadn r1, #0
    cmp r2, r1
    jne ATB_fim

    ; saiu da tela → mata o tiro
    loadn r0, #0
    store flagChineladaFederupa, r0

ATB_fim:
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
    load r0, flagChineladaCaaso
    loadn r1, #0
    cmp r0, r1
    jeq Colisao_TiroB   ; pula se tiro A não ativo

    load r0, posChineloCaaso

    load r1, posFederupaUp
    cmp r0, r1
    jeq AcertoB

    load r1, posFederupaDown
    cmp r0, r1
    jeq AcertoB

Colisao_TiroB:
    ; =========================
    ; TIRO B ATINGE JOGADOR A
    ; =========================
    load r0, flagChineladaFederupa
    loadn r1, #0
    cmp r0, r1
    jeq ChecaColisoes_fim

    load r0, posChineloFederupa

    load r1, posCaasoUp
    cmp r0, r1
    jeq AcertoA

    load r1, posCaasoDown
    cmp r0, r1
    jeq AcertoA

    jmp ChecaColisoes_fim

AcertoB:
    push r0
    push r1

    load r0, posChineloCaaso
    loadn r1, #' '
    outchar r1, r0

    loadn r0, #0
    store flagChineladaCaaso, r0

    load r0, lifesFederupa
    dec r0
    store lifesFederupa, r0

    loadn r1, #0
    cmp r0, r1
    jeq GameOverA

    pop r1
    pop r0
    jmp ChecaColisoes_fim

AcertoA:
    push r0
    push r1

    load r1, posChineloFederupa
    loadn r0, #' '
    outchar r0, r1

    loadn r0, #0
    store flagChineladaFederupa, r0

    load r0, lifesCaaso
    dec r0
    store lifesCaaso, r0

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

MataTiroA:
    loadn r0, #0
    store flagChineladaCaaso, r0
    rts

MataTiroB:
    loadn r0, #0
    store flagChineladaFederupa, r0
    rts
    
MoveCaasoLeft:
    push r0
	
    load r0, posCaasoUp
    dec r0
    store posCaasoUp, r0
    load r0, posCaasoDown
    dec r0
    store posCaasoDown, r0

    pop r0
    rts

MoveFederupaLeft:
    push r0
    push r1
    push r2

    ; calcula coluna atual
    load r0, posFederupaUp
    loadn r1, #40
    mod r2, r0, r1       ; r2 = coluna

    ; se coluna == 20 → NÃO MOVE
    loadn r1, #20
    cmp r2, r1
    jeq MEB_fim

    ; move normalmente
    dec r0
    store posFederupaUp, r0

    load r0, posFederupaDown
    dec r0
    store posFederupaDown, r0

MEB_fim:
    pop r2
    pop r1
    pop r0
    rts

MoveCaasoRight:
    push r0
    push r1
    push r2

    ; calcula coluna atual
    load r0, posCaasoUp
    loadn r1, #40
    mod r2, r0, r1       ; r2 = coluna

    ; se coluna == 19 → NÃO MOVE
    loadn r1, #19
    cmp r2, r1
    jeq MD_fim

    ; move normalmente
    inc r0
    store posCaasoUp, r0

    load r0, posCaasoDown
    inc r0
    store posCaasoDown, r0

MD_fim:
    pop r2
    pop r1
    pop r0
    rts

MoveFederupaRight:
    push r0

    load r0, posFederupaUp
    inc r0
    store posFederupaUp, r0

    load r0, posFederupaDown
    inc r0
    store posFederupaDown, r0

    pop r0
    rts

MoveCaasoUp:
    push r0

    load r0, posCaasoUp
    loadn r1, #40
    sub r0, r0, r1
    store posCaasoUp, r0
    load r0, posCaasoDown
    loadn r1, #40
    sub r0, r0, r1
    store posCaasoDown, r0

    pop r0
    rts

MoveFederupaUp:
    push r0

    load r0, posFederupaUp
    loadn r1, #40
    sub r0, r0, r1
    store posFederupaUp, r0
    load r0, posFederupaDown
    loadn r1, #40
    sub r0, r0, r1
    store posFederupaDown, r0

    pop r0
    rts
    
MoveCaasoDown:
    push r0
    push r1

    load r0, posCaasoUp
    loadn r1, #40     ; largura da tela
    add r0, r0, r1
    store posCaasoUp, r0
    load r0, posCaasoDown
    loadn r1, #40     ; largura da tela
    add r0, r0, r1
    store posCaasoDown, r0

    pop r1
    pop r0
    rts

MoveFederupaDown:
    push r0
    push r1

    load r0, posFederupaUp
    loadn r1, #40     ; largura da tela
    add r0, r0, r1
    store posFederupaUp, r0
    load r0, posFederupaDown
    loadn r1, #40     ; largura da tela
    add r0, r0, r1
    store posFederupaDown, r0

    pop r1
    pop r0
    rts

DisparaTiroCaaso:
    push r0

    load r0, flagChineladaCaaso
    loadn r1, #1
    cmp r0, r1
    jeq DisparaTiroA_fim   ; já existe tiro

    loadn r0, #1
    store flagChineladaCaaso, r0

    load r0, posCaasoUp
    store posChineloCaaso, r0
    store posChineloCaasoAnt, r0

DisparaTiroA_fim:
    pop r0
    rts

DisparaTiroFederupa:
    push r0

    load r0, flagChineladaFederupa
    loadn r1, #1
    cmp r0, r1
    jeq DisparaTiroB_fim

    loadn r0, #1
    store flagChineladaFederupa, r0

    load r0, posFederupaUp
    store posChineloFederupa, r0
    store posChineloFederupaAnt, r0

DisparaTiroB_fim:
    pop r0
    rts

Render:
    push r0
    push r1
    
    call EraseCaaso		; apaga frame anterior
    call EraseFederupa
    call ApagaChinelos 

    call DrawCaaso	
    call DrawFederupa
    call DesenhaChinelos
    call PrintHud

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

DrawCaaso:
    push r0
    push r1

    loadn r0, #'@'
    loadn r2, #256     ; cor jogador A
    add r0, r0, r2
    load r1, posCaasoUp
    outchar r0, r1

    loadn r0, #'*'
    loadn r2, #256
    add r0, r0, r2
    load r1, posCaasoDown
    outchar r0, r1

    pop r1
    pop r0
    rts

DrawFederupa:
    push r0
    push r1

    loadn r0, #'&'
    loadn r2, #768     ; cor jogador A
    add r0, r0, r2
    load r1, posFederupaUp
    outchar r0, r1

    loadn r0, #'%'
    loadn r2, #768
    add r0, r0, r2
    load r1, posFederupaDown
    outchar r0, r1

    pop r1
    pop r0
    rts


StartGameScreen:
	push r1
	push r2
	
	loadn r1, #screenStartGameLinha0 ; Endereco da primeira linha da tela
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

Tutorial:
	push r1
	push r2
	
	loadn r1, #screenTutorialLinha0 ; Endereco da primeira linha da tela
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


GameOverA:
	call CleanScreen
	push r0
	push r1
	push r2
	
	loadn r1, #gameOverLinha0 ; Endereco da primeira linha da tela
	loadn r2, #0  		   ; Cor branca
	call ImprimeTela
	
	loadn r2, #13
	
	lerTecla:
		inchar r1
		cmp r1, r2
		jne lerTecla
	
	pop r2
	pop r1
	pop r0
	
	jmp inicio
	
GameOverB:
    call CleanScreen
    push r0
    push r1
    push r2
    loadn r1, #gameWinLinha0 ; Endereco da primeira linha da tela
	loadn r2, #0  		   ; Cor branca
	call ImprimeTela
	
	loadn r2, #13
	
	lerTecla:
		inchar r1
		cmp r1, r2
		jne lerTecla
		
    pop r2
    pop r1
    pop r0
    
    jmp inicio

CleanScreen:
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

EraseCaaso:
    push r0
    push r1

    loadn r0, #' '
    load r1, posCaasoUpAnt
    outchar r0, r1
    load r1, posCaasoDownAnt
    outchar r0, r1

    pop r1
    pop r0
    rts

EraseFederupa:
    push r0
    push r1

    loadn r0, #' '
    load r1, posFederupaUpAnt
    outchar r0, r1
    load r1, posFederupaDownAnt
    outchar r0, r1

    pop r1
    pop r0
    rts

ApagaChinelos:
    push r0
    push r1

    loadn r0, #' '

    load r1, posChineloCaasoAnt
    outchar r0, r1

    load r1, posChineloFederupaAnt
    outchar r0, r1

    pop r1
    pop r0
    rts


DesenhaChinelos:
    push r0
    push r1

    load r0, flagChineladaCaaso
    loadn r1, #1
    cmp r0, r1
    jne DT_A_skip

    loadn r0, #'-'
    load r1, posChineloCaaso
    outchar r0, r1

DT_A_skip:

    load r0, flagChineladaFederupa
    loadn r1, #1
    cmp r0, r1
    jne DT_B_skip

    loadn r0, #'-'
    load r1, posChineloFederupa
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

PrintHud:
	push r0; Armazena posição para começar a printar
	push r1; Armazena endereço da string da HUD
	push r2 ; cor
	
	
	loadn r0, #0
	loadn r1, #hud
	loadn r2, #0
	call  ImprimeStr
	
	pop r2
	pop r1
	pop r0
	rts
	

; HUD
hud    : string "                                         VIDAS CAASO:       VIDAS FEDERUPA:     "
hud3x3 : string "                                         VIDAS CAASO: 3     VIDAS FEDERUPA: 3   "
hud3x2 : string "                                         VIDAS CAASO: 3     VIDAS FEDERUPA: 2   "
hud3x1 : string "                                         VIDAS CAASO: 3     VIDAS FEDERUPA: 1   "
hud2x3 : string "                                         VIDAS CAASO: 2     VIDAS FEDERUPA: 3   "
hud2x2 : string "                                         VIDAS CAASO: 2     VIDAS FEDERUPA: 2   "
hud2x1 : string "                                         VIDAS CAASO: 2     VIDAS FEDERUPA: 1   "
hud1x3 : string "                                         VIDAS CAASO: 1     VIDAS FEDERUPA: 3   "
hud1x2 : string "                                         VIDAS CAASO: 1     VIDAS FEDERUPA: 2   "
hud1x1 : string "                                         VIDAS CAASO: 1     VIDAS FEDERUPA: 1   "


; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-TELAS-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;	Menu
screenStartGameLinha0  : string "                                        "
screenStartGameLinha1  : string "                                        "
screenStartGameLinha2  : string "                                        "
screenStartGameLinha3  : string "                                        "
screenStartGameLinha4  : string "                                        "
screenStartGameLinha5  : string "                                        "
screenStartGameLinha6  : string "                                        "
screenStartGameLinha7  : string "                                        "
screenStartGameLinha8  : string "                                        "
screenStartGameLinha9  : string "  _____                                 "
screenStartGameLinha10 : string " |_   _| _ _    __  ___  __ _           "
screenStartGameLinha11 : string "   | |  || ||  | _|| _| | _` |          "
screenStartGameLinha12 : string "   | |  ||_|| _| ) | _  |(_| |          "
screenStartGameLinha13 : string "   |_|  |___| |_/  |__| |__ _|          "
screenStartGameLinha14 : string "                                        "
screenStartGameLinha15 : string "    _____                               "
screenStartGameLinha16 : string "   |._.__|__               __           "
screenStartGameLinha17 : string "   |.|___ ||               ||        __ "
screenStartGameLinha18 : string "   |_._. )||___  __   __  _||_  ___ / _|"
screenStartGameLinha19 : string "  __  /./ |---| |. | |. ||_. _|| _| ||  "
screenStartGameLinha20 : string " |.|_/./  || || |. | |. |  ||  ||__ ||  "
screenStartGameLinha21 : string " |_ _ /   || || |__| |__|  ||  | _| ||  "
screenStartGameLinha22 : string "                               |__| ||  "
screenStartGameLinha23 : string "                                        "
screenStartGameLinha24 : string "                                        "
screenStartGameLinha25 : string "                                        "
screenStartGameLinha26 : string "                                        "
screenStartGameLinha27 : string "     Pressione ENTER para continuar!    "
screenStartGameLinha28 : string "                                        "
screenStartGameLinha29 : string "                                        "
    
screenTutorialLinha0  : string "                                        "
screenTutorialLinha1  : string "                                        "
screenTutorialLinha2  : string "                                        "
screenTutorialLinha3  : string "                                        "
screenTutorialLinha4  : string "                                        "
screenTutorialLinha5  : string "             INSTRUCOES                 "
screenTutorialLinha6  : string "                                        "
screenTutorialLinha7  : string "             CAASO                      "
screenTutorialLinha8  : string "    Use   A, W, S, D, para se mover     "
screenTutorialLinha9  : string "          ESPACO para disparar          "
screenTutorialLinha10 : string "                                        "
screenTutorialLinha11 : string "             FEDERUPA                   "
screenTutorialLinha12 : string "    Use  I, J, K, L para se mover       "
screenTutorialLinha13 : string "            P para disparar             "
screenTutorialLinha14 : string "                                        "
screenTutorialLinha15 : string "                                        "
screenTutorialLinha16 : string "      Pressione ENTER para jogar        "
screenTutorialLinha17 : string "                                        "
screenTutorialLinha18 : string "                                        "
screenTutorialLinha19 : string "                                        "
screenTutorialLinha20 : string "                                        "
screenTutorialLinha21 : string "                                        "
screenTutorialLinha22 : string "                                        "
screenTutorialLinha23 : string "                                        "
screenTutorialLinha24 : string "                                        "
screenTutorialLinha25 : string "                                        "
screenTutorialLinha26 : string "                                        "
screenTutorialLinha27 : string "                                        "
screenTutorialLinha28 : string "                                        "
screenTutorialLinha29 : string "                                        "

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
gameOverLinha9  : string "           Federupa   Wins!             "
gameOverLinha10 : string "                                        "
gameOverLinha11 : string "                                        "
gameOverLinha12 : string "                                        "
gameOverLinha13 : string "                                        "
gameOverLinha14 : string "               SCORE:                   "
gameOverLinha15 : string "                                        "
gameOverLinha16 : string "                                        "
gameOverLinha17 : string "                                        "
gameOverLinha18 : string "                                        "
gameOverLinha19 : string "       ENTER - Jogar Novamente          "
gameOverLinha20 : string "                                        "
gameOverLinha21 : string "              Esc - Fechar jogo         "
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
gameWinLinha9  : string "               Caaso   Wins!            "
gameWinLinha10 : string "                                        "
gameWinLinha11 : string "                                        "
gameWinLinha12 : string "                                        "
gameWinLinha13 : string "                                        "
gameWinLinha14 : string "                                        "
gameWinLinha15 : string "                                        "
gameWinLinha16 : string "                                        "
gameWinLinha17 : string "                                        "
gameWinLinha18 : string "                                        "
gameWinLinha19 : string "       Enter - Jogar Novamente          "
gameWinLinha20 : string "                                        "
gameWinLinha21 : string "        Esc - Fechar jogo               "
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
