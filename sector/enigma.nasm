%include "macros.nasm"
[org 0x7c00]

; Stack 0x10000 - 0x1FFFF
mov ax, 0x1000
mov ss, ax
mov sp, 0xFFFF
mov bp, sp

; Go to Graphics Mode 80x25 Color
mov ah, 0x00
mov al, 3                               ; Mode
int 0x10

mainfunc:
  .inloop:
    mov AH, 0x00
    int 0x16
    xor AH, AH

    cmp AL, ' '
    jz .space

    cmp AL, 0x1B
    jz .break

    cmp AL, 'a'
    jl .bigalpha
      sub AL, 'a'
      jmp .endalpha
    .bigalpha:
      sub AL, 'A'
    .endalpha:

    ARGS AX
    call enigma
    call print_pos
    call play_char
    jmp .inloop

  .space:
    mov AH, 0x0E
    int 0x10
    jmp .inloop

  .break:
    jmp $

FUNC enigma
  ;PRESERVE BX, CX
  call Rotor_step_all
; INPUT HERE
  ARG AX, 0

  mov BX, ROTORS + 4
  .fowardloop:
    mov CX, [BX]

    ARGS AX, CX, Rotor_forward
    call Rotor_get

    ;call print_pos

    sub BX, 2
    cmp BX, ROTORS
    jae .fowardloop

  mov BX, REFLECTOR
  xlat

  ;call print_pos

  mov BX, ROTORS
  .backwardloop:
    mov CX, [BX]

    ARGS AX, CX, Rotor_backward
    call Rotor_get

    ;call print_pos

    add BX, 2
    cmp BX, ROTORS + 4
    jbe .backwardloop

  ;RESTORE BX, CX
  RETURN 1

print_pos:
  push ax
  mov AH, 0x0E                          ; Command
  add AL, 'A'
  int 0x10
  pop ax
  ret

%include "rotors_gen.nasm"
%include "rotors.nasm"
%warning Enigma is %eval($-$$) bytes
%include "speaker.nasm"
%include "timer.nasm"
%include "beep.nasm"
; %include "generic.nasm"
%warning Size is %eval($-$$) bytes

times 510-($-$$) db 0x0
dw 0xaa55
