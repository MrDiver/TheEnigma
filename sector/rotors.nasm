struc RotorDef
  .rotation:   resb 1
  .notch:      resb 1
  .forward:    resb 26
endstruc

ROTORS:
dw ROTOR1, ROTOR2, ROTOR3

; AX - CX mod 26 -> AX
%macro SUBMOD26 0
    sub AL, CL
    jns %%done                          ; if positive, just mod
        add AL, 26                      ; wrap around
    %%done:
%endmacro

; AX + CX mod 26 -> AX
%macro ADDMOD26 0
    add AL, CL
    cmp AL, 26
    jl %%done
        sub AL, 26
    %%done:
%endmacro

; Position, Rotor -> AX = Next Position
FUNC Rotor_get
  PRESERVE BX, CX, DX

  ARG AX, 0                             ; AX = In Position
  ARG BX, 1                             ; BX = Rotor Addr
  ARG DX, 2                             ; XLAT oder SCAN

  mov CL, [BX + RotorDef.rotation]      ; CX Rotation

  ;AL, CL
  ADDMOD26

  add BX, RotorDef.forward
  call DX
  sub BX, RotorDef.forward

  ; AL, CL
  mov CL, [BX + RotorDef.rotation]      ; CX Rotation
  SUBMOD26

  RESTORE BX, CX, DX
  RETURN 3


; AX = Position, BX = Table Address -> AL = Next Position
Rotor_forward:
  xlat
  ret

; AX = Position, BX = Table Address -> AX = Next Position
Rotor_backward:
  mov SI, 26
  .scan:
    dec SI
    cmp [BX+SI],AL                      ; FWD[CX] == AL
    jnz .scan
  mov AX, SI
  ret

; BX = Rotor Adress
FUNC Rotor_step
  PRESERVE BX, CX
  ARG BX, 0

  mov CL, [BX + RotorDef.notch]         ; CX = Notch
  xor CH, CH

  mov AL, [BX + RotorDef.rotation]
  xor AH, AH                            ; AX = Rotation

  cmp AL, CL                            ; Check if notch passed
  setz CL

  push CX
  mov CX, 1
  ADDMOD26
  pop CX
  mov [BX], AL

  MOV AX, CX
  RESTORE BX, CX
  RETURN 1

Rotor_step_all:
  PRESERVE BX,CX
  mov BX, ROTORS+(3*2)
  
  .again:
    sub BX, 2
    mov CX, [BX]
    ARGS CX
    call Rotor_step
    cmp AX, 1
    jz .again

  RESTORE BX,CX
  ret 

