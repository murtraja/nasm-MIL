;=====================
; program to the helper program
; for asg5.asm
; 64 bit
;=====================

%include "macros.inc"
%include "functions.inc"
section .data

msg1 db "Enter the primary string:   "
len1 equ $-msg1

msg2 db "Enter the secondary string: "
len2 equ $-msg2

msg3 db "The concatenated string: "
len3 equ $-msg3

msg4 db "The strings are unequal!", 10
len4 equ $-msg4

msg5 db "The strings are equal!", 10
len5 equ $-msg5

msg6 db "The substring was not found!", 10
len6 equ $-msg6

msg7 db "The count of the substring is: "
len7 equ $-msg7



newLine db 10

strLen equ 32

section .bss

str1Len resb 1
str2Len resb 1
count resb 2

global inputStrings
global compare
global concatenate
global substring
extern string1
extern string2
extern string3

section .text

returnToMain:
ret

;==========================================
inputStrings:
disp msg1, len1
read string1, strLen
dec al
mov byte[str1Len], al

disp msg2, len2
read string2, strLen
dec al
mov byte[str2Len], al
jmp returnToMain

;==========================================
compare:

cmp al, byte[str1Len]
jne displayUnequal

mov rsi, string1
mov rdi, string2
movzx rcx, al
compareLoop:
mov al, byte[rsi]
cmp al, byte[rdi]
jne displayUnequal
inc rsi
inc rdi
loop compareLoop

displayEqual:
disp msg5, len5
jmp returnToMain

displayUnequal:
disp msg4, len4
jmp returnToMain


;=====================================
concatenate:

disp msg3, len3
; now we copy the string1 to string3
; let rdi point to string3
; and rsi point to string1
mov rsi, string1
mov rdi, string3
movzx rcx, byte[str1Len]	; note the enter will not get copied
rep movsb

; now we need to change rsi so that it will point to
; string2. we need not change rdi
mov rsi, string2
movzx rcx, byte[str2Len]
inc rcx			; this will also copy enter
rep movsb

; now in order to display we need to calculate
; the total length of the concatenated string
movzx rcx, byte[str1Len]
movzx rax, byte[str2Len]
add rcx, rax
inc rcx

disp string3, rcx

jmp returnToMain

;======================================================
substring:

cmp byte[str1Len], al
jb notFound
cmp byte[str2Len], 0
je notFound

; logic: get a character match 
; if matched, then run a loop
; till the length of the substring
; if the consecutive characters match
; then increment count
mov rsi, string1
mov ch, byte[str1Len]
mov byte[count], 0

substringLoop:
mov al, byte[rsi]
cmp al, byte[string2]
jne updateVariables

mov cl, byte[str2Len]
dec cl			; now we need to check the rest of characters
cmp cl, 0		; if length of substring is 1
je incrementCount

mov r8, rsi
inc r8			; already rsi is checked with string2
mov rdi, string2+1	; so go for the next characters

innerLoop:
mov al, byte[rdi]
cmp byte[r8], al
jne updateVariables
inc r8
inc rdi
dec cl
jnz innerLoop

incrementCount:
inc byte[count]

updateVariables:
inc rsi
dec ch
jnz substringLoop

cmp byte[count], 0
jne Found
notFound:
disp msg6, len6
jmp returnToMain

Found:
disp msg7, len7
movzx rax, byte[count]
mov rsi, count
mov rcx, 2
call hexToAscii
disp count, 2
disp newLine, 1
jmp returnToMain




