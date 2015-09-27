;===============================
; load the ascii string in rsi
; the length will be stored in cl
getLength:
	mov rcx, 0
getLengthLoop:
	cmp byte[rsi], 10
	je getLengthReturn
	inc rsi
	inc cl
	jmp getLengthLoop
getLengthReturn:
	ret
;===============================
; load the no in rax
; the digits will be stored in cl
getDigits:
	mov rcx, 0	
	cmp rax, 0
	jne getDigitsLoop	
	mov rcx, 1
	jmp getDigitsReturn
getDigitsLoop:
	cmp rax, 0
	je getDigitsReturn
	inc cl
	shr rax, 4	;DON'T USE 'SAR'
	jmp getDigitsLoop
getDigitsReturn:
	ret
;===============================
; 1. load hex value in rax
; 2. load ascii in rsi
; 3. load no. of digits in cl
hexToAscii:
	mov rbx, 0
	mov bl, cl
	add rsi, rbx
hexToAsciiLoop:
	mov bl, al
	shr rax, 4
	and bl, 0fh
	cmp bl, 9
	jbe hexToAsciiAdd30
	add bl, 7
hexToAsciiAdd30:
	add bl, 30h
	dec rsi
	mov [rsi], bl
	dec cl
	jnz hexToAsciiLoop
ret
;=================================
; 1. load Ascii in rsi (rsi->MSD)
; 2. hex no. is calculated in rax
; 3. load cl with no. of digits
asciiToHex:
	mov rax, 0
asciiToHexLoop:
	mov bl, [rsi]
	cmp bl, 61h
	jb asciiToHexCapital
	sub bl, 20h
asciiToHexCapital:
	cmp bl, 39h
	jbe asciiToHexSub30
	sub bl, 7
asciiToHexSub30:
	sub bl, 30h
	rol rax, 4
	add al, bl
	inc rsi
	dec cl
	jnz asciiToHexLoop
ret
