; Pushes registers on to the stack in order
%macro PRESERVE 1-*
    %rep %0
        push %1
        %rotate 1
    %endrep
%endmacro

; Pops registers in reverse order
%macro RESTORE 1-*
    %rep %0
        %rotate -1
        pop %1
    %endrep
%endmacro

; Pushes Arguments in reverse order on to the stack
%macro ARGS 1-*
    %rep %0
        %rotate -1
        push %1
    %endrep
%endmacro

; Defines a function with bp saved and copied from stack
%macro FUNC 1
    %1:
        push bp
        mov bp, sp
%endmacro

; Gets the nth argument into register reg, argN (not byte offsets)
%macro ARG 2
    mov %1, [bp + 2*%2 + 4]
%endmacro

; Pops bp and pops N arguments from the stack then returns
%macro RETURN 1
    pop bp
    ret %1*2
%endmacro

%macro DUP 0
  pop AX
  push AX
  push AX
%endmacro
