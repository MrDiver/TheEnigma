; Speaker - AX=1193180 / Frequence, BX=Ticks ; 18 ticks = 1 sec
beep:
  pusha
  call set_freq
  call speak_on
  SLEEP
  call speak_off
  popa
  ret

play_char:
  pusha
  xor AH, AH
  shl AX, 1
  mov BX, FREQTABLE
  add BX, AX
  mov AX, [BX]
  mov BX, 4
  call beep
  popa
  ret

FREQTABLE:
  dw 1193180/262, 1193180/277, 1193180/294, 1193180/311
  dw 1193180/330, 1193180/349, 1193180/370, 1193180/392
  dw 1193180/415, 1193180/440, 1193180/466, 1193180/494
  dw 1193180/523, 1193180/554, 1193180/587, 1193180/622
  dw 1193180/659, 1193180/698, 1193180/740, 1193180/784
  dw 1193180/831, 1193180/880, 1193180/932, 1193180/988
  dw 1193180/1047, 1193180/1109
