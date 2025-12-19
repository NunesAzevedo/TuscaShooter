/*
 * PROCESSADOR VON NEUMANN - SIMULADO
 * Compilar: gcc Von_Newmann.c -O3 -Wall -lm -o Von_Newmann
 * Executar: ./Von_Newmann
 * Requisito: Arquivo cpuram.mif na mesma pasta
 */

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <math.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>

// --- PARÂMETROS GERAIS ---
#define TAMANHO_PALAVRA 16
#define TAMANHO_MEMORIA 32768
#define MAX_VAL 65535
#define NUM_REGS 8  // Quantidade de registradores de uso geral

// --- ESTADOS DA MÁQUINA DE CONTROLE ---
#define STATE_RESET 0
#define STATE_FETCH 1
#define STATE_DECODE 2
#define STATE_EXECUTE 3
#define STATE_EXECUTE2 4
#define STATE_HALTED 5
#define STATE_PUSHALL 6
#define STATE_POPALL  7

// --- SELETORES DE MUX ---
// Mux1 (Endereçamento da Memória)
#define sPC 0
#define sMAR 1
#define sM4 2
#define sSP 3

// Mux2 (Escrita no Banco de Registradores)
#define sULA 0
#define sDATA_OUT 1
#define sM4 2
#define sSP 3
#define sTECLADO 4

// Mux5 (Dado para escrever na Memória)
#define sPC 0
#define sM3 1 // Valor de Rx

// Mux6 (Fonte das Flags)
#define sULA_FR 0
#define sDATA_OUT_FR 1

// --- OPCODES (INSTRUÇÕES) ---
// Data Manipulation
#define LOAD 48
#define STORE 49
#define LOADN 56
#define LOADI 60
#define STOREI 61
#define MOV 51

// I/O
#define OUTCHAR 50
#define INCHAR 53

// Arithmetic
#define ARITH 2
#define ADD 32
#define SUB 33
#define MULT 34
#define DIV 35
#define INC 36
#define LMOD 37

// Logic
#define LOGIC 1
#define LAND 18
#define LOR 19
#define LXOR 20
#define LNOT 21
#define SHIFT 16
#define CMP 22

// Flow Control
#define JMP 2
#define CALL 3
#define RTS 4
#define PUSH 5
#define POP 6
#define PUSHALL 10
#define POPALL  11

// Control
#define NOP 0
#define HALT 15
#define SETC 8
#define BREAKP 14

// --- FLAGS (REGISTER STATUS) ---
#define NEGATIVE 9
#define STACK_UNDERFLOW 8
#define STACK_OVERFLOW 7
#define DIV_BY_ZERO 6
#define ARITHMETIC_OVERFLOW 5
#define CARRY 4
#define ZERO 3
#define EQUAL 2
#define LESSER 1
#define GREATER 0

// --- VARIÁVEIS GLOBAIS DO SISTEMA ---
unsigned int MEMORY[TAMANHO_MEMORIA]; 
int reg[NUM_REGS]; 
int FR[16] = {0}; 

typedef struct _resultadoUla{
    unsigned int result;
    unsigned int auxFR;
} ResultadoUla;

// --- PROTÓTIPOS ---
void le_arquivo(void);
int processa_linha(char* linha);
int pega_pedaco(int ir, int a, int b);
unsigned int _rotl(const unsigned int value, int shift); // Auxiliares se precisar
unsigned int _rotr(const unsigned int value, int shift); // Auxiliares se precisar
ResultadoUla ULA(unsigned int x, unsigned int y, unsigned int OP, int carry);

// Função para detectar tecla sem Enter (Linux/Unix)
int kbhit(void) {
    struct termios oldt, newt;
    int ch;
    int oldf;
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);
    ch = getchar();
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    fcntl(STDIN_FILENO, F_SETFL, oldf);
    if(ch != EOF) {
        ungetc(ch, stdin);
        return 1;
    }
    return 0;
}

// --- MAIN ---
int main() {
    // CORREÇÃO CRÍTICA PARA WSL: Desativa buffer de saída
    setbuf(stdout, NULL);

    int i=0;
    int key=0;
    
    // Registradores internos do Processador
    int PC=0, IR=0, SP=0, MAR=0;
    int rx=0, ry=0, rz=0;
    
    // Sinais de Controle
    int COND=0, RW=0, DATA_OUT=0;
    int LoadPC=0, IncPC=0, LoadIR=0, LoadSP=0, IncSP=0, DecSP=0, LoadMAR=0, LoadFR=0;
    int selM1=0, selM2=0, selM3=0, selM4=0, selM5=0, selM6=0;
    int LoadReg[NUM_REGS] = {0};
    
    // Variáveis temporárias / Auxiliares
    int M1=0, M2=0, M3=0, M4=0, M5=0, M6=0;
    int carry=0;
    int opcode=0;
    int temp=0;
    unsigned char state=0;
    int OP=0;
    int TECLADO;
    ResultadoUla resultadoUla;
    int temp_reg_cnt = 0; // Controle para PUSHALL/POPALL

    le_arquivo();

inicio:
    printf("\nPROCESSADOR VON NEUMANN ICMC - Iniciando...\n");
    state = STATE_RESET;

loop:
    // --- ATUALIZAÇÃO DOS REGISTRADORES (Borda de Subida Virtual) ---
    if(LoadIR) IR = DATA_OUT;
    if(LoadPC) PC = DATA_OUT;
    if(IncPC) PC++;
    if(LoadMAR) MAR = DATA_OUT;
    if(LoadSP) SP = M4;
    
    // Pilha
    if(IncSP) SP++;
    if(DecSP) SP--;

    // Flags Register
    if(LoadFR) {
        for(i=16; i--; )
            FR[i] = pega_pedaco(M6, i, i);
    }

    // Carrega registradores de propósito geral (Reg Bank)
    rx = pega_pedaco(IR, 9, 7);
    ry = pega_pedaco(IR, 6, 4);
    rz = pega_pedaco(IR, 3, 1);

    // CORREÇÃO: Atualização genérica de registradores (para funcionar com POPALL dinâmico)
    for(i=0; i<NUM_REGS; i++) {
        if(LoadReg[i]) reg[i] = M2;
    }

    // Escrita na Memória
    if (RW == 1) MEMORY[M1] = M5;

    // --- RESET DOS SINAIS DE CONTROLE PARA O PRÓXIMO CICLO ---
    for(i=0; i<NUM_REGS; i++) { LoadReg[i] = 0; } // Chaves adicionadas
    RW = 0;
    LoadIR = 0; LoadMAR = 0; LoadPC = 0; IncPC = 0;
    LoadSP = 0; IncSP = 0; DecSP = 0; LoadFR = 0;
    
    // Valores padrão dos Muxes
    selM1 = sPC; selM2 = sDATA_OUT; selM3 = rx; selM4 = rz; selM5 = sM3; selM6 = sULA_FR;

    // --- MÁQUINA DE ESTADOS (CONTROL UNIT) ---
    switch(state) {
        case STATE_RESET:
            for(i=0; i<NUM_REGS; i++) reg[i] = 0;
            for(i=0; i<16; i++) FR[i] = 0;
            PC = 0;
            IR = 0;
            MAR = 0;
            SP = TAMANHO_MEMORIA - 1;
            state = STATE_FETCH;
            break;

        case STATE_FETCH:
            // Busca Instrução: IR <- MEM[PC], PC++
            selM1 = sPC;
            RW = 0;
            LoadIR = 1;
            IncPC = 1;
            state = STATE_DECODE;
            break;

        case STATE_DECODE:
            opcode = pega_pedaco(IR, 15, 10);
            
            // Definição padrão de operandos para ULA
            selM3 = ry; // Operando A
            selM4 = rz; // Operando B

            switch(opcode) {
                case INCHAR:
                    if(kbhit()) {
                        TECLADO = getchar();
                        TECLADO = pega_pedaco(TECLADO, 7, 0); 
                    } else {
                        TECLADO = 255;
                    }
                    selM2 = sTECLADO;
                    LoadReg[rx] = 1;
                    state = STATE_FETCH;
                    break;

                case OUTCHAR:
                    printf("%c", (char)reg[rx]);
                    fflush(stdout); 
                    state = STATE_FETCH;
                    break;

                case LOADN:
                    selM1 = sPC; 
                    RW = 0;
                    IncPC = 1;
                    if(pega_pedaco(IR, 0, 0) == 1) { 
                        selM2 = sDATA_OUT;
                        LoadReg[rx] = 1; 
                    } else {
                        selM2 = sDATA_OUT;
                        LoadReg[rx] = 1;
                    }
                    state = STATE_FETCH;
                    break;

                case LOAD:
                    selM1 = sPC;
                    LoadMAR = 1;
                    IncPC = 1;
                    state = STATE_EXECUTE;
                    break;

                case STORE:
                    selM1 = sPC;
                    LoadMAR = 1;
                    IncPC = 1;
                    state = STATE_EXECUTE;
                    break;

                case LOADI:
                    selM4 = ry; 
                    selM1 = sM4; 
                    selM2 = sDATA_OUT; 
                    LoadReg[rx] = 1;
                    state = STATE_FETCH;
                    break;

                case STOREI:
                    selM4 = rx; 
                    selM1 = sM4; 
                    selM3 = ry; 
                    selM5 = sM3; 
                    RW = 1;
                    state = STATE_FETCH;
                    break;

                case MOV:
                    OP = LAND;
                    selM3 = ry;
                    selM4 = ry;
                    selM2 = sULA;
                    LoadReg[rx] = 1;
                    selM6 = sULA_FR;
                    LoadFR = 1;
                    state = STATE_FETCH;
                    break;

                case ADD: case SUB: case MULT: case DIV: case LMOD:
                case LAND: case LOR: case LXOR: case LNOT: case CMP:
                    OP = opcode;
                    selM3 = ry;
                    selM4 = rz;
                    if(opcode != CMP) {
                        selM2 = sULA;
                        LoadReg[rx] = 1;
                    }
                    selM6 = sULA_FR;
                    LoadFR = 1;
                    state = STATE_FETCH;
                    break;

                case INC:
                    selM3 = rx;
                    selM4 = 8; 
                    if(pega_pedaco(IR, 6, 6) == 0) OP = ADD; 
                    else OP = SUB; 
                    selM2 = sULA;
                    LoadReg[rx] = 1;
                    selM6 = sULA_FR;
                    LoadFR = 1;
                    state = STATE_FETCH;
                    break;

                case SHIFT:
                    OP = SHIFT;
                    selM3 = rx;
                    selM4 = rz; // Shift amount
                    selM2 = sULA;
                    LoadReg[rx] = 1;
                    selM6 = sULA_FR;
                    LoadFR = 1;
                    state = STATE_FETCH;
                    break;

                case JMP:
                    COND = pega_pedaco(IR, 9, 6);
                    int cond_met = 0;
                    if(COND == 0) cond_met = 1;
                    else if(COND == 1 && FR[EQUAL]) cond_met = 1;
                    else if(COND == 2 && !FR[EQUAL]) cond_met = 1;
                    else if(COND == 3 && FR[ZERO]) cond_met = 1;
                    else if(COND == 4 && !FR[ZERO]) cond_met = 1;
                    else if(COND == 5 && FR[CARRY]) cond_met = 1;
                    else if(COND == 6 && !FR[CARRY]) cond_met = 1;
                    else if(COND == 7 && FR[GREATER]) cond_met = 1;
                    else if(COND == 8 && FR[LESSER]) cond_met = 1;
                    else if(COND == 9 && (FR[GREATER] || FR[EQUAL])) cond_met = 1;
                    else if(COND == 10 && (FR[LESSER] || FR[EQUAL])) cond_met = 1;
                    else if(COND == 11 && FR[ARITHMETIC_OVERFLOW]) cond_met = 1;
                    else if(COND == 12 && !FR[ARITHMETIC_OVERFLOW]) cond_met = 1;
                    else if(COND == 13 && FR[DIV_BY_ZERO]) cond_met = 1;
                    else if(COND == 14 && FR[NEGATIVE]) cond_met = 1;

                    if(cond_met) {
                        selM1 = sPC; 
                        LoadPC = 1;  
                        RW = 0;
                    } else {
                        IncPC = 1; 
                    }
                    state = STATE_FETCH;
                    break;

                case CALL:
                    selM1 = sPC;
                    LoadMAR = 1;
                    IncPC = 1;
                    state = STATE_EXECUTE; 
                    break;

                case PUSH:
                    selM3 = rx; 
                    selM5 = sM3;
                    selM1 = sSP; 
                    RW = 1;      
                    DecSP = 1;   
                    state = STATE_FETCH;
                    break;

                case POP:
                    IncSP = 1; 
                    state = STATE_EXECUTE;
                    break;

                case PUSHALL:
                    temp_reg_cnt = 0; // Começa do r0
                    state = STATE_PUSHALL;
                    break;

                case POPALL:
                    temp_reg_cnt = rx; // Começa do rX (ex: r7)
                    IncSP = 1; // POP começa incrementando
                    state = STATE_POPALL;
                    break;

                case RTS:
                    IncSP = 1;
                    state = STATE_EXECUTE;
                    break;

                case SETC:
                    FR[CARRY] = pega_pedaco(IR, 9, 9);
                    state = STATE_FETCH;
                    break;

                case HALT:
                    state = STATE_HALTED;
                    break;

                case NOP:
                    state = STATE_FETCH;
                    break;

                case BREAKP:
                    printf("BREAKPOINT - Press Enter");
                    getchar();
                    state = STATE_FETCH;
                    break;

                default:
                    state = STATE_FETCH;
                    break;
            }
            break;

        case STATE_EXECUTE:
            switch(opcode) {
                case LOAD:
                    selM1 = sMAR;
                    selM2 = sDATA_OUT;
                    LoadReg[rx] = 1;
                    state = STATE_FETCH;
                    break;

                case STORE:
                    selM1 = sMAR;
                    selM3 = rx;
                    selM5 = sM3;
                    RW = 1;
                    state = STATE_FETCH;
                    break;

                case CALL:
                    selM1 = sSP;
                    selM5 = sPC; 
                    RW = 1;
                    DecSP = 1;
                    state = STATE_EXECUTE2;
                    break;

                case POP:
                    selM1 = sSP;
                    selM2 = sDATA_OUT;
                    LoadReg[rx] = 1;
                    state = STATE_FETCH;
                    break;

                case RTS:
                    selM1 = sSP;
                    LoadPC = 1;
                    state = STATE_FETCH;
                    break;
            }
            break;

        case STATE_EXECUTE2:
            if (opcode == CALL) {
                PC = MAR;
                state = STATE_FETCH;
            }
            break;

        case STATE_PUSHALL:
            selM3 = temp_reg_cnt;
            selM5 = sM3;
            selM1 = sSP;
            RW = 1;
            DecSP = 1;
            temp_reg_cnt++;
            if (temp_reg_cnt > rx) {
                state = STATE_FETCH;
            }
            break;
 
        case STATE_POPALL:
            // IncSP já foi feito no ciclo anterior
            selM1 = sSP;
            selM2 = sDATA_OUT;
            LoadReg[temp_reg_cnt] = 1;
            
            // Prepara para o próximo
            temp_reg_cnt--;
            if (temp_reg_cnt < 0) {
                state = STATE_FETCH;
            } else {
                IncSP = 1; // Sobe a pilha
            }
            break;

        case STATE_HALTED:
            printf("\nHALTED. 'r' para reiniciar, 'q' para sair.\n");
            key = getchar();
            if (key == 'r') goto inicio;
            if (key == 'q') goto fim;
            break;
    }

    // --- EXECUÇÃO DO DATAPATH (Lógica Combinacional) ---

    // 1. Mux4 (Operando B da ULA)
    if(selM4 == 8) M4 = 1; // Constante 1
    else M4 = reg[selM4]; 

    // 2. Mux1 (Endereçamento)
    if (selM1 == sPC) M1 = PC;
    else if (selM1 == sMAR) M1 = MAR;
    else if (selM1 == sM4) M1 = M4;
    else if (selM1 == sSP) M1 = SP;
    else M1 = 0;

    // Proteção de Memória
    if(M1 >= TAMANHO_MEMORIA) {
        M1 = M1 % TAMANHO_MEMORIA; 
    }

    // 3. Leitura da Memória
    if (RW == 0) DATA_OUT = MEMORY[M1]; 

    // 4. Mux3 (Operando A da ULA)
    temp = 0;
    for(i=16; i--; ) temp = temp + (int)(FR[i] * pow(2.0, i));
    if(selM3 == 8) M3 = temp; 
    else M3 = reg[selM3]; 

    // 5. ULA
    resultadoUla = ULA(M3, M4, OP, carry);

    // 6. Mux2 (Seleção para escrever em Reg)
    if (selM2 == sULA) M2 = resultadoUla.result;
    else if (selM2 == sDATA_OUT) M2 = DATA_OUT;
    else if (selM2 == sM4) M2 = M4; 
    else if (selM2 == sTECLADO) M2 = TECLADO;
    else if (selM2 == sSP) M2 = SP;

    // 7. Mux5 (Dado para escrever na Memória)
    if (selM5 == sPC) M5 = PC;
    else if (selM5 == sM3) M5 = M3;

    // 8. Mux6 (Atualização de Flags)
    if (selM6 == sULA_FR) M6 = resultadoUla.auxFR;
    else if (selM6 == sDATA_OUT_FR) M6 = DATA_OUT; 
     
    goto loop;

fim:
    printf("\nSimulador encerrado.\n");
    return 0;
}

// --- FUNÇÕES AUXILIARES ---

void le_arquivo(void){
    FILE *stream; 
    int i, j;
    int processando = 0;
    char linha[110];

    if ((stream = fopen("cpuram.mif","r")) == NULL) {
        printf("Erro: Arquivo cpuram.mif não encontrado!\n");
        exit(1);
    }

    j = 0;
    while (fscanf(stream,"%s", linha)!=EOF) {
        char letra[2] = "00";
        if (!processando) {
            i = 0;
            do {
                letra[0] = letra[1];
                letra[1] = linha[i];
                if ((letra[0]=='0') && (letra[1]==':')) {
                    processando = 1;
                    j = 0;
                }
                i++;
            } while (linha[i] != '\0');
        }
        if (processando && (j < TAMANHO_MEMORIA)) {
            MEMORY[j] = processa_linha(linha);
            j++;
        }
    }
    fclose(stream);
}

int processa_linha(char* linha) {
    int i=0;
    int j=0;
    int valor=0;
    while (linha[i] != ':') {
        if (linha[i] == 0) return -1;
        i++;
    }
    valor = 0;
    for (j=0;j<16;j++) { 
        valor <<= 1; 
        valor += linha[i+j+1] - '0'; 
    }
    return valor;
}

int pega_pedaco(int ir, int a, int b) {
    int pedaco = ((1 << (a - b + 1)) - 1);
    pedaco = pedaco & (ir >> b);
    return pedaco;
}

ResultadoUla ULA(unsigned int x, unsigned int y, unsigned int OP, int carry) {
    unsigned int auxFRbits[16]={0};
    unsigned int result = 0;

    switch(pega_pedaco(OP, 5, 4)) {
        case ARITH:
            switch(OP) {
                case ADD:
                    result = x + y;
                    if(result > MAX_VAL) { auxFRbits[CARRY] = 1; result &= MAX_VAL; }
                    break;  
                case SUB:
                    result = x - y;
                    if((int)result < 0) { auxFRbits[NEGATIVE] = 1; result &= MAX_VAL; } 
                    if(x < y) auxFRbits[CARRY] = 1; 
                    break;  
                case MULT:
                    result = x * y;
                    if(result > MAX_VAL) { auxFRbits[ARITHMETIC_OVERFLOW] = 1; result &= MAX_VAL; }
                    break;  
                case DIV:
                    if(y==0) { result = 0; auxFRbits[DIV_BY_ZERO] = 1; }
                    else { result = x / y; }
                    break;  
                case LMOD:
                    if(y==0) { result = 0; auxFRbits[DIV_BY_ZERO] = 1; }
                    else { result = x % y; }
                    break;  
                default: result = x;
            }
            if(result == 0) auxFRbits[ZERO] = 1;
            break;

        case LOGIC:
            if(OP==CMP) {
                result = x;
                if(x > y) auxFRbits[GREATER] = 1;
                else if(x < y) auxFRbits[LESSER] = 1;
                else auxFRbits[EQUAL] = 1;
                if(x==0) auxFRbits[ZERO] = 1; 
            } else {
                switch(OP) {
                    case LAND: result = x & y; break;
                    case LXOR: result = x ^ y; break;
                    case LOR:  result = x | y; break;
                    case LNOT: result = ~x & MAX_VAL; break;
                    case SHIFT:
                        // Simples Shift Left (Lógico) pelo valor de y
                        if (y == 0) y = 1; 
                        result = (x << y) & MAX_VAL;
                        break;
                    default: result = x;
                }
                if(result == 0) auxFRbits[ZERO] = 1;
            }
            break;
    }

    // Reconstrói FR
    unsigned int auxFR = 0;
    for(int i=0; i<16; i++) 
        if(auxFRbits[i]) auxFR += (1 << i);

    ResultadoUla res;
    res.result = result;
    res.auxFR = auxFR;
    return res;
}
