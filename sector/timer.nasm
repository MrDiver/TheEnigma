; Reset clock - no param

%macro CLOCK_RESET 0
  mov ah, 0x01 ; Reset clock with CX:DX
  xor CX, CX
  xor DX, DX
  int 0x1A
%endmacro

; Ticks BX - 18 = 1 sec
%macro SLEEP 0
  CLOCK_RESET
  %%wait:
    xor AH, AH ; Read Ticks CX:DX
    int 0x1A
    cmp dx, bx
    jb %%wait
%endmacro
