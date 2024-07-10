	.file	"standalone.c"
	.intel_syntax noprefix
	.text
	.type	ptr_to_hex_str, @function
ptr_to_hex_str:
	mov	WORD PTR [rsi], 30768
	lea	rax, [rsi+16]
.L6:
	mov	ecx, edi
	shr	cl, 4
	cmp	cl, 9
	lea	r8d, [rcx+48]
	lea	edx, [rcx+87]
	mov	ecx, edi
	cmovbe	edx, r8d
	and	ecx, 15
	cmp	cl, 9
	lea	r8d, [rcx+48]
	mov	BYTE PTR [rax], dl
	lea	edx, [rcx+87]
	cmovbe	edx, r8d
	sub	rax, 2
	shr	rdi, 8
	mov	BYTE PTR [rax+3], dl
	cmp	rax, rsi
	jne	.L6
	ret
	.size	ptr_to_hex_str, .-ptr_to_hex_str
	.type	write_syscall_x64, @function
write_syscall_x64:
	push	1
	pop	rax
#APP
# 55 "standalone.c" 1
	syscall
# 0 "" 2
#NO_APP
	ret
	.size	write_syscall_x64, .-write_syscall_x64
	.type	exit_syscall_x64, @function
exit_syscall_x64:
	push	60
	pop	rax
#APP
# 66 "standalone.c" 1
	syscall
# 0 "" 2
#NO_APP
	.size	exit_syscall_x64, .-exit_syscall_x64
	.globl	_start
	.type	_start, @function
_start:
	sub	rsp, 32
	mov	r9d, OFFSET FLAT:_Unwind_Backtrace
	lea	rsi, [rsp+14]
	mov	rdi, r9
	call	ptr_to_hex_str
	push	19
	pop	rdx
	mov	esi, OFFSET FLAT:uw_bt_prefix_str
	push	2
	pop	rdi
	call	write_syscall_x64
	push	18
	pop	rdx
	lea	rsi, [rsp+14]
	call	write_syscall_x64
	push	1
	mov	esi, OFFSET FLAT:newline_str
	pop	rdx
	call	write_syscall_x64
	mov	rdi, r9
	shr	rdi, 32
	xor	edi, r9d
	mov	DWORD PTR foo[rip], edi
	call	exit_syscall_x64
	.size	_start, .-_start
	.section	.rodata
	.type	newline_str, @object
	.size	newline_str, 2
newline_str:
	.string	"\n"
	.align 16
	.type	uw_bt_prefix_str, @object
	.size	uw_bt_prefix_str, 20
uw_bt_prefix_str:
	.string	"_Unwind_Backtrace: "
	.globl	foo
	.bss
	.align 4
	.type	foo, @object
	.size	foo, 4
foo:
	.zero	4
	.ident	"GCC: (GNU) 15.0.0 20240710 (experimental)"
	.section	.note.GNU-stack,"",@progbits
