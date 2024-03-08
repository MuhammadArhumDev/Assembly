; Program Description: Assembly language
; Author: Muhammad Arhum
; Creation Date: 01/03/2024
; Revisions: 
; Date: 01/03/2024     Modified by: Muhammad Arhum

.386
.model flat, stdcall
.stack 4096
INCLUDE irvine32.inc
ExitProcess PROTO, dwExitCode:DWORD

.data
	; declare variables here
	msg BYTE "Hello World!", 0

.code
main PROC
	; write your code here
	mov edx, offset msg
	call WriteString

main ENDP

; (insert additional procedures here)
END main
