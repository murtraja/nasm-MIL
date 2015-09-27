;=====================
; program to calculate
; data stats w/ math
; co processor
; 64 bit
;=====================

%include "macros.inc"
%include "functions.inc"

section .data
array dq 1.2, 2.3, 3.4, 4.5, 5.6
count dq 5
decimal dd 100000000

msgMean db "The mean is:",10
lenMean equ $-msgMean

msgVariance db "The variance is:", 10
lenVariance equ $-msgVariance

msgSD db "The standard deviation is:",10
lenSD equ $-msgSD

newLine db 10
point db '.'

section .bss
resMean resq 1
bcdMean rest 1
bcdVariance rest 1
bcdSD rest 1
temp resb 17

global _start

section .text
_start:
nop
nop

startgdb:
finit
fldz		; pushing 0 to top of stack
mov rsi, array
mov rcx, [count]

addNext:
fadd qword[rsi]
add rsi, 8	; to next quadword
loop addNext

fild qword[count]	; after this st1 will contain summation
fdiv st1, st0		; the result is stored in st1
fild dword[decimal]	; after this st1 will contain count, st2 = mean
fmul st0, st2		; making mean as integer by shifting point by 8 places
fbstp [bcdMean]		; storing the value

disp msgMean, lenMean
mov rsi, bcdMean	; for printFloat
mov rdi, temp		; ""
call printFloat		; printing the float
disp newLine, 1

variance:
		; st0 contains count
fstp st0
fldz		; it now contains summation initial value
		; st1 contains mean
mov rsi, array
mov rcx, qword[count]
varianceLoop:
fld qword[rsi]	; st1 = summation, st2 = mean
fsub st0, st2	
fmul st0, st0	; now add this value to summation
fadd st1, st0	; st1 contains updated summation
fstp st0		; popping the current array element
add rsi, 8	; go to next element
loop varianceLoop

fild qword[count]	; now st0 = count, st1 = summation, st2 = mean
fdiv st1, st0
fxch st1, st0		; now st0 = variance, st1 = count
fild dword[decimal]	; now st0 = 10^8, st1 = variance
fmul st0, st1		; multiplying...
fbstp [bcdVariance]	; getting bcd value for variance
fsqrt			; square root of variance
fild dword[decimal]
fmul st0, st1
fbstp [bcdSD]		; getting bcd value for standard deviation

printingValues:

disp msgVariance, lenVariance
mov rsi, bcdVariance
mov rdi, temp
call printFloat
disp newLine, 1

disp msgSD, lenSD
mov rsi, bcdSD
mov rdi, temp
call printFloat
disp newLine, 1
nop
nop
nop
exit
printFloat:
; load tbyte data's pointer to rsi
; load the 12 byte display variable in rdi
;
mov r14, rsi		; saving rsi
mov r15, rdi 		; saving rdi
mov cl, 12		; required to convert integer part
mov rsi, r15		; ""
mov rax, qword[r14+4]	; ""
call hexToAscii		; converting integer part
disp r15, 12		; printing it
disp point, 1		; printing '.'
mov cl, 8		; required to convert fraction part
mov rsi, r15		; ""
mov rax, 0		
mov eax, dword[r14]	; ""
call hexToAscii		; converting fractional part
disp temp, 8		; printing it
ret
