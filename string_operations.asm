;=====================
; program to perform
; basic string operations
; 64 bit
;=====================

%include "functions.inc"
%include "macros.inc"

section .data

msg0 db "This program deals with basic string operations.",10
len0 equ $-msg0

msg1 db "Enter the string (Max 31 chars): "
len1 equ $-msg1

msg2 db "Invalid string length! Please try again.", 10
len2 equ $-msg2

msg3 db "The length of the string is: "
len3 equ $-msg3

msg4 db "The string is a palindrome!",10
len4 equ $-msg4

msg5 db "The string is not a palindrome!",10
len5 equ $-msg5

menu db 10, "1. Calculate length", 10, "2. Reverse the string", 10, "3. Check for palindrome", 10, "4. Change string", 10, "*. Exit", 10, ">> "
lenMenu equ $-menu

newLine db 10

section .bss

temp resq 4		; for input output purposes
string resq 4		; to store the original string
strlen resb 1 		; this stores the length of the string

global _start


section .text

_start:
nop
startgdb:
nop
disp msg0, len0

getString:
disp msg1, len1
read temp, 64		; take the string
; special note
; if 32 is used and user enters a string > 32 chars
; then the enter won't be read, which implies that
; the getLength function goes in an infinite loop
mov rsi, temp
call getLength		; to check for its length
cmp cl, 31
ja printError
cmp cl, 0		; check whether it was a null string
jne saveString

printError:
disp msg2, len2		; say error
jmp getString

saveString:
mov byte[strlen], cl
mov rsi, temp		; the following lines
mov rdi, string		; save the string to 
inc cl			; dedicated memory
cld			; location with its length
rep movsb

menuDisplay:
disp menu, lenMenu

read temp, 2


cmp byte[temp], 31h
je calculateLength

cmp byte[temp], 32h
je reverseString

cmp byte[temp], 33h
je checkPalindrome

cmp byte[temp], 34h
je getString

jmp exit


;---------------------------
calculateLength:
mov rsi, string
call getLength
mov rax, rcx
mov cl, 2
mov rsi, temp
call hexToAscii
disp msg3, len3
disp temp, 2
disp newLine, 1
jmp menuDisplay
;---------------------------
reverseString:

; the reversed string will be stored in temp
movzx rcx, byte[strlen]
; the loop operation
; works with rcx
; and not with cl
mov rsi, string
mov ax, 0
pushing:
nop
movzx ax, byte[rsi]
nop
push ax
inc rsi
loop pushing

movzx rcx, byte[strlen]
mov rsi, temp
popping:
pop ax
mov byte[rsi], al
inc rsi
loop popping
mov byte[rsi], 10

mov rcx, 0
mov cl, byte[strlen]
inc cl
disp temp, rcx
jmp menuDisplay

;---------------------------
checkPalindrome:

; point rsi to start
; point rdi to end
; compare both values
; if equal continue
; else not a palindrome
; continue till strlen/2

mov rsi, string
mov rdi, string
movzx rax, byte[strlen]
dec rax
add rdi, rax		; it points to the last element
shr rax, 1		; this will divide the length by 2
mov rcx, rax

palindromeLoop:
mov al, byte[rsi]
cmp byte[rdi], al
jne notPalindrome
inc rsi
dec rdi
loop palindromeLoop

; string is palindrome
disp msg4, len4
jmp endCheckPalindrome

notPalindrome:
; string is not palindrome
disp msg5, len5

endCheckPalindrome:
jmp menuDisplay

;---------------------------
exit




