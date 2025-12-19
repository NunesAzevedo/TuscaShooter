; =====================
; Guarda "Oi" em r2 e r3
; =====================

LOADN r2, 'O'
LOADN r3, 'i'

OUTCHAR r2
OUTCHAR r3
LOADN r0, '\n'
OUTCHAR r0


; =====================
; Salva contexto r0–r3
; =====================

PUSHALL r3


; =====================
; Usa outros registradores
; =====================

LOADN r0, 'P'
OUTCHAR r0
LOADN r0, 'r'
OUTCHAR r0
LOADN r0, 'o'
OUTCHAR r0
LOADN r0, 'f'
OUTCHAR r0
LOADN r0, '\n'
OUTCHAR r0


; =====================
; Restaura contexto
; =====================

POPALL r3


; =====================
; Imprime "Oi" novamente
; =====================

OUTCHAR r2
OUTCHAR r3

HALT
