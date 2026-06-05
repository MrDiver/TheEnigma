; Frequenz Setzen - AX = Frequency
set_freq: 
  pusha
  ; PIT konfigurierung
  mov bx, ax
  mov al, 0xB6 ; 2 channel mode 3 square wave, binary
  out 0x43, al
  mov ax, bx
  out 0x42, al ; low byte
  mov al, ah
  out 0x42, al ; high byte
  popa
  ret

; Speaker aktivieren
speak_on:
  pusha
  in al, 0x61
  or al, 3
  out 0x61, al
  popa
  ret

speak_off:
  pusha
  in al, 0x61
  and al, 0xFC
  out 0x61, al
  popa
  ret
