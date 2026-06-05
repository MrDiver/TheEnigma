%include "macros.nasm"
[org 0x7c00]

cli
cld
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax

; Load SP immediately after SS while interrupts are masked.
mov sp, 0x9000
mov bp, sp
sti

; Go to Graphics Mode 80x25 Color
mov ah, 0x00
mov al, 0                               ; Mode
int 0x10

mov AH, 0x0E
mov AL, '>'
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
    ; call play_char
    jmp .inloop

  .space:
    mov AH, 0x0E
    int 0x10
    jmp .inloop

  .break:
    jmp $

FUNC enigma
  PRESERVE BX, CX, DX
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

  RESTORE BX, CX, DX
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
 ; %include "speaker.nasm"
 ; %include "timer.nasm"
 ; %include "beep.nasm"
 ; %include "generic.nasm"
 %warning Size is %eval($-$$) bytes

jmp $

USB_IMAGE_BYTES equ 1440 * 1024
USB_IMAGE_SECTORS equ USB_IMAGE_BYTES / 512
USB_PARTITION_LBA equ 1
USB_PARTITION_SECTORS equ USB_IMAGE_SECTORS - USB_PARTITION_LBA

; MBR partition table starts at byte 446.
times 446-($-$$) db 0x0

; Active partition entry for BIOSes that validate USB-HDD media.
db 0x80
db 0x00, 0x02, 0x00
db 0x0c
db 0xfe, 0xff, 0xff
dd USB_PARTITION_LBA
dd USB_PARTITION_SECTORS

times 510-($-$$) db 0x0
dw 0xaa55

;
;              END OF 512 BYTE SECTOR
;

times USB_IMAGE_BYTES-($-$$) db 0x0
