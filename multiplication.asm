;=====================
; program to implement
; multiplication algorithms
; 64 bit
;=====================

%include "macros.inc"
%include "functions.inc"

section .data

menu db "1. Successive Addition", 10, "2. Booth's Algorithm", 10, "3. Change numbers", 10, "*. Exit", 10, ">> "
lenMenu equ $-menu

msg1 db "Enter the multiplicand (max 2 digits): "
len1 equ $-msg1

msg2 db "Enter the multiplier (max 2 digits): "
len2 equ $-msg2

newLine db 10

equalTo db " = -"
lenEqualTo equ $-equalTo

section .bss

temp resb 4
multiplicand resb 1
multiplier resb 1
result resw 1

global _start

section .text

_start:
nop
startgdb:
nop

takeInput:

disp msg1, len1
read temp, 3
mov rcx, rax
dec rcx
mov rsi, temp
call asciiToHex
mov byte[multiplicand], al

disp msg2, len2
read temp, 3
mov rcx, rax
dec rcx
mov rsi, temp
call asciiToHex
mov byte[multiplier], al

displayMenu:
disp menu, lenMenu
read temp, 2
cmp byte[temp], 31h
je succAddition
cmp byte[temp], 32h
je boothsAlgo
cmp byte[temp], 33h
je takeInput
exit

succAddition:

movzx rcx, byte[multiplier]
mov rax, 0
movzx rbx, byte[multiplicand]

addMultiplier:
cmp rcx, 0
je endAddition
add rax, rbx
loop addMultiplier 

endAddition:
mov word[result], ax
mov rsi, temp
mov rcx, 4
call hexToAscii
disp temp, 4
disp newLine, 1
jmp displayMenu

boothsAlgo:

; //bl will contain status of Q-1
; //al will contain 8 bits multiplier (Q register)
; //ah will be zero (Accumulator A)
; //bh will contain the multiplicand ( M )
; so that SAR will be applied to ax as a whole
; setb dest -> sets dest = 1 if carry 1 else 0
; sar -> has last bit shifted out in carry
; ____________________________________
; general overlay of booth's algorithm
; accumulator	register q	q-1
; 00000000	multiplier	0

; initialization steps
mov ah, 0
mov cl, 8
mov bh, byte[multiplicand]
mov al, byte[multiplier]
mov bl, 0

boothAlgoLoop:

cmp bl, 0
je nestedIf

; here Q-1 = 1			; Q0	Q-1
bt ax, 0
jc update			; 1	1
; here Q0 = 0
jmp addMultiplicand		; 0	1

nestedIf:
; here Q-1=0
bt ax, 0
jnc update			; 0	0
; here Q0=1
; so go to subMultiplicand	; 1	0

subMultiplicand:
sub ah, byte[multiplicand]
jmp update

addMultiplicand:
add ah, byte[multiplicand]

update:
sar ax,1
setb bl
dec cl
jnz boothAlgoLoop

; now the product is in register AQ i.e. ax
movzx r15, ax	; i need to store the product to check whether it is negative
mov rsi, temp
mov cl, 4
movzx rax, ax
call hexToAscii
disp temp, 4

; check whether the product is negative
cmp r15w, 0
jge printNewLine

; so now, ax is negative
; print the = -
disp equalTo, lenEqualTo
; now load the product back
mov ax, r15w

neg ax		; getting the two's complement
movzx rax, ax	; for conversion
mov rsi, temp
mov cl, 4	; 4 digits
call hexToAscii
disp temp, 4


printNewLine:
disp newLine, 1
jmp displayMenu
