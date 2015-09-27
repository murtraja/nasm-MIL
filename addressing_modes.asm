;=====================
; program to demonstrate
; block data transfer
; overlap and non overlap
; forward, w/ and w/o
; using string instructions 
; 64 bit
;=====================


%include"functions.inc"
%include"macros.inc"

section .data

msg0 db "Please enter the no. of elements you wish to enter (Max F): "
len0 equ $-msg0

msg1 db "You have entered an invalid input!", 10
len1 equ $-msg1

msg2_a db "Enter the no. "
len2_a equ $-msg2_a

msg2_b db ": "
len2_b equ $-msg2_b

msg3 db " ---> "
len3 equ $-msg3

msg4 db "Input Block:",10
len4 equ $-msg4

msg5 db "Output Block: ", 10
len5 equ $-msg5

msg6_a db "Please specify the offset (Max "
len6_a equ $-msg6_a

msg6_b db "): "
len6_b equ $-msg6_b

menu db "1. Non Overlap Block Data Transfer",10,"2. Overlap Block Data Transfer", 10,">> "
lenMenu equ $-menu


newLine db 10

count db 0

i db 31h

section .bss
overlapBlock resq 30
; reserving 14*2 quadwords for overlapping
; the 29th and 30th one if for "0xa"

inputBlock resq 32	
; reserving 15*2 quadwords for the input
; the 16th and 17th one is for "0xa"

nonOverlapBlock resq 32
temp resb 17		; for input/output
offset resb 1		; to store the max offset

global _start

section .text

_start:
nop
startgdb:
nop
disp msg0, len0		; enter count
read temp, 2
mov esi, temp		; for conversion
mov cl, 1		; for conversion
call asciiToHex		; converting count
mov byte[count], al	; storing count to memory
movzx r15, byte[count]	; for loop condition


; the input is a 17 byte ascii no.
; i.e. 16 digits + 1 enterKey
; but it should also work for
; digits<16. So copy the last
; bytes first i.e. LSBs
; and put 30h in MSBs


mov r9, inputBlock
;r9 will keep track of
;the starting address of
; each element in the array

takeInput:
disp msg2_a, len2_a	
disp i,1
disp msg2_b, len2_b
cmp byte[i], 39h	; this is done to update i
jne incr		; from 9 to A
add byte[i], 7		; 'A' - '9' = 7+1	
incr:
inc byte[i]		
read temp, 17		; reading the number
mov rsi, temp		; to get the length of no
call getLength		; the result is in rcx
mov r10, 16		; r10 will store the 
sub r10, rcx		; value = 16-length
mov rsi, temp		; rsi=temp+length
add rsi, rcx		; i.e. rsi points to "0xa"
mov rdi, r9		; rdi points to last
add rdi, 16		; byte of array element
std			; decrement the addresses
inc rcx			; coz we are transferring "0xa" also
rep movsb 		; transfer to inputBlock
mov rcx, r10		; loading difference, for loop
cmp rcx, 0		; this is important as user may have already entered a 16 digit no.
je update
copy0:
mov byte[rdi],30h	; copying '0'
dec rdi
loop copy0
update:
add r9, 17		; next address
dec r15			; update counter
jnz takeInput




showMenu:
disp menu, lenMenu
read temp, 2		; reading choice	
cmp byte[temp], 31h	; if 1
je nonOverlap
cmp byte[temp], 32h	; if 2
je overlap
disp msg1, len1		; if wrong choice
jmp showMenu

nonOverlap:
nop
disp msg4, len4		; input block
mov r9, inputBlock	; for printing block
call printBlock
disp newLine, 1

movzx rcx, byte[count]		; cl will contain count
add rcx,rcx			; required for transfer
cld				; addresses to be incremented
mov rsi, inputBlock		; for movsq
mov rdi, nonOverlapBlock	; for movsq
rep movsq			; actual copy
movzx rcx, byte[count]		; this will take care of 
rep movsb			; "0xa"s

disp msg5, len5			; non-overlap block
mov r9, nonOverlapBlock		; for printing block
call printBlock

jmp end

overlap:
nop
takeOffset:
disp msg6_a, len6_a
; here we need to calculate the max offset
; that the user can give - it can be calculated as
; offset = count - 1
movzx rax, byte[count]
dec rax
mov rcx, 1		; for conversion to ascii
mov rsi, offset		; for conversion
call hexToAscii	
disp offset, 1
disp msg6_b, len6_b


read temp, 2
; now we check the max offset with
; the input offset	
mov bl, byte[offset]
cmp byte[temp], bl		; note that offset and temp both are in ascii
jbe checkZero
jmp errorState

checkZero:		; this will make sure that the input is greater than '0'
cmp byte[temp], 30h
ja beginOverlap

errorState:		; this will display proper error message and retake the input
disp msg1, len1
jmp takeOffset

beginOverlap:

mov rsi, temp
mov rcx, 1
call asciiToHex
mov byte[offset], al	; note we are over writing the max offset with user input offset

disp msg4, len4		; input block
mov r9, inputBlock	; for printing block
call printBlock
disp newLine, 1



; now r9 must point to the start of overlap block
; r9 = inputBlock - offset*17 
mov rax, 17
movzx rbx, byte[offset]
mul rbx
mov r9, inputBlock
sub r9, rax			; r9 -> overlapBlock
mov r14, r9			; saving r9 for printing
mov r10, inputBlock		; r10 -> inputBlock
; one no. is of 17 bytes
; implies total bytes = 17*count bytes
movzx rax, byte[count]
mov rbx, 17
mul rbx
mov rcx, rax			; stores the loop end condition

overlapLoop:

mov al, [r10]			; storing inputBlock's data in al
mov [r9], al			; overlapBlock is now getting filled
inc r9
inc r10				; updation
loop overlapLoop		; loop until rcx reaches zero

disp msg5, len5
mov r9, r14
call printBlock
jmp end

end:
exit

;======================
; this function prints the address
; and the value contained at that address
; just load the starting address in r9
printBlock:

movzx r15, byte[count]		; storing count

displayAdd:				

mov rax, r9			; for conversion
mov cl, 16			; for conversion
mov rsi, temp			; for conversion
call hexToAscii

disp temp, 16			; printing the address
disp msg3, len3			; printing "--->"

disp r9, 17			; printing the value

add r9, 17
dec r15
jnz displayAdd
ret


