;=====================
; program to perform
; some string operations
; using far procedures 
; 64 bit
;=====================

global _start
global string1
global string2
global string3

section .data

msg1 db "This is main program", 10
len1 equ $-msg1

menu db 10, "1. Compare two strings", 10, "2. Concatenate two strings", 10, "3. Find substring", 10, "4. Change strings", 10, "*. Exit", 10, ">> "
lenMenu equ $-menu

section .bss

temp resb 2
string1 resq 4
string2 resq 4
string3 resq 8


extern inputStrings
extern farProcedure
extern compare
extern concatenate
extern substring

section .text

_start:
nop

startgdb:
nop

call inputStrings

displayMenu:
mov rax, 1
mov rdi, 1
mov rsi, menu
mov rdx, lenMenu
syscall

mov rax, 0
mov rdi, 1
mov rsi, temp
mov rdx, 2
syscall

cmp byte[temp], 31h
je compareMain
cmp byte[temp], 32h
je concatenateMain
cmp byte[temp], 33h
je substringMain
cmp byte[temp], 34h
je inputStringsMain
jmp exitMain

compareMain:
call compare
jmp displayMenu

concatenateMain:
call concatenate
jmp displayMenu

substringMain:
call substring
jmp displayMenu

inputStringsMain:
call inputStrings
jmp displayMenu

exitMain:
mov rax, 60
mov rdi, 0
syscall
