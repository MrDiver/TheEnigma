
; Print Position as Character - AL = Position 0-25 BL=Color
print_pos_color:
  pusha
  mov ah, 0x09                          ; Command
  ; add al, 'A'                         ; Character
  xor bh, bh                            ; Page 0
  mov cx, 0x1
  ;mov bl, 0x01                         ; Attribute
  int 0x10
  popa
  ret

mov_cursor:
  pusha
  mov ah, 0x03                          ; Read position
  xor bh, bh                            ; Page 0
  int 0x10
  inc dl                                ; Increment Position
  cmp dl, 80
  jle continue_cursor_move              ; Cursor x > 80
    xor dl, dl
    inc dh
    cmp dh, 24
    jle continue_cursor_move
      call scroll_one
      dec dh
  continue_cursor_move:
  mov ah, 0x02                          ; Write Position
  xor bh, bh
  int 0x10
  popa
  ret

; AL = Lines to Scroll
scroll_one:
  pusha
  mov ah, 0x06                          ; scroll up
  ;mov al, 1                             ; lines to scroll
  xor cx, cx                            ; top-left 0,0
  mov dx, 0x184f                        ; bottom-right 24,79
  mov bh, 0x07                          ; fill attribute
  int 0x10
  popa
  return
