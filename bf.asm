; Using the System V AMD64 ABI
; Preserving RBX, RBP and R12-15, all others are spoiled.
; Arguments passed through RDI, RSI, RDX, RCX, R8, R9
; rest through stack

global _start

%define INPUT_SIZE 0x1000

section .bss
bracket_ignore: resb 8   ; bracket ignore count
code: resb 8             ; pointer to code
code_start: resb 8       ; pointer to code, always at start
stack: resb 30000        ; brainfuck stack
bfsp: resb 8             ; brainfuck stack pointer


section .text
_brainfuck_run:
	sub rsp, 16
	mov qword [rsp], 0 ; i
	mov qword [bfsp], stack
	mov rdi, qword [code]
	mov qword [code_start], rdi

	.main_loop:
	mov rcx, qword [code]
	mov al, byte [rcx]
	cmp al, 0
	je .exit
	
	mov rcx, qword [bracket_ignore]
	cmp rcx, 0
	je .no_ignore

	cmp al, '['
	je .add_ignore_index

	cmp al, ']'
	je .dec_ignore_index

	jmp .next_char

	.add_ignore_index:
	inc qword [bracket_ignore]
	jmp .next_char

	.dec_ignore_index:
	dec qword [bracket_ignore]
	jmp .next_char

	.no_ignore:
	cmp al, '<'
	je .dec_sp

	cmp al, '>'
	je .inc_sp

	cmp al, '+'
	je .inc_cell

	cmp al, '-'
	je .dec_cell

	cmp al, '.'
	je .putchar_cell

	cmp al, ','
	je .getchar_cell

	cmp al, '['
	je .open_loop

	cmp al, ']'
	je .close_loop

	jmp .continue

	.dec_sp:
	dec qword [bfsp]
	jmp .continue

	.inc_sp:
	inc qword [bfsp]
	jmp .continue

	.inc_cell:
	mov rax, qword [bfsp]
	inc qword [rax]
	jmp .continue

	.dec_cell:
	mov rax, qword [bfsp]
	dec qword [rax]
	jmp .continue

	.putchar_cell:
	mov rdi, qword [bfsp]
	push qword [rdi]
	mov rdi, rsp
	call _putchar
	add rsp, 8
	jmp .continue

	.getchar_cell:
	int 3
	jmp .continue

	.open_loop:
	mov rdi, qword [bfsp]
	cmp byte [rdi], 0
	je .do_ignore_brackets
	push qword [code]
	jmp .continue

	.do_ignore_brackets:
	inc qword [bracket_ignore]
	jmp .continue

	.close_loop:
	pop qword [code]
	jmp .main_loop

	.continue:
	; mov rcx, qword [code]
	; cmp byte [rcx], ']'
	; je .main_loop
	.next_char:
	inc qword [code]
	jmp .main_loop

	.exit:
	add rsp, 16
	ret

; calls sys_write(stdout, rdi, 1)
_putchar:
	mov rsi, rdi
	mov rdi, 1 ; stdout
	mov rdx, 1

	mov rax, 1 ; sys_write
	syscall
	ret

_alloc_mem:
	; mmap(addr, length:rdi, prot, flags, fd, offset)
	mov rsi, rdi  ; length
	xor rdi, rdi  ; addr
	mov rdx, 3    ; PROT_READ | PROT_WRITE
	mov r10, 0x22 ; MAP_PRIVATE | MAP_ANONYMOUS
	mov r8, -1    ; fd
	mov r9, 0     ; offset

	mov rax, 9  ; syscall ID
	syscall
	ret

; memset(dest, fill, size)
_memset:
	mov rcx, rdx
	mov al, sil
	rep stosb
	ret

; memcpy(dest, src, size)
_memcpy:
	mov rcx, rdx
	rep movsb
	ret

_start:
	sub rsp, INPUT_SIZE

	; memset(buffer, 0, count)
	mov rdi, rsp
	mov rsi, 0
	mov rdx, INPUT_SIZE
	call _memset

	; sys_read(stdin, buffer, count)
	mov rdi, 0
	mov rsi, rsp
	mov rdx, INPUT_SIZE
	mov rax, 0
	syscall

	mov qword [code], rsp

	call _brainfuck_run
	add rsp, INPUT_SIZE

	xor rdi, rdi
	mov rax, 60 ; exit
	syscall
