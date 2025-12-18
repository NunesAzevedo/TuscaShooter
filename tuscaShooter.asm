	call StartGameScreen
	call Tuturial
	jmp  Main

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
	hud : string " VIDAS CAASO:           VIDAS FEDERUPA: "

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
	; Passa por vários ciclos fazendo nada
	; afim de esperar o tempo de 1 segundo passar
	; no clock de 1 MHz em 2 loops de 1000 ciclos cada
	; fazendo gastar tempo de forma que:
	; (1000) * (1000) = 1 seg (Clock: 1 MHz)

Delay:

	push r0; Armazena quantidade de clocks ignorados
	push r1

	loadn r0, #1000

Delay_loop1:
	loadn r1, #1000

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
	push r2
	push r3
	push r4

	loadn r0, lifesCaaso
	loadn r1, #48; Fator de correção para tabela ASCII
	add   r0, r0, r1

	loadn   r1, #1168; Posição da tela para o print
	outchar r0, r1

	; Print das vidas

	load r1
	;    ########## FALTA TERMINAR PrintValuesHud ##########

	; Printa tela de Fim de jogo

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
	jeq    StartGameScreen

	loadn r1, #' '
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
	jeq    StartGameScreen

	loadn r1, #' '
	cmp   r0, r1
	jeq   EndGameScreen

	;   Se nenhuma tecla for precionada
	;   volta para o início do loop
	jmp GameOverFederalWin_ScanChar

	; ----- Tela de Início do Jogo -----

StartGameScreen:
	push r1
	push r2

	loadn, #screenStartGameLinha0; Primeiro endereço da tela
	loadn  r2, #0; Cor Branca
	call   PrintScreen

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
	loadn r2, #13

Tuturial_ScanChar:
	inchar r1
	cmp    r1, r2
	jne    Tuturial_ScanChar
	call   CleanScreen

	pop r2
	pop r1

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

	inchar r0

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
	jle   MoveCaasoRight_Skip; Não faz nada

	call EraseCaaso

	; Decrementa a posição do jogador do Caaso

	load  r0, posCaasoUp
	dec   r0
	store posCaasoUp, r0

	load  r0, posCaasoDown
	dec   r0
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

	load  r0, posChineloCaaso
	call  EraseCaasoChinelo
	loadn r2, #40; Move a posição do chinelo uma linha acima
	sub   r0, r0, r2

	; Verifica se ele atingiu a borda da tela

	loadn r1, #40
	cmp   r0, r1
	cle   ChineladaCaasoPassouPrimeiraLinha

	store posChineloCaaso, r0
	call  ChineladaCaasoDraw

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

	; Coloca flagChineladaCaaso como 0

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
	add   r1, r1, r6; Desloca para baixo o chinelo

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

	load  r2 posCaasoUp
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

	inchar r0

	loadn r1, #'j'
	cmp   r0, r1
	ceq   MoveFederupaLeft

	loadn r1, #'k'
	cmp   r0, r1
	ceq   MoveFederupaRight

	; Verifica se o jogador do Caaso
	; Atirou o chinelo

	loadn r1, #12; Enter = 12
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
	jle   MoveFederupaRight_Skip; Não faz nada

	call EraseFederupa

	; Decrementa a posição do jogador do Caaso

	load  r0, posFederupaUp
	dec   r0
	store posFederupaUp, r0

	load  r0, posFederupaDown
	dec   r0
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

	; --- Responsável pela Chinelada do jogador do CAASO ---

ChineladaCaaso:
	;=== FALTA IMPLEMENTAR ===

	; --- Responsável pela Chinelada do jogador da Federal ---

ChineladaFederupa:
	;=== FALTA IMPLEMENTAR ===

	; --- Verifica se o jogador do CAASO foi atingido ---

IsCaasoHit:
	push r0
	push r1

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

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do Federupa: Esquerda
	; Posição do jogador do CAASO   : Direita
	; =====================================

	inc r1; Posição da direita do CAASO
	cmp r0, r1
	ceq DecLifeCaaso

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do Federupa: Direita
	; Posição do jogador do CAASO   : Direita
	; =====================================

	inc r0; Posição da direita do chinelo
	cmp r0, r1
	ceq DecLifeCaaso

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do Federupa: Direita
	; Posição do jogador do CAASO   : Esquerda
	; =====================================

	dec r1; Posição esquerda do CAASO
	cmp r0, r1
	ceq DecLifeCaaso

	pop r1
	pop r0
	rts

	; --- Verifica se o jogador da Federal foi atingido ---

IsFederupaHit:
	push r0
	push r1

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

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do CAASO: Esquerda
	; Posição do Federupa        : Direita
	; =====================================

	inc r1; Posição da direita do federupa
	cmp r0, r1
	ceq DecLifeFederupa

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do CAASO: Direita
	; Posição do Federupa        : Direita
	; =====================================

	inc r0; Posição da direita do chinelo
	cmp r0, r1
	ceq DecLifeFederupa

	; =====================================
	; Compara
	; -------------------------------------
	; Posição do Chinelo do CAASO: Direita
	; Posição do Federupa        : Esquerda
	; =====================================

	dec r1; Posição esquerda do Federupa
	cmp r0, r1
	ceq DecLifeFederupa

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

	; Decrementa vidas do CAASO

	load  r0, lifesCaaso
	dec   r0
	store lifesCaaso, r0

	; Incrementa a vida do Federupa

	load  r0, lifesFederupa
	inc   r0
	store lifesFederupa, r0

	pop r0
	rts

	; --- Quando jogador do CAASO acerta o chinelo no Federupa ---

DecLifeFederupa:
	push r0

	; Decrementa a vida do Federupa

	load  r0, lifesFederupa
	dec   r0
	store lifesFederupa, r0

	; Incrementa a vida do CAASO

	load  r0, lifesCaaso
	inc   r0
	store lifesCaaso, r0

	pop r0
	rts

Main:
	call CleanScreen

	; ===================================
	; Setup inicial das variáveis do jogo
	; ===================================

	;     Salva quantidades de vidas
	;     dos jogadores
	loadn r0, #10
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
	jmp   Main_loop

Main_loop:
	;     ======================
	;     Movimentação do CAASO
	;     Num de estado: 10
	;     ======================
	loadn r1, #10
	mod   r1, r0, r1
	cmp   r1, r2
	ceq   MovimentacaoCaaso

	;     ======================
	;     Chinelada do CAASO
	;     Num de estado: 2
	;     ======================
	loadn r1, #2
	mod   r1, r0, r1
	cmp   r1, r2
	ceq   ChineladaCaaso

	;     ======================
	;     Movimentação do Federupa
	;     Num de estado: 30
	;     ======================
	loadn r1, #30
	mod   r1, r0, r1
	cmp   r1, r2
	ceq   MovimentacaoFederupa

	;     ======================
	;     Chinelada do Federupa
	;     Num de estado: 3
	;     ======================
	loadn r1, #3
	mod   r1, r0, r1
	cmp   r1, r2
	ceq   ChineladaFederupa

	;    Verifica se alguém tomou uma chinelada
	call IsCaasoHit
	call IsFederupaHit

	;    Mostra vidas dos jogadores
	call PrintValuesHud

	;    Verifica se os jogadores tem vidas restantes
	call IsCaasoAlive
	call IsFederupaAlive

	call Delay; Controla o fps do jogo
	inc  r0; Incrementa o contador de estados do jogo
	jmp  Main_loop

	;                      ================== Cenários ==================
	;                      Game Over CAASO Win
	gameOverCaasoWinLinha0 : string ""

	;                        Game Over Federal Win
	gameOverFederalWinLinha0 : string ""

	;                     Tela inicial do jogo
	screenStartGameLinha0 : string ""

	;                    Tela do tuturial do jogo
	screenTuturialLinha0 : string ""

	;                   Tela final do jogo
	endGameScreenLinha0 : string ""
