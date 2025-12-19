	jmp Main

	; ================== Variáveis ===================

lifesCaaso:
	var #1; Vidas do jogador do CAASO

lifesFederupa:
	var #1; Vidas do jogador da Federal

posCaasoUp:
	var #1; Coordenada do jogador do CAASO (Parte de Cima)

posCaasoDown:
	var #1; Coordenada do jogador do CAASO (Parte de Baixo)

posFederupaUp:
	var #1; Coordenadas do jogador da Federal (Parte de Cima)

posFederupaDown:
	var #1; Coordenadas do jogador da Federal (Parte de Baixo)

flagChineladaCaaso:
	var #1; Flag se o CAASO tomou chinelada

posChineloCaaso:
	var #1; Posição do chinelo do CAASO

flagChineladaFederupa:
	var #1; Flag se a Federal tomou chinelada

posChineloFederupa:
	var #1; Posição do chinelo da Federal

	;   =================== Strings ====================
	hud : string " VIDAS CAASO:         VIDAS FEDERUPA:   "

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
	jeq PrintStr_Skip

	add     r4, r2, r4; Adiciona cor à string
	outchar r4, r0
	inc     r0
	inc     r1
	jmp     PrintStr_loop

PrintStr_Skip:
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
	; Passa por vários ciclos sem fazer nada a fim
	; de deixar o tempo passar e, com isso, causar um
	; delay controlado no fps do jogo

Delay:

	push r0; Armazena quantidade de clocks ignorados
	push r1

	loadn r0, #10

Delay_loop1:
	loadn r1, #100

Delay_loop2:
	dec r1
	jnz Delay_loop2
	dec r0
	jnz Delay_loop1

	pop r1
	pop r0
	rts

	; --------------- Printa HUD ---------------

PrintHud:
	push r0; Armazena posição para começar a printar
	push r1; Armazena endereço da sting da HUD

	loadn r0, #1160
	loadn r1, #hud
	call  PrintStr

	pop r1
	pop r0
	rts

	; -------------- Printa os valores da HUD --------------

PrintValuesHud:
	push r0
	push r1

	; Print das vidas do Caaso

	load    r0, lifesCaaso
	loadn   r1, #48; Fator de correção para tabela ASC
	add     r0, r0, r1
	loadn   r1, #1174; Posição da tela da vida do Caaso
	outchar r0, r1

	; Print das vidas do Federupa

	load    r0, lifesFederupa
	loadn   r1, #48; Fator e correção para tabela ASC
	add     r0, r0, r1
	loadn   r1, #1199; Posição das vidas da Federal
	outchar r0, r1

	pop r1
	pop r0
	rts

	; --------- Tela de Game Over quando o CAASO Vence ---------

GameOverCaasoWin:
	loadn r0, #0; Posição do início  tela
	loadn r1, #gameOverCaasoWinLinha0
	call  PrintScreen

	; Pergunta ao jogador se quer jogar novamente
	; s: Jogar novamente
	; n: Finaliza o jogo

GameOverCaasoWin_ScanChar:
	inchar r0; Lê uma tecla do teclado
	loadn  r1, #'s'
	cmp    r0, r1
	jeq    Main

	loadn r1, #'n'
	cmp   r0, r1
	jeq   EndGameScreen

	;   Se nenhuma tecla for precionada
	;   volta para o início do loop
	jmp GameOverCaasoWin_ScanChar

	; --------- Tela de Game Over quando a Federal Vence ---------

GameOverFederalWin:
	loadn r0, #0; Posição do início  tela
	loadn r1, #gameOverFederalWinLinha0
	call  PrintScreen

	; Pergunta ao jogador se quer jogar novamente
	; s: Jogar novamente
	; n: Finaliza o jogo

GameOverFederalWin_ScanChar:
	inchar r0; Lê uma tecla do teclado
	loadn  r1, #'s'
	cmp    r0, r1
	jeq    Main

	loadn r1, #'n'
	cmp   r0, r1
	jeq   EndGameScreen

	;   Se nenhuma tecla for precionada
	;   volta para o início do loop
	jmp GameOverFederalWin_ScanChar

	; ----- Tela de Início do Jogo -----

StartGameScreen:
	push r1
	push r2

	loadn r1, #screenStartGameLinha0; Primeiro endereço da tela
	loadn r2, #0; Cor Branca
	call  PrintScreen

	;     -- Lê tecla do usuário para iniciar o jogo --
	;     Fica verificando em loop a entrada do usuário
	;     e enquanto não for precionado 'ENTER' o
	;     jogo não inicia, e quando for precionado
	;     limpa a tela e continua o programa
	loadn r2, #13

StartGameScreen_ScanChar:
	inchar r1
	cmp    r1, r2
	jne    StartGameScreen_ScanChar
	call   CleanScreen

	pop r2
	pop r1
	rts

	; ----- Tela com instruções de como jogar o jogo -----

Tuturial:
	call CleanScreen
	push r1
	push r2

	loadn r1, #screenTuturialLinha0; Primeiro endereço da tela de tuturial
	loadn r2, #0; Cor Branca
	call  PrintScreen

	;     -- Lê tecla do usuário para iniciar o jogo --
	;     Fica verificando em loop a entrada do usuário
	;     e enquanto não for precionado 'ENTER' o
	;     jogo não inicia, e quando for precionado
	;     limpa a tela e continua o programa
	call  Delay; Para não pular direto com o 'ENTER' da tela anterior
	loadn r2, #13

Tuturial_ScanChar:
	inchar r1
	cmp    r1, r2
	jne    Tuturial_ScanChar
	call   CleanScreen

	pop r2
	pop r1
	rts

	; ----- Tela de Fim do Jogo -----

EndGameScreen:
	loadn r0, #0; Posição do começo da tela
	loadn r1, #endGameScreenLinha0
	call  PrintScreen
	halt

	; --- Responsável pela movimentação do jogador do CAASO ---

Caaso:
	call DrawCaaso
	call MoveCaaso
	rts

DrawCaaso:
	; O jogador do CAASO será composto por 4 caracteres
	; C1 C3
	; C2 C4

	push r0
	push r1

	loadn   r0, #'c'; Caractere C1
	load    r1, posCaasoUp; Posição do C1
	outchar r0, r1

	inc     r0; Caractere C3
	inc     r1; Posição do C3
	outchar r0, r1

	inc     r0; Caractere C2
	load    r1, posCaasoDown; Posição C2
	outchar r0, r1

	inc r0; Caractere C4
	inc r1; Posição C4

	pop r1
	pop r0
	rts

	; --- Apaga o jogador do CAASO ---

EraseCaaso:
	push r0
	push r1
	push r2

	loadn r0, #' '; Caractere Vazio (Espaço)
	load  r1, posCaasoUp; Posição do C1
	load  r2, posCaasoDown; Posição do C2

	outchar r0, r1
	outchar r0, r2

	inc r1; Posição C3
	inc r2; Posição C4

	outchar r0, r1
	outchar r0, r2

	pop r2
	pop r1
	pop r0
	rts

MoveCaaso:
	; Movimentação do jogador do Caaso
	; será dada pelas teclas A, D e Espaço:
	; A     : Movimenta para a Esquerda
	; D     : Movimenta para a Direita
	; Espaço: Chinelada

	push r0
	push r1
	push r2
	push r3

	; Copia a entrada do teclado em r6
	; para o r0

	mov r0, r6

	loadn r1, #'a'
	cmp   r0, r1
	ceq   MoveCaasoLeft

	loadn r1, #'d'
	cmp   r0, r1
	ceq   MoveCaasoRight

	; Verifica se o jogador do Caaso
	; Atirou o chinelo

	loadn r1, #' '
	load  r2, flagChineladaCaaso
	loadn r3, #1
	cmp   r2, r3
	jeq   CaasoAtirouOChinelo_Skip

	cmp r0, r1
	ceq CaasoAtirouOChinelo

CaasoAtirouOChinelo_Skip:
	pop r3
	pop r2
	pop r1
	pop r0
	rts

MoveCaasoLeft:
	push r0
	push r1

	; Caso em que o jogador do Caaso está
	; na borda da tela

	load  r0, posCaasoUp
	loadn r1, #1041
	cmp   r0, r1
	jle   MoveCaasoLeft_Skip; Não faz nada

	call EraseCaaso

	; Decrementa a posição do jogador do Caaso

	load  r0, posCaasoUp
	dec   r0
	store posCaasoUp, r0

	load  r0, posCaasoDown
	dec   r0
	store posCaasoDown, r0

	call DrawCaaso

MoveCaasoLeft_Skip:
	pop r1
	pop r0
	rts

MoveCaasoRight:
	push r0
	push r1

	; Caso em que o jogador do Caaso está
	; na borda da tela

	load  r0, posCaasoUp
	loadn r1, #1077
	cmp   r0, r1
	jgr   MoveCaasoRight_Skip; Não faz nada

	call EraseCaaso

	; Decrementa a posição do jogador do Caaso

	load  r0, posCaasoUp
	inc   r0
	store posCaasoUp, r0

	load  r0, posCaasoDown
	inc   r0
	store posCaasoDown, r0

	call DrawCaaso

MoveCaasoRight_Skip:
	pop r1
	pop r0
	rts

CaasoAtirouOChinelo:
	; Ativa a flag de tiro e
	; coloca a posição de origem
	; do tiro sendo a de jogador
	; no momento em que foi disparado

	push r0

	loadn r0, #1
	store flagChineladaCaaso, r0
	load  r0, posCaasoUp
	store posChineloCaaso, r0

	pop r0
	rts

ChineladaCaaso:
	; Enquanto a flag de chinelada
	; estiver ativa, o chinelo
	; continua voando

	push r0
	push r1

	loadn r0, #1
	load  r1, flagChineladaCaaso
	cmp   r0, r1
	ceq   ChineladaCaasoMove

	pop r1
	pop r0
	rts

ChineladaCaasoMove:
	push r0
	push r1
	push r2
	push r3

	load r0, posChineloCaaso
	call EraseCaasoChinelo

	mov   r3, r0; Salva a posição velha em r3
	loadn r2, #40; Move a posição do chinelo uma linha acima
	sub   r0, r0, r2

	;-- Protecao contra Underflow --
	;   Se a posicao nova (r0) ficou
	;   maior que a antiga (r3)
	;   significa que houve um Underflow
	;   e o numero ficou enorme, por nao
	;   poder ficar negativo

	cmp r0, r3
	cgr ChineladaCaasoPassouPrimeiraLinha

	; Verifica se ele atingiu a borda da tela

	loadn r1, #10
	cmp   r0, r1
	cle   ChineladaCaasoPassouPrimeiraLinha

	store posChineloCaaso, r0
	call  ChineladaCaasoDraw

	pop r3
	pop r2
	pop r1
	pop r0
	rts

ChineladaCaasoPassouPrimeiraLinha:
	; Apaga o chinelo quando ele
	; passa da borda da tela

	push r0
	push r1
	push r2

	; Coloca o flag da Chinelada como 0

	loadn r0, #0
	store flagChineladaCaaso, r0

	loadn r1, #' '
	load  r2, posChineloCaaso

	outchar r1, r2
	inc     r2
	outchar r1, r2

	pop r2
	pop r1
	pop r0
	rts

ChineladaCaasoDraw:
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6

	load  r1, flagChineladaCaaso
	loadn r2, #0
	cmp   r1, r2
	jeq   ChineladaCaasoDraw_Skip

	load  r1, posChineloCaaso
	loadn r2, #'W'
	loadn r3, #'X'
	loadn r4, #'w'
	loadn r5, #'x'

	outchar r2, r1

	inc     r1; Desloca a posição do tiro para a direita
	outchar r3, r1

	dec   r1; Desloca posição do chinelo para a esquerda novamente
	loadn r6, #40
	add   r1, r1, r6; Desloca para cima o chinelo

	outchar r4, r1

	inc     r1
	outchar r5, r1

ChineladaCaasoDraw_Skip:
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	rts

EraseCaasoChinelo:
	push r0
	push r1
	push r2
	push r3

	loadn r0, #' '
	load  r1, posChineloCaaso

	; Verifica se a posição atual
	; do chinelo é a mesma do jogador
	; e se for, pula a função

	load  r2, posCaasoUp
	loadn r3, #40
	cmp   r1, r2
	jeq   EraseCaasoChinelo_Skip

	; Desenha Espaço vazio na
	; posição do chinelo

	add     r1, r1, r3
	outchar r0, r1
	inc     r1
	outchar r0, r1

EraseCaasoChinelo_Skip:
	pop r3
	pop r2
	pop r1
	pop r0
	rts

	; --- Responsável pela movimentação do jogador da Federal ---

Federupa:
	call DrawFederupa
	call MoveFederupa

DrawFederupa:
	; O Federupa será composto por 4 caracteres
	; F1 F3
	; F2 F4

	push r0
	push r1

	loadn   r0, #'f'; Caractere F1
	load    r1, posFederupaUp; Posição do F1
	outchar r0, r1

	inc     r0; Caractere F3
	inc     r1; Posição do F3
	outchar r0, r1

	inc     r0; Caractere F2
	load    r1, posFederupaDown; Posição F2
	outchar r0, r1

	inc r0; Caractere F4
	inc r1; Posição F4

	pop r1
	pop r0
	rts

	; --- Apaga o Federupa ---

EraseFederupa:
	push r0
	push r1
	push r2

	loadn r0, #' '; Caractere Vazio (Espaço)
	load  r1, posFederupaUp; Posição do F1
	load  r2, posFederupaDown; Posição do F2

	outchar r0, r1
	outchar r0, r2

	inc r1; Posição F3
	inc r2; Posição F4

	outchar r0, r1
	outchar r0, r2

	pop r2
	pop r1
	pop r0
	rts

MoveFederupa:
	;    Movimentação do Federupa
	;    será dada pelas teclas J, K e Enter:
	;    J    : Movimenta para a Esquerda
	;    K    : Movimenta para a Direita
	;    Enter: Chinelada
	push r0
	push r1
	push r2
	push r3

	; Copia a entrada do teclado em r6
	; para o r0

	mov r0, r6

	loadn r1, #'j'
	cmp   r0, r1
	ceq   MoveFederupaLeft

	loadn r1, #'k'
	cmp   r0, r1
	ceq   MoveFederupaRight

	; Verifica se o jogador do Caaso
	; Atirou o chinelo

	loadn r1, #13; Enter = 13
	load  r2, flagChineladaFederupa
	loadn r3, #1
	cmp   r2, r3
	jeq   FederupaAtirouOChinelo_Skip

	cmp r0, r1
	ceq FederupaAtirouOChinelo

FederupaAtirouOChinelo_Skip:
	pop r3
	pop r2
	pop r1
	pop r0
	rts

MoveFederupaLeft:
	push r0
	push r1

	; Caso em que o Federupa está
	; na borda da tela

	load  r0, posFederupaUp
	loadn r1, #0
	cmp   r0, r1
	jle   MoveFederupaLeft_Skip; Não faz nada

	call EraseFederupa

	; Decrementa a posição do Federupa

	load  r0, posFederupaUp
	dec   r0
	store posFederupaUp, r0

	load  r0, posFederupaDown
	dec   r0
	store posFederupaDown, r0

	call DrawFederupa

MoveFederupaLeft_Skip:
	pop r1
	pop r0
	rts

MoveFederupaRight:
	push r0
	push r1

	; Caso em que o Federupa está
	; na borda da tela

	load  r0, posFederupaUp
	loadn r1, #39
	cmp   r0, r1
	jgr   MoveFederupaRight_Skip; Não faz nada

	call EraseFederupa

	; Decrementa a posição do jogador do Caaso

	load  r0, posFederupaUp
	inc   r0
	store posFederupaUp, r0

	load  r0, posFederupaDown
	inc   r0
	store posFederupaDown, r0

	call DrawFederupa

MoveFederupaRight_Skip:
	pop r1
	pop r0
	rts

FederupaAtirouOChinelo:
	; Ativa a flag de tiro e
	; coloca a posição de origem
	; do tiro sendo a de jogador
	; no momento em que foi disparado

	push r0

	loadn r0, #1
	store flagChineladaFederupa, r0
	load  r0, posFederupaUp
	store posChineloFederupa, r0

	pop r0
	rts

	; --- Responsável pela Chinelada do jogador da Federal ---

ChineladaFederupa:
	; Enquanto a flag de chinelada
	; estiver ativa, o chinelo
	; continua voando

	push r0
	push r1

	loadn r0, #1
	load  r1, flagChineladaFederupa
	cmp   r0, r1
	ceq   ChineladaFederupaMove

	pop r1
	pop r0
	rts

ChineladaFederupaMove:
	push r0
	push r1
	push r2
	push r3

	load r0, posChineloFederupa
	call EraseFederupaChinelo

	mov   r3, r0; Salva a posição antiga em r3
	loadn r2, #40; Move a posição do chinelo uma linha acima
	add   r0, r0, r2

	;   -- Protecao contra Overflow --
	cmp r0, r3
	cle ChineladaFederupaPassouUltimaLinha

	; Verifica se ele atingiu a borda da tela

	loadn r1, #1120
	cmp   r0, r1
	cgr   ChineladaFederupaPassouUltimaLinha

	store posChineloFederupa, r0
	call  ChineladaFederupaDraw

	pop r3
	pop r2
	pop r1
	pop r0
	rts

ChineladaFederupaPassouUltimaLinha:
	; Apaga o chinelo quando ele
	; passa da borda da tela

	push r0
	push r1
	push r2
	push r3

	; Coloca o flag da Chinelada como 0

	loadn r0, #0
	store flagChineladaFederupa, r0

	loadn r1, #' '
	load  r2, posChineloFederupa

	;       Apaga parte de cima
	outchar r1, r2
	inc     r2
	outchar r1, r2

	;     Apaga parte de baixo
	loadn r3, #40
	dec   r2
	add   r2, r2, r3

	outchar r1, r2
	inc     r2
	outchar r1, r2

	pop r3
	pop r2
	pop r1
	pop r0
	rts

ChineladaFederupaDraw:
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6

	load  r1, flagChineladaFederupa
	loadn r2, #0
	cmp   r1, r2
	jeq   ChineladaFederupaDraw_Skip

	load  r1, posChineloFederupa
	loadn r2, #'W'
	loadn r3, #'X'
	loadn r4, #'w'
	loadn r5, #'x'

	;       Desenha parte de cima
	outchar r2, r1
	inc     r1; Desloca a posição do tiro para a direita
	outchar r3, r1

	dec   r1; Desloca posição do chinelo para a esquerda novamente
	loadn r6, #40
	add   r1, r1, r6; Desloca para baixo o chinelo

	outchar r4, r1

	inc     r1
	outchar r5, r1

ChineladaFederupaDraw_Skip:
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	rts

EraseFederupaChinelo:
	push r0
	push r1
	push r2
	push r3

	loadn r0, #' '
	load  r1, posChineloFederupa

	; Verifica se a posição atual
	; do chinelo é a mesma do jogador
	; e se for, pula a função

	load r2, posFederupaUp
	cmp  r1, r2
	jeq  EraseFederupaChinelo_Skip

	;       Apagar parte de cima do chinelo
	outchar r0, r1
	inc     r1
	outchar r0, r1

	;     Descer para a linha de baixo
	loadn r3, #40
	dec   r1
	add   r1, r1, r3

	;       Apaga a parte de baixo
	outchar r0, r1
	inc     r1
	outchar r0, r1

	; Desenha Espaço vazio na
	; posição do chinelo

	; loadn r3, #1040
	; add     r1, r1, r3
	; outchar r0, r1
	; inc     r1
	; outchar r0, r1

EraseFederupaChinelo_Skip:
	pop r3
	pop r2
	pop r1
	pop r0
	rts

	; --- Verifica se o jogador do CAASO foi atingido ---

IsCaasoHit:
	push r0
	push r1

	;     Verifica se a flag do chinelo esta ativa
	loadn r0, #0
	load  r1, flagChineladaFederupa
	cmp   r0, r1
	jeq   IsCaasoHit_Skip

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do Federupa: Esquerda
	; Posição do jogador do CAASO   : Esquerda
	; =====================================

	load r0, posChineloFederupa; Posição do chinelo do Federupa
	load r1, posCaasoUp
	cmp  r0, r1
	ceq  DecLifeCaaso
	cmp  r0, r1
	jeq  IsCaasoHit_Skip

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do Federupa: Esquerda
	; Posição do jogador do CAASO   : Direita
	; =====================================

	inc r1; Posição da direita do CAASO
	cmp r0, r1
	ceq DecLifeCaaso
	cmp r0, r1
	jeq IsCaasoHit_Skip

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do Federupa: Direita
	; Posição do jogador do CAASO   : Direita
	; =====================================

	inc r0; Posição da direita do chinelo
	cmp r0, r1
	ceq DecLifeCaaso
	cmp r0, r1
	jeq IsCaasoHit_Skip

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do Federupa: Direita
	; Posição do jogador do CAASO   : Esquerda
	; =====================================

	dec r1; Posição esquerda do CAASO
	cmp r0, r1
	ceq DecLifeCaaso

IsCaasoHit_Skip:
	pop r1
	pop r0
	rts

	; --- Verifica se o jogador da Federal foi atingido ---

IsFederupaHit:
	push r0
	push r1

	;     Verifica se a flag do chinelo esta ativa
	loadn r0, #0
	load  r1, flagChineladaCaaso
	cmp   r0, r1
	jeq   IsFederupaHit_Skip

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do CAASO: Esquerda
	; Posição do Federupa        : Esquerda
	; =====================================

	load r0, posChineloCaaso; Posição do chinelo do CAASO
	load r1, posFederupaUp
	cmp  r0, r1
	ceq  DecLifeFederupa
	cmp  r0, r1
	jeq  IsFederupaHit_Skip

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do CAASO: Esquerda
	; Posição do Federupa        : Direita
	; =====================================

	inc r1; Posição da direita do federupa
	cmp r0, r1
	ceq DecLifeFederupa
	cmp r0, r1
	jeq IsFederupaHit_Skip

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do CAASO: Direita
	; Posição do Federupa        : Direita
	; =====================================

	inc r0; Posição da direita do chinelo
	cmp r0, r1
	ceq DecLifeFederupa
	cmp r0, r1
	jeq IsFederupaHit_Skip

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do CAASO: Direita
	; Posição do Federupa        : Esquerda
	; =====================================

	dec r1; Posição esquerda do Federupa
	cmp r0, r1
	ceq DecLifeFederupa

IsFederupaHit_Skip:
	pop r1
	pop r0
	rts

	; --- Verifica se o jogador do CAASO tem vidas restantes ---

IsCaasoAlive:
	push  r0
	push  r1
	loadn r0, #0
	load  r1, lifesCaaso
	cmp   r0, r1
	jeq   GameOverFederalWin

	pop r1
	pop r0
	rts

	; --- Verifica se o jogador da Federal tem vidas restantes ---

IsFederupaAlive:
	push  r0
	push  r1
	loadn r0, #0
	load  r1, lifesFederupa
	cmp   r0, r1
	jeq   GameOverCaasoWin

	pop r1
	pop r0
	rts

	; --- Quando Federupa acerta o chinelo no jogador do CAASO ---

DecLifeCaaso:
	push r0
	push r1

	; Decrementa vidas do CAASO

	load  r0, lifesCaaso
	dec   r0
	store lifesCaaso, r0

	; Incrementa a vida do Federupa

	load  r0, lifesFederupa
	inc   r0
	store lifesFederupa, r0

	;    Apaga o chinelo
	call EraseFederupaChinelo

	;     Zera a flag da chinelada
	loadn r0, #0
	store flagChineladaFederupa, r0

	;     Teletransporta o chinelo para longe
	;     para evitar multipla colisao
	store posChineloFederupa, r0

	pop r1
	pop r0
	rts

	; --- Quando jogador do CAASO acerta o chinelo no Federupa ---

DecLifeFederupa:
	push r0
	push r1

	; Decrementa a vida do Federupa

	load  r0, lifesFederupa
	dec   r0
	store lifesFederupa, r0

	; Incrementa a vida do CAASO

	load  r0, lifesCaaso
	inc   r0
	store lifesCaaso, r0

	;    Apaga o chinelo
	call EraseCaasoChinelo

	;     Zera a flag da chinelada
	loadn r0, #0
	store flagChineladaCaaso, r0

	;     Teletransporta o chinelo para longe
	;     para evitar multipla colisao
	store posChineloCaaso, r0

	pop r1
	pop r0
	rts

Main:

	; ===================================
	; Setup inicial das variáveis do jogo
	; ===================================

	; Limpando lixo dos registradores

	loadn r0, #0
	loadn r1, #0
	loadn r2, #0
	loadn r3, #0
	loadn r4, #0
	loadn r5, #0
	loadn r6, #0
	loadn r7, #0

	call CleanScreen
	call StartGameScreen
	call Tuturial

	; Salva quantidades de vidas
	; dos jogadores

	loadn r0, #3
	store lifesCaaso, r0
	store lifesFederupa, r0

	;     Posição inicial do jogador do CAASO
	loadn r0, #1059
	store posCaasoUp, r0
	loadn r0, #1099
	store posCaasoDown, r0

	;     Posição inicial do jogador da Federal
	loadn r0, #19
	store posFederupaUp, r0
	loadn r0, #59
	store posFederupaDown, r0

	;     Zera a flag de chineladas do CAASO
	loadn r0, #0
	store flagChineladaCaaso, r0

	;     Zera a flag de chineladas do Federupa
	loadn r0, #0
	store flagChineladaFederupa, r0

	call PrintHud

	; ===================================================================
	; |                Funcionamento dos estados de jogo                |
	; |-----------------------------------------------------------------|
	; |O jogo acontecerá por meio de estados de jogo, em que cada estado|
	; |acontecerá quando um contador de estados do jogo for um múltiplo |
	; |de um determinado número específico de cada estado.              |
	; |                                                                 |
	; |Exemplo:                                                         |
	; |A movimentação do jogador do CAASO tem como númedo de estado 2   |
	; |então toda vez que o contador de estados assumir um              |
	; |valor múltiplo de 2 (2, 4, 8 ...), o jogo executará              |
	; |o estado de jogo da movimentação do jogador do CAASO             |
	; ===================================================================

	loadn r0, #0; Contador de estados de jogo iniciado em 0
	loadn r2, #0; Salva valor 0 para futuras operações

Main_loop:

	;      Leitura da entrada do teclado
	inchar r6

	; ======================
	; Movimentação do CAASO
	; Num de estado: 10
	; ======================

	loadn r1, #10
	mod   r1, r0, r1
	cmp   r1, r2
	ceq   Caaso

	; ======================
	; Chinelada do CAASO
	; Num de estado: 2
	; ======================

	loadn r1, #2
	mod   r1, r0, r1
	cmp   r1, r2
	ceq   ChineladaCaaso

	; ======================
	; Movimentação do Federupa
	; Num de estado: 10
	; ======================

	loadn r1, #10
	mod   r1, r0, r1
	cmp   r1, r2
	ceq   Federupa

	; ======================
	; Chinelada do Federupa
	; Num de estado: 2
	; ======================

	loadn r1, #2
	mod   r1, r0, r1
	cmp   r1, r2
	ceq   ChineladaFederupa

	; Verifica se alguém tomou uma chinelada

	call IsCaasoHit
	call IsFederupaHit

	; Mostra vidas dos jogadores

	call PrintValuesHud

	; Verifica se os jogadores tem vidas restantes

	call IsCaasoAlive
	call IsFederupaAlive

	call Delay; Controla o fps do jogo
	inc  r0; Incrementa o contador de estados do jogo
	jmp  Main_loop

	;                       ================== Cenários ==================
	;                       ----------------------- Game Over CAASO Win -----------------------------
	gameOverCaasoWinLinha0  : string "                                        "
	gameOverCaasoWinLinha1  : string "                                        "
	gameOverCaasoWinLinha2  : string "                                        "
	gameOverCaasoWinLinha3  : string "                                        "
	gameOverCaasoWinLinha4  : string "                                        "
	gameOverCaasoWinLinha5  : string "                                        "
	gameOverCaasoWinLinha6  : string "                                        "
	gameOverCaasoWinLinha7  : string "                                        "
	gameOverCaasoWinLinha8  : string "                                        "
	gameOverCaasoWinLinha9  : string "                                        "
	gameOverCaasoWinLinha10 : string "            XUPA FEDERUPA               "
	gameOverCaasoWinLinha11 : string "                                        "
	gameOverCaasoWinLinha12 : string "                                        "
	gameOverCaasoWinLinha13 : string "                                        "
	gameOverCaasoWinLinha14 : string "         VOCE QUER JOGAR                "
	gameOverCaasoWinLinha15 : string "            NOVAMENTE?                  "
	gameOverCaasoWinLinha16 : string "                                        "
	gameOverCaasoWinLinha17 : string "      S: JOGAR NOVAMENTE                "
	gameOverCaasoWinLinha18 : string "      N: IR CURTIR O TUSCA              "
	gameOverCaasoWinLinha19 : string "         (E A VITORIA SOBRE             "
	gameOverCaasoWinLinha20 : string "             A FEDERAL)                 "
	gameOverCaasoWinLinha21 : string "                                        "
	gameOverCaasoWinLinha22 : string "                                        "
	gameOverCaasoWinLinha23 : string "                                        "
	gameOverCaasoWinLinha24 : string "                                        "
	gameOverCaasoWinLinha25 : string "                                        "
	gameOverCaasoWinLinha26 : string "                                        "
	gameOverCaasoWinLinha27 : string "                                        "
	gameOverCaasoWinLinha28 : string "                                        "
	gameOverCaasoWinLinha29 : string "                                        "

	;                         ----------------------- Game Over Federal Win ------------------------------
	gameOverFederalWinLinha0  : string "                                        "
	gameOverFederalWinLinha1  : string "                                        "
	gameOverFederalWinLinha2  : string "                                        "
	gameOverFederalWinLinha3  : string "                                        "
	gameOverFederalWinLinha4  : string "                                        "
	gameOverFederalWinLinha5  : string "                                        "
	gameOverFederalWinLinha6  : string "                                        "
	gameOverFederalWinLinha7  : string "                                        "
	gameOverFederalWinLinha8  : string "                                        "
	gameOverFederalWinLinha9  : string "                                        "
	gameOverFederalWinLinha10 : string "                                        "
	gameOverFederalWinLinha11 : string "                                        "
	gameOverFederalWinLinha12 : string "                                        "
	gameOverFederalWinLinha13 : string "           XUPA CAASO                   "
	gameOverFederalWinLinha14 : string "                                        "
	gameOverFederalWinLinha15 : string "                                        "
	gameOverFederalWinLinha16 : string "                                        "
	gameOverFederalWinLinha17 : string "         VOCE QUER JOGAR                "
	gameOverFederalWinLinha18 : string "             NOVAMENTE?                 "
	gameOverFederalWinLinha19 : string "                                        "
	gameOverFederalWinLinha20 : string "     S: JOGAR NOVAMENTE                 "
	gameOverFederalWinLinha21 : string "     N: IR CURTIR O TUSCA               "
	gameOverFederalWinLinha22 : string "                                        "
	gameOverFederalWinLinha23 : string "                                        "
	gameOverFederalWinLinha24 : string "                                        "
	gameOverFederalWinLinha25 : string "                                        "
	gameOverFederalWinLinha26 : string "                                        "
	gameOverFederalWinLinha27 : string "                                        "
	gameOverFederalWinLinha28 : string "                                        "
	gameOverFederalWinLinha29 : string "                                        "

	;                      -------------------- Tela inicial do jogo -----------------------------
	screenStartGameLinha0  : string "                                        "
	screenStartGameLinha1  : string "                                        "
	screenStartGameLinha2  : string "                                        "
	screenStartGameLinha3  : string "                                        "
	screenStartGameLinha4  : string "                                        "
	screenStartGameLinha5  : string "               OUTLAW                   "
	screenStartGameLinha6  : string "           TUSCA EDITION                "
	screenStartGameLinha7  : string "                                        "
	screenStartGameLinha8  : string "                                        "
	screenStartGameLinha9  : string "          PRESSIONE ENTER               "
	screenStartGameLinha10 : string "            PARA JOGAR                  "
	screenStartGameLinha11 : string "                                        "
	screenStartGameLinha12 : string "                                        "
	screenStartGameLinha13 : string "                                        "
	screenStartGameLinha14 : string "                                        "
	screenStartGameLinha15 : string "                                        "
	screenStartGameLinha16 : string "                                        "
	screenStartGameLinha17 : string "                                        "
	screenStartGameLinha18 : string "                                        "
	screenStartGameLinha19 : string "                                        "
	screenStartGameLinha20 : string "                                        "
	screenStartGameLinha21 : string "                                        "
	screenStartGameLinha22 : string "                                        "
	screenStartGameLinha23 : string "                                        "
	screenStartGameLinha24 : string "                                        "
	screenStartGameLinha25 : string "                                        "
	screenStartGameLinha26 : string "                                        "
	screenStartGameLinha27 : string "                                        "
	screenStartGameLinha28 : string "                                        "
	screenStartGameLinha29 : string "                                        "

	;                     ------------------- Tela do tuturial do jogo ------------------------
	screenTuturialLinha0  : string "                                        "
	screenTuturialLinha1  : string "                                        "
	screenTuturialLinha2  : string "                                        "
	screenTuturialLinha3  : string "                                        "
	screenTuturialLinha4  : string "          COMO JOGAR?                   "
	screenTuturialLinha5  : string "                                        "
	screenTuturialLinha6  : string "                                        "
	screenTuturialLinha7  : string "           RACA CAASO                   "
	screenTuturialLinha8  : string "                                        "
	screenTuturialLinha9  : string "     A: ANDAR PARA A ESQUERDA           "
	screenTuturialLinha10 : string "     D: ANDAR PARA A DIREITA            "
	screenTuturialLinha11 : string "     ESPACO: DAR CHINELADA              "
	screenTuturialLinha12 : string "                                        "
	screenTuturialLinha13 : string "                                        "
	screenTuturialLinha14 : string "            FEDERUPA                    "
	screenTuturialLinha15 : string "     J: ANDAR PARA A ESQUERDA           "
	screenTuturialLinha16 : string "     K: ANDAR PARA A DIREITA            "
	screenTuturialLinha17 : string "     ENTER: DAR CHINELADA               "
	screenTuturialLinha18 : string "                                        "
	screenTuturialLinha19 : string "                                        "
	screenTuturialLinha20 : string "                                        "
	screenTuturialLinha21 : string "          PRESSIONE ENTER               "
	screenTuturialLinha22 : string "           PARA JOGAR                   "
	screenTuturialLinha23 : string "                                        "
	screenTuturialLinha24 : string "                                        "
	screenTuturialLinha25 : string "                                        "
	screenTuturialLinha26 : string "                                        "
	screenTuturialLinha27 : string "                                        "
	screenTuturialLinha28 : string "                                        "
	screenTuturialLinha29 : string "                                        "

	;                    ------------------ Tela final do jogo -------------------------------
	endGameScreenLinha0  : string "                                        "
	endGameScreenLinha1  : string "                                        "
	endGameScreenLinha2  : string "                                        "
	endGameScreenLinha3  : string "                                        "
	endGameScreenLinha4  : string "                                        "
	endGameScreenLinha5  : string "                                        "
	endGameScreenLinha6  : string "                                        "
	endGameScreenLinha7  : string "                                        "
	endGameScreenLinha8  : string "                                        "
	endGameScreenLinha9  : string "                                        "
	endGameScreenLinha10 : string "                                        "
	endGameScreenLinha11 : string "                                        "
	endGameScreenLinha12 : string "                                        "
	endGameScreenLinha13 : string "          OBRIGADO POR JOGAR            "
	endGameScreenLinha14 : string "                                        "
	endGameScreenLinha15 : string "                                        "
	endGameScreenLinha16 : string "                                        "
	endGameScreenLinha17 : string "                                        "
	endGameScreenLinha18 : string "                                        "
	endGameScreenLinha19 : string "                                        "
	endGameScreenLinha20 : string "                                        "
	endGameScreenLinha21 : string "                                        "
	endGameScreenLinha22 : string "                                        "
	endGameScreenLinha23 : string "                                        "
	endGameScreenLinha24 : string "                                        "
	endGameScreenLinha25 : string "                                        "
	endGameScreenLinha26 : string "                                        "
	endGameScreenLinha27 : string "                                        "
	endGameScreenLinha28 : string "                                        "
	endGameScreenLinha29 : string "                                        "

