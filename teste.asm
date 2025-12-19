; r0 = 'A'
LOADN r0
65

; r1 = 'B'
LOADN r1
66

; r2 = 'C'
LOADN r2
67

OUTCHAR r0
OUTCHAR r1
OUTCHAR r2

PUSHALL r2   ; salva r0, r1, r2

; sobrescreve registradores
LOADN r0
120          ; 'x'
LOADN r1
121          ; 'y'
LOADN r2
122          ; 'z'

OUTCHAR r0
OUTCHAR r1
OUTCHAR r2

POPALL r2    ; restaura r2, r1, r0

OUTCHAR r0
OUTCHAR r1
OUTCHAR r2

HALT
