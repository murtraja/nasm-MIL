;=====================
; program to add <=F <=10
; digit nos 
; 64 bit
;=====================

%include "functions.inc"
%include "macros.inc"
section .data
msg1 db "Enter the no. of elements (max F): "
len1 equ $-msg1

msg2_a db "Enter the no. "
len2_a equ $-msg2_a

msg2_b db ":   "
len2_b equ $-msg2_b

msg3 db "The summation is: "
len3 equ $-msg3

newLine db 10
space db 32

section .bss
count resb 1	; counter for loop
i resb 1	; i stores the serial of current input no.
temp resb 17	; for printing and input
number resq 1	; hex number stored here
sum resq 1	; sum of hex numbers
carry resb 1	; this takes care of the carry digit

global _start

section .text



_start:
nop
startgdb:
nop
disp msg1,len1

read temp, 2
mov esi, temp		; for conversion
mov cl, 1		; for conversion
call asciiToHex		; converting
mov byte[count], al	; converted result is in rax
nop
nop

mov byte[i], 31h	; initializing i with '1'
mov byte[carry], 0	; initializing carry with 0
start:
disp msg2_a, len2_a	
disp i,1
disp msg2_b, len2_b
cmp byte[i], 39h	; this is done to update i
jne incr		; from 9 to A
add byte[i], 7		; 'A' - '9' = 7+1	
incr:
inc byte[i]		
read temp, 17		; reading the number
mov esi, temp		; for getLength
call getLength		; result is in cl
mov esi, temp		; for conversion
call asciiToHex
; cl was updated by getLength
; the result is stored in rax
add qword[sum], rax	; adding the entered no.
jnc update		; the following lines check
inc byte[carry]		; for carry and updates it
update:
dec byte[count]
jnz start

disp msg3,len3		; displaying result
cmp byte[carry], 0	; was there a carry?
je printSpace		; no? then print space
mov esi, temp		; else print it after
mov rax, 0		; converting to ascii
mov al, byte[carry]	; for conversion
mov cl, 1		; for conversion
call hexToAscii
disp temp, 1		;
jmp printSum		; 

printSpace:
disp space,1

printSum:
mov rax, qword[sum]
mov rcx, 0
call getDigits
mov r8, rcx
mov rax, qword[sum]	; convert and print sum
mov esi, temp		; for conversion
call hexToAscii
disp temp, r8
disp newLine, 1



nop
nop
nop
exit
