;=====================
; program to interconvert
; base 10 with 16
; 64 bit
;=====================

%include"functions.inc"
%include"macros.inc"
section .data

menu db 10, "1. Hex to BCD", 10, "2. BCD to Hex", 10, "*. Exit", 10, ">> "
lenMenu equ $-menu

msg1 db "Now Exiting!", 10
len1 equ $-msg1

msg2 db "Please enter the Hex no (max 16 digits): "
len2 equ $-msg2

msg3 db "Please enter the BCD no (max 19 digits): "
len3 equ $-msg3

msg4 db "The converted Hex no. is: "
len4 equ $-msg4

msg5 db "The converted BCD no. is : "
len5 equ $-msg5

newLine db 10

section .bss
temp resb 20
hexNo resq 2
bcdNo:	resq 2
 	resd 1
;ffffffffffffffff=18446744073709551615
; 16 digit hex = 20 digit bcd
count resb 1


global _start
section .text

_start:
nop
startgdb:
nop
displayMenu:		; this simply displays the menu and check for choice
disp menu, lenMenu
read temp, 2
cmp byte[temp], 0x31
je hexToBcd
cmp byte[temp], 0x32
je BcdToHex
disp msg1, len1
exit

hexToBcd:
nop
disp msg2, len2
read temp, 17		; max 16 digits can be converted
disp msg5, len5
mov rsi, temp		; for getting length
call getLength		
mov byte[count], cl	; storing the length
mov rsi, temp		; for converting to hex
call asciiToHex		
;;;;;;;mov qword[hexNo], rax	; storing the converted no.

mov r9, bcdNo
add r9, 15		; r9 -> last location of bcdNo
hexToBcdLoop:
mov edx, 0		; necessary to avoid an arithmetic exception
mov rbx, 10
div rbx
mov [r9], dl		; storing the last digit
add byte[r9], 30h	; in ascii form itself
dec r9
cmp rax, 0
jne hexToBcdLoop
mov rcx, bcdNo		; in the following lines, the total digits
add rcx, 15		; in the converted no. is calculated by
sub rcx, r9		; making use of addresses, result in rcx
inc r9			; to make sure r9 -> first digit of bcd no

disp r9, rcx
disp newLine, 1
jmp displayMenu


BcdToHex:
nop
disp msg3, len3
read temp, 20		; max 19 digits can be converted
disp msg4, len4
mov rsi, temp
call getLength		; result is stored in rcx
mov r9, temp		; r9 -> MSB of BCD no (ascii)
mov r10, 0xa		; for multiplication
mov rax, 0		; initial value
BcdToHexLoop:
mul r10			; multiplying rax by 10
sub byte[r9], 30h	; getting proper no
movzx rdx, byte[r9]	; to avoid carry problems
add rax, rdx		; 64 bit reg are added
inc r9			; next digit
loop BcdToHexLoop

mov qword[hexNo], rax	; to save the newly converted no.
call getDigits		; so that we know how many to print
mov byte[count], cl	; saving the digits
mov rax, qword[hexNo]	; reloading hex no into rax for conversion to ascii
mov esi, temp		; for conversion to ascii
call hexToAscii
movzx rcx, byte[count]	; to display
disp temp, rcx
disp newLine, 1
jmp displayMenu

