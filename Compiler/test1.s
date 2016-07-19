.globl Bool..vtable
Bool..vtable:
	.quad Bool.new
	.quad Object.abort
	.quad Object.copy
	.quad Object.type_name

.globl IO..vtable
IO..vtable:
	.quad IO.new
	.quad Object.abort
	.quad Object.copy
	.quad Object.type_name
	.quad IO.in_int
	.quad IO.in_string
	.quad IO.out_int
	.quad IO.out_string

.globl Int..vtable
Int..vtable:
	.quad Int.new
	.quad Object.abort
	.quad Object.copy
	.quad Object.type_name

.globl Main..vtable
Main..vtable:
	.quad Main.new
	.quad Object.abort
	.quad Object.copy
	.quad Object.type_name
	.quad IO.in_int
	.quad IO.in_string
	.quad IO.out_int
	.quad IO.out_string
	.quad Main.main

.globl Object..vtable
Object..vtable:
	.quad Object.new
	.quad Object.abort
	.quad Object.copy
	.quad Object.type_name

.globl String..vtable
String..vtable:
	.quad String.new
	.quad Object.abort
	.quad Object.copy
	.quad Object.type_name
	.quad String.concat
	.quad String.length
	.quad String.substr

	.section	.rodata
.Bool.type_string:
	.string "Bool"
.globl .Bool.type_string_obj
.Bool.type_string_obj:
	.quad .String.type_string
	.quad 40
	.quad String..vtable
	.quad .Bool.type_string
	.quad 4
	.text
	.globl	Bool.new
	.type	Bool.new, @function
Bool.new:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	$1,%rsi
	movq	$32,%rdi
	movq	$0,%rax
	call	calloc
	movq	$.Bool.type_string_obj,(%rax)
	movq	$32,8(%rax)
	movq	$Bool..vtable,16(%rax)
	movq	%rax,%rbx
	pushq	%rax
	popq	%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
.IO.type_string:
	.string "IO"
.globl .IO.type_string_obj
.IO.type_string_obj:
	.quad .String.type_string
	.quad 40
	.quad String..vtable
	.quad .IO.type_string
	.quad 2
	.text
	.globl	IO.new
	.type	IO.new, @function
IO.new:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	$1,%rsi
	movq	$24,%rdi
	movq	$0,%rax
	call	calloc
	movq	$.IO.type_string_obj,(%rax)
	movq	$24,8(%rax)
	movq	$IO..vtable,16(%rax)
	movq	%rax,%rbx
	pushq	%rax
	popq	%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
.Int.type_string:
	.string "Int"
.globl .Int.type_string_obj
.Int.type_string_obj:
	.quad .String.type_string
	.quad 40
	.quad String..vtable
	.quad .Int.type_string
	.quad 3
	.text
	.globl	Int.new
	.type	Int.new, @function
Int.new:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	$1,%rsi
	movq	$32,%rdi
	movq	$0,%rax
	call	calloc
	movq	$.Int.type_string_obj,(%rax)
	movq	$32,8(%rax)
	movq	$Int..vtable,16(%rax)
	movq	%rax,%rbx
	pushq	%rax
	popq	%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
.Main.type_string:
	.string "Main"
.globl .Main.type_string_obj
.Main.type_string_obj:
	.quad .String.type_string
	.quad 40
	.quad String..vtable
	.quad .Main.type_string
	.quad 4
	.text
	.globl	Main.new
	.type	Main.new, @function
Main.new:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	$1,%rsi
	movq	$64,%rdi
	movq	$0,%rax
	call	calloc
	movq	$.Main.type_string_obj,(%rax)
	movq	$64,8(%rax)
	movq	$Main..vtable,16(%rax)
	movq	%rax,%rbx
	pushq	%rax
	call	Int.new
	movq	%rax,24(%rbx)
	call	Int.new
	movq	%rax,32(%rbx)
	call	Int.new
	movq	%rax,40(%rbx)
	call	Main.attr.a
	movq	%rax,24(%rbx)
	call	Main.attr.b
	movq	%rax,32(%rbx)
	popq	%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
.Object.type_string:
	.string "Object"
.globl .Object.type_string_obj
.Object.type_string_obj:
	.quad .String.type_string
	.quad 40
	.quad String..vtable
	.quad .Object.type_string
	.quad 6
	.text
	.globl	Object.new
	.type	Object.new, @function
Object.new:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	$1,%rsi
	movq	$24,%rdi
	movq	$0,%rax
	call	calloc
	movq	$.Object.type_string_obj,(%rax)
	movq	$24,8(%rax)
	movq	$Object..vtable,16(%rax)
	movq	%rax,%rbx
	pushq	%rax
	popq	%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
.String.type_string:
	.string "String"
.globl .String.type_string_obj
.String.type_string_obj:
	.quad .String.type_string
	.quad 40
	.quad String..vtable
	.quad .String.type_string
	.quad 6
	.text
	.globl	String.new
	.type	String.new, @function
String.new:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	$1,%rsi
	movq	$40,%rdi
	movq	$0,%rax
	call	calloc
	movq	$.String.type_string_obj,(%rax)
	movq	$40,8(%rax)
	movq	$String..vtable,16(%rax)
	movq	%rax,%rbx
	pushq	%rax
	movq	$.NULLSTR,24(%rbx)
	popq	%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.globl	IO.in_int
	.type	IO.in_int, @function
IO.in_int:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	subq	$8,%rsp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	$1,%rsi
	movq	$256,%rdi
	call	malloc
	pushq	%rax
	movq	%rax,%rdi
	movq	$256,%rsi
	movq	stdin(%rip),%rdx
	call	fgets
	popq	%rdi
	movq	$0,%rax
	pushq	%rax
	movq	%rsp,%rdx
	movq	$.FORMOFLONGINT,%rsi
	call	sscanf
	popq	%rax
	movq	$0,%rsi
	cmpq	$2147483647,%rax
	cmovgq	%rsi,%rax
	cmpq	$-2147483648,%rax
	cmovlq	%rsi,%rax
	movq	%rax,-8(%rbp)
	call	Int.new
	pushq	%rcx
	movl	-8(%rbp),%ecx
	movl	%ecx,24(%rax)
	popq	%rcx
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.globl	IO.in_string
	.type	IO.in_string, @function
IO.in_string:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	subq	$32,%rsp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	$2048,%rdi
	movq	$0,%rax
	call	malloc
	movq	%rax,-16(%rbp)
	movq	$0,-8(%rbp)
nlabel_1:
	movq	$0,%rax
	movq	stdin(%rip),%rdi
	call	fgetc
	cmpl	$-1,%eax
	je	nlabel_2
	cmpl	$10,%eax
	je	nlabel_2
	cmpl	$0,%eax
	je	nlabel_3
	movq	-8(%rbp),%rsi
	movq	-16(%rbp),%rbx
	addq	%rsi,%rbx
	movb	%al,(%rbx)
	addq	$1,-8(%rbp)
	jmp	nlabel_1
nlabel_2:
	movq	-8(%rbp),%rsi
	movq	-16(%rbp),%rbx
	addq	%rsi,%rbx
	movb	$0,(%rbx)
	jmp	nlabel_4
nlabel_3:
	movq	$.NULLSTR,-16(%rbp)
	movq	$0,-8(%rbp)
nlabel_5:
	movq	$0,%rax
	call	getchar
	cmpl	$-1,%eax
	je	nlabel_4
	cmpl	$10,%eax
	je	nlabel_4
	jmp	nlabel_5
nlabel_4:
	call	String.new
	pushq	%rcx
	movq	-16(%rbp),%rcx
	movq	%rcx,24(%rax)
	popq	%rcx
	pushq	%rcx
	movl	-8(%rbp),%ecx
	movl	%ecx,32(%rax)
	popq	%rcx
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.globl	IO.out_int
	.type	IO.out_int, @function
IO.out_int:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	$0,%rax
	movq	24(%rbp),%rsi
	movq	24(%rsi),%rsi
	movq	$.FORMOFINT,%rdi
	call	printf
	movq	16(%rbp),%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.globl	IO.out_string
	.type	IO.out_string, @function
IO.out_string:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	subq	$2048,%rsp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	%rbp,%r12
	movq	%rbp,%r13
	subq	$2048,%r12
	subq	$2048,%r13
	movq	$0,-16(%rbp)
	movq	24(%rbp),%rbx
	movq	24(%rbx),%rbx
nlabel_6:
	movq	-16(%rbp),%rdi
	movq	%rbx,%rax
	addq	%rdi,%rax
	movb	(%rax),%al
	cmpb	$92,%al
	je	nlabel_7
	cmpb	$0,%al
	je	nlabel_10
	movb	%al,(%r12)
	addq	$1,%r12
	addq	$1,-16(%rbp)
	jmp	nlabel_6
nlabel_7:
	movq	-16(%rbp),%rdi
	movq	%rbx,%rax
	addq	%rdi,%rax
	addq	$1,%rax
	movb	(%rax),%al
	cmpb	$110,%al
	je	nlabel_8
	cmpb	$116,%al
	je	nlabel_9
	movb	$92,(%r12)
	addq	$1,%r12
	addq	$1,-16(%rbp)
	jmp	nlabel_6
nlabel_8:
	movb	$10,(%r12)
	addq	$1,%r12
	addq	$2,-16(%rbp)
	jmp	nlabel_6
nlabel_9:
	movb	$9,(%r12)
	addq	$1,%r12
	addq	$2,-16(%rbp)
	jmp	nlabel_6
nlabel_10:
	movb	$0,(%r12)
	movq	%r13,%rsi
	movq	$.FORMOFSTRING,%rdi
	movq	$0,%rax
	call	printf
	movq	16(%rbp),%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.globl	Main.attr.a
	.type	Main.attr.a, @function
Main.attr.a:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	subq	$32,%rsp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movl	$1,%esi
	pushq	%rbx
	movq	%rsi,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rsi
	popq	%rbx
	movq	%rsi,%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.globl	Main.attr.b
	.type	Main.attr.b, @function
Main.attr.b:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	subq	$32,%rsp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movl	$2,%r13d
	pushq	%rbx
	movq	%r13,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%r13
	popq	%rbx
	movq	%r13,%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.globl	Main.main
	.type	Main.main, @function
Main.main:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	subq	$32,%rsp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	pushq	%rax
	movq	16(%rbp),%rax
	movq	40(%rax),%rax
	movq	%rax,%rbx
	popq	%rax
	pushq	%rax
	movq	%rbx,%rax
	movl	24(%rax),%r12d
	popq	%rax
	movl	$7,%r8d
	movq	%r8,%r15
	pushq	%r15
	addl	%r12d,%r15d
	movl	%r15d,%r12d
	popq	%r15
	pushq	%rbx
	movq	%r12,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%r12
	popq	%rbx
	movq	%r12,%r10
	pushq	%r10
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	call	Int.new
	movq	%rax,%rcx
	pushq	%rax
	movq	%rcx,%rax
	movl	24(%rax),%r9d
	popq	%rax
	movl	$5,%r14d
	movq	%r14,%rcx
	pushq	%rcx
	addl	%r9d,%ecx
	movl	%ecx,%r9d
	popq	%rcx
	pushq	%rbx
	movq	%r9,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%r9
	popq	%rbx
	movq	%r9,%rbx
	pushq	%rbx
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	call	Int.new
	movq	%rax,%rax
	pushq	%rax
	movq	%rax,%rax
	movl	24(%rax),%r13d
	popq	%rax
	call	Int.new
	movq	%rax,%r15
	pushq	%rax
	movq	%r15,%rax
	movl	24(%rax),%r12d
	popq	%rax
	pushq	%r12
	addl	%r13d,%r12d
	movl	%r12d,%edi
	popq	%r12
	pushq	%rbx
	movq	%rdi,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rdi
	popq	%rbx
	movq	%rdi,%r15
	pushq	%r15
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	call	Int.new
	movq	%rax,%rcx
	pushq	%rax
	movq	%rcx,%rax
	movl	24(%rax),%edi
	popq	%rax
	movl	$5,%ecx
	movq	%rcx,%r10
	cmpl	%r10d,%edi
	jl	nlabel_12
nlabel_11:
	movl	$0,%r9d
	jmp	nlabel_13
nlabel_12:
	movl	$1,%r9d
nlabel_13:
	movq	%r9,%rbx
	cmpl	$1,%ebx
	je	label_0
label_1:
	call	String.new
	movq	$.GLOB.STR1,24(%rax)
	movl	$7,32(%rax)
	movq	%rax,%r13
	movq	%r13,%rcx
	pushq	%rcx
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
	jmp	label_2
label_0:
	call	String.new
	movq	$.GLOB.STR2,24(%rax)
	movl	$6,32(%rax)
	movq	%rax,%r9
	movq	%r9,%r11
	pushq	%r11
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
label_2:
	pushq	%rax
	movq	16(%rbp),%rax
	movq	32(%rax),%rax
	movq	%rax,%r12
	popq	%rax
	pushq	%rax
	movq	%r12,%rax
	movl	24(%rax),%r14d
	popq	%rax
	pushq	%rax
	movq	16(%rbp),%rax
	movq	24(%rax),%rax
	movq	%rax,%r11
	popq	%rax
	pushq	%rax
	movq	%r11,%rax
	movl	24(%rax),%r8d
	popq	%rax
	cmpl	%r8d,%r14d
	je	nlabel_15
nlabel_14:
	movl	$0,%r10d
	jmp	nlabel_16
nlabel_15:
	movl	$1,%r10d
nlabel_16:
	movq	%r10,%r13
	cmpl	$1,%r13d
	je	label_3
label_4:
	call	String.new
	movq	$.GLOB.STR3,24(%rax)
	movl	$7,32(%rax)
	movq	%rax,%rax
	movq	%rax,%rbx
	pushq	%rbx
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
	jmp	label_5
label_3:
	call	String.new
	movq	$.GLOB.STR4,24(%rax)
	movl	$6,32(%rax)
	movq	%rax,%rbx
	movq	%rbx,%r15
	pushq	%r15
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
label_5:
	pushq	%rax
	movq	16(%rbp),%rax
	movq	40(%rax),%rax
	movq	%rax,%r11
	popq	%rax
	pushq	%rax
	movq	%r11,%rax
	movl	24(%rax),%r14d
	popq	%rax
	pushq	%rax
	movq	16(%rbp),%rax
	movq	32(%rax),%rax
	movq	%rax,%r8
	popq	%rax
	pushq	%rax
	movq	%r8,%rax
	movl	24(%rax),%ebx
	popq	%rax
	cmpl	%ebx,%r14d
	jle	nlabel_18
nlabel_17:
	movl	$0,%r8d
	jmp	nlabel_19
nlabel_18:
	movl	$1,%r8d
nlabel_19:
	movq	%r8,%r12
	cmpl	$1,%r12d
	je	label_6
label_7:
	call	String.new
	movq	$.GLOB.STR5,24(%rax)
	movl	$7,32(%rax)
	movq	%rax,%rax
	movq	%rax,%rsi
	pushq	%rsi
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
	jmp	label_8
label_6:
	call	String.new
	movq	$.GLOB.STR6,24(%rax)
	movl	$6,32(%rax)
	movq	%rax,%rdx
	movq	%rdx,%rdx
	pushq	%rdx
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
label_8:
	movl	$1,%r15d
	pushq	%rbx
	movq	%r15,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%r15
	popq	%rbx
	movq	%r15,%r9
	pushq	%rax
	movq	%r9,%rax
	movl	24(%rax),%r13d
	popq	%rax
	movl	$2,%r10d
	pushq	%rbx
	movq	%r10,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%r10
	popq	%rbx
	movq	%r10,%r12
	pushq	%rax
	movq	16(%rbp),%rax
	movq	%r12,40(%rax)
	popq	%rax
	pushq	%rax
	movq	%r12,%rax
	movl	24(%rax),%r8d
	popq	%rax
	cmpl	%r8d,%r13d
	je	nlabel_21
nlabel_20:
	movl	$0,%r8d
	jmp	nlabel_22
nlabel_21:
	movl	$1,%r8d
nlabel_22:
	movq	%r8,%r14
	cmpl	$1,%r14d
	je	label_9
label_10:
	call	String.new
	movq	$.GLOB.STR7,24(%rax)
	movl	$7,32(%rax)
	movq	%rax,%rbx
	movq	%rbx,%r12
	pushq	%r12
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
	jmp	label_11
label_9:
	call	String.new
	movq	$.GLOB.STR8,24(%rax)
	movl	$6,32(%rax)
	movq	%rax,%rax
	movq	%rax,%rcx
	pushq	%rcx
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
label_11:
	call	Int.new
	movq	%rax,%r9
	cmpq	$0,%r9
	je	nlabel_24
nlabel_23:
	movl	$0,%esi
	jmp	nlabel_25
nlabel_24:
	movl	$1,%esi
nlabel_25:
	pushq	%rsi
	xorl	$1,%esi
	movl	%esi,%edx
	popq	%rsi
	cmpl	$1,%edx
	je	label_12
	pushq	$.GLOB.STR9
	call	error.error
label_12:
	pushq	%r9
	movq	%r9,%rax
	movq	16(%rax),%rax
	addq	$24,%rax
	call	*(%rax)
	addq	$8,%rsp
	movq	%rax,%r13
	movq	%r13,%r8
	pushq	%r8
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	24(%rax),%rax
	movq	%rax,%rbx
	popq	%rax
	movq	%rbx,%r9
	pushq	%r9
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	movq	16(%rbp),%rax
	movq	32(%rax),%rax
	movq	%rax,%rax
	movq	%rax,%rbx
	pushq	%rbx
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	40(%rax),%rax
	movq	%rax,%r13
	popq	%rax
	movq	%r13,%r15
	pushq	%r15
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	movl	$5,%r15d
	pushq	%rbx
	movq	%r15,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%r15
	popq	%rbx
	movq	%r15,%r15
	pushq	%rax
	movq	%r15,%rax
	movl	24(%rax),%r12d
	popq	%rax
	movl	$3,%edx
	pushq	%rbx
	movq	%rdx,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rdx
	popq	%rbx
	movq	%rdx,%rsi
	pushq	%rax
	movq	16(%rbp),%rax
	movq	%rsi,40(%rax)
	popq	%rax
	pushq	%rax
	movq	%rsi,%rax
	movl	24(%rax),%r9d
	popq	%rax
	pushq	%r9
	addl	%r12d,%r9d
	movl	%r9d,%r10d
	popq	%r9
	pushq	%rbx
	movq	%r10,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%r10
	popq	%rbx
	movq	%r10,%r8
	pushq	%rax
	movq	16(%rbp),%rax
	movq	%r8,24(%rax)
	popq	%rax
	movq	%r8,%r10
	pushq	%r10
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	movl	$1,%esi
	pushq	%rbx
	movq	%rsi,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rsi
	popq	%rbx
	movq	%rsi,%r9
	pushq	%rax
	movq	%r9,%rax
	movl	24(%rax),%r9d
	popq	%rax
	movl	$2,%edi
	movq	%rdi,%rdx
	movl	$3,%ebx
	pushq	%rdx
	pushq	%r9
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rbx
	popq	%r9
	popq	%rdx
	movq	%rbx,%rbx
	pushq	%rax
	movq	%rbx,%rax
	movl	24(%rax),%ecx
	popq	%rax
	pushq	%rcx
	addl	%edx,%ecx
	movl	%ecx,%edx
	popq	%rcx
	pushq	%r9
	pushq	%rbx
	movq	%rdx,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rdx
	popq	%rbx
	popq	%r9
	movq	%rdx,%rdi
	pushq	%rax
	movq	16(%rbp),%rax
	movq	%rdi,24(%rax)
	popq	%rax
	movq	%rdi,%rax
	movl	24(%rax),%eax
	addl	%r9d,%eax
	pushq	%rbx
	movq	%rax,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rax
	popq	%rbx
	movq	%rax,%rsi
	pushq	%rax
	movq	16(%rbp),%rax
	movq	%rsi,32(%rax)
	popq	%rax
	movq	%rsi,%rcx
	pushq	%rcx
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	24(%rax),%rax
	movq	%rax,%rdx
	popq	%rax
	movq	%rdx,%rdx
	pushq	%rdx
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	32(%rax),%rax
	movq	%rax,%rbx
	popq	%rax
	movq	%rbx,%r12
	pushq	%r12
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	40(%rax),%rax
	movq	%rax,%rdi
	popq	%rax
	movq	%rdi,%r11
	pushq	%r11
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	24(%rax),%rax
	movq	%rax,%r8
	popq	%rax
	cmpq	$0,%r8
	je	nlabel_27
nlabel_26:
	movl	$0,%ebx
	jmp	nlabel_28
nlabel_27:
	movl	$1,%ebx
nlabel_28:
	xorl	$1,%ebx
	movl	%ebx,%ebx
	cmpl	$1,%ebx
	je	label_13
	pushq	$.GLOB.STR10
	call	error.error
label_13:
	pushq	%r8
	movq	%r8,%rax
	movq	16(%rax),%rax
	addq	$24,%rax
	call	*(%rax)
	addq	$8,%rsp
	movq	%rax,%rcx
	movq	%rcx,%r15
	pushq	%r15
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
	movl	$5,%edi
	pushq	%rbx
	movq	%rdi,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rdi
	popq	%rbx
	cmpq	$0,%rdi
	je	nlabel_30
nlabel_29:
	movl	$0,%ebx
	jmp	nlabel_31
nlabel_30:
	movl	$1,%ebx
nlabel_31:
	pushq	%rbx
	xorl	$1,%ebx
	movl	%ebx,%ecx
	popq	%rbx
	cmpl	$1,%ecx
	je	label_14
	pushq	$.GLOB.STR11
	call	error.error
label_14:
	pushq	%rdi
	movq	%rdi,%rax
	movq	16(%rax),%rax
	addq	$24,%rax
	call	*(%rax)
	addq	$8,%rsp
	movq	%rax,%rax
	movq	%rax,%rdx
	pushq	%rdx
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
	movl	$5,%r13d
	movq	%r13,%rbx
	movl	$5,%r10d
	movq	%r10,%r13
	pushq	%r13
	addl	%ebx,%r13d
	movl	%r13d,%esi
	popq	%r13
	pushq	%rbx
	movq	%rsi,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rsi
	popq	%rbx
	movq	%rsi,%r15
	pushq	%r15
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	movl	$0,%esi
	movq	%rsi,%rbx
	pushq	%rax
	movq	16(%rbp),%rax
	movq	24(%rax),%rax
	movq	%rax,%rsi
	popq	%rax
	pushq	%rax
	movq	%rsi,%rax
	movl	24(%rax),%r12d
	popq	%rax
	pushq	%rbx
	subl	%r12d,%ebx
	movl	%ebx,%ecx
	popq	%rbx
	pushq	%rbx
	movq	%rcx,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rcx
	popq	%rbx
	movq	%rcx,%r9
	pushq	%r9
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	32(%rax),%rax
	movq	%rax,%r12
	popq	%rax
	pushq	%rax
	movq	%r12,%rax
	movl	24(%rax),%edi
	popq	%rax
	movl	$0,%eax
	movq	%rax,%r12
	movl	$1,%ebx
	movq	%rbx,%r8
	pushq	%r12
	subl	%r8d,%r12d
	movl	%r12d,%esi
	popq	%r12
	movq	%rsi,%r11
	imull	%edi,%r11d
	pushq	%rbx
	movq	%r11,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%r11
	popq	%rbx
	movq	%r11,%r10
	pushq	%r10
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	32(%rax),%rax
	movq	%rax,%rdi
	popq	%rax
	pushq	%rax
	movq	%rdi,%rax
	movl	24(%rax),%r13d
	popq	%rax
	movl	$0,%r9d
	movq	%r9,%r12
	movl	$1,%edx
	movq	%rdx,%r15
	subl	%r15d,%r12d
	movq	%r12,%r15
	movl	$0,%r14d
	cmpl	%r15d,%r14d
	je	nlabel_33
nlabel_32:
	movl	$0,%eax
	jmp	nlabel_34
nlabel_33:
	movl	$1,%eax
nlabel_34:
	pushq	%rax
	xorl	$1,%eax
	movl	%eax,%ecx
	popq	%rax
	cmpl	$1,%ecx
	je	label_15
	pushq	$.GLOB.STR12
	call	error.error
label_15:
	pushq	%rax
	pushq	%rdx
	movq	%r13,%rax
	cltd
	idivl	%r15d
	popq	%rdx
	movq	%rax,%r11
	popq	%rax
	pushq	%rbx
	movq	%r11,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%r11
	popq	%rbx
	movq	%r11,%r10
	pushq	%r10
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	32(%rax),%rax
	movq	%rax,%rsi
	popq	%rax
	cmpq	$0,%rsi
	je	nlabel_36
nlabel_35:
	movl	$0,%eax
	jmp	nlabel_37
nlabel_36:
	movl	$1,%eax
nlabel_37:
	pushq	%rax
	xorl	$1,%eax
	movl	%eax,%r14d
	popq	%rax
	cmpl	$1,%r14d
	je	label_16
	pushq	$.GLOB.STR13
	call	error.error
label_16:
	pushq	%rsi
	movq	%rsi,%rax
	movq	16(%rax),%rax
	addq	$16,%rax
	call	*(%rax)
	addq	$8,%rsp
	movq	%rax,%r9
	movq	%r9,%rsi
	pushq	%rax
	movq	16(%rbp),%rax
	movq	%rsi,24(%rax)
	popq	%rax
	pushq	%rax
	movq	16(%rbp),%rax
	movq	24(%rax),%rax
	movq	%rax,%rbx
	popq	%rax
	movq	%rbx,%r13
	pushq	%r13
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	24(%rax),%rax
	movq	%rax,%rdi
	popq	%rax
	cmpq	$0,%rdi
	je	nlabel_39
nlabel_38:
	movl	$0,%esi
	jmp	nlabel_40
nlabel_39:
	movl	$1,%esi
nlabel_40:
	pushq	%rsi
	xorl	$1,%esi
	movl	%esi,%r10d
	popq	%rsi
	cmpl	$1,%r10d
	je	label_17
	pushq	$.GLOB.STR14
	call	error.error
label_17:
	pushq	%rdi
	movq	%rdi,%rax
	movq	16(%rax),%rax
	addq	$16,%rax
	call	*(%rax)
	addq	$8,%rsp
	movq	%rax,%rsi
	movq	%rsi,%rcx
	pushq	%rcx
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	24(%rax),%rax
	movq	%rax,%rsi
	popq	%rax
	cmpq	$0,%rsi
	je	nlabel_42
nlabel_41:
	movl	$0,%r13d
	jmp	nlabel_43
nlabel_42:
	movl	$1,%r13d
nlabel_43:
	pushq	%r13
	xorl	$1,%r13d
	movl	%r13d,%r14d
	popq	%r13
	cmpl	$1,%r14d
	je	label_18
	pushq	$.GLOB.STR15
	call	error.error
label_18:
	pushq	%rsi
	movq	$Object..vtable,%rax
	addq	$16,%rax
	call	*(%rax)
	addq	$8,%rsp
	movq	%rax,%r10
	cmpq	$0,%r10
	je	nlabel_45
nlabel_44:
	movl	$0,%eax
	jmp	nlabel_46
nlabel_45:
	movl	$1,%eax
nlabel_46:
	pushq	%rax
	xorl	$1,%eax
	movl	%eax,%r12d
	popq	%rax
	cmpl	$1,%r12d
	je	label_19
	pushq	$.GLOB.STR16
	call	error.error
label_19:
	pushq	%r10
	movq	%r10,%rax
	movq	16(%rax),%rax
	addq	$24,%rax
	call	*(%rax)
	addq	$8,%rsp
	movq	%rax,%r12
	movq	%r12,%r13
	pushq	%r13
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$56,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	24(%rax),%rax
	movq	%rax,%rbx
	popq	%rax
	cmpq	$0,%rbx
	je	nlabel_48
nlabel_47:
	movl	$0,%r12d
	jmp	nlabel_49
nlabel_48:
	movl	$1,%r12d
nlabel_49:
	pushq	%r12
	xorl	$1,%r12d
	movl	%r12d,%edi
	popq	%r12
	cmpl	$1,%edi
	je	label_20
	pushq	$.GLOB.STR17
	call	error.error
label_20:
	pushq	%rbx
	movq	%rbx,%rax
	movq	16(%rax),%rax
	addq	$16,%rax
	call	*(%rax)
	addq	$8,%rsp
	movq	%rax,%r8
	pushq	%rax
	movq	%r8,%rax
	movl	24(%rax),%r8d
	popq	%rax
	pushq	%rax
	movq	16(%rbp),%rax
	movq	32(%rax),%rax
	movq	%rax,%r10
	popq	%rax
	cmpq	$0,%r10
	je	nlabel_51
nlabel_50:
	movl	$0,%edi
	jmp	nlabel_52
nlabel_51:
	movl	$1,%edi
nlabel_52:
	pushq	%rdi
	xorl	$1,%edi
	movl	%edi,%r13d
	popq	%rdi
	cmpl	$1,%r13d
	je	label_21
	pushq	$.GLOB.STR18
	call	error.error
label_21:
	pushq	%r8
	pushq	%r10
	movq	%r10,%rax
	movq	16(%rax),%rax
	addq	$16,%rax
	call	*(%rax)
	addq	$8,%rsp
	movq	%rax,%rcx
	popq	%r8
	movq	%rcx,%rax
	movl	24(%rax),%eax
	pushq	%r8
	subl	%eax,%r8d
	movl	%r8d,%edx
	popq	%r8
	pushq	%rbx
	movq	%rdx,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%rdx
	popq	%rbx
	movq	%rdx,%r12
	pushq	%r12
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	pushq	%rax
	movq	16(%rbp),%rax
	movq	24(%rax),%rax
	movq	%rax,%r11
	popq	%rax
	pushq	%rax
	movq	%r11,%rax
	movl	24(%rax),%r14d
	popq	%rax
	pushq	%rax
	movq	16(%rbp),%rax
	movq	32(%rax),%rax
	movq	%rax,%r12
	popq	%rax
	pushq	%rax
	movq	%r12,%rax
	movl	24(%rax),%r15d
	popq	%rax
	pushq	%r15
	addl	%r14d,%r15d
	movl	%r15d,%r14d
	popq	%r15
	pushq	%rbx
	movq	%r14,%rbx
	call	Int.new
	movl	%ebx,24(%rax)
	movq	%rax,%r14
	popq	%rbx
	movq	%r14,%r10
	pushq	%rax
	movq	16(%rbp),%rax
	movq	%r10,40(%rax)
	popq	%rax
	pushq	%rax
	movq	16(%rbp),%rax
	movq	40(%rax),%rax
	movq	%rax,%r10
	popq	%rax
	movq	%r10,%r11
	pushq	%r11
	pushq	16(%rbp)
	movq	16(%rbp),%rax
	movq	16(%rax),%rax
	addq	$48,%rax
	call	*(%rax)
	addq	$16,%rsp
	movq	%rax,%r9
	movq	%r9,%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
.globl .GLOB.STR1
.GLOB.STR1:
.byte	102	#f
.byte	97	#a
.byte	108	#l
.byte	115	#s
.byte	101	#e
.byte	92	#\
.byte	110	#n
.byte	0
.globl .GLOB.STR2
.GLOB.STR2:
.byte	116	#t
.byte	114	#r
.byte	117	#u
.byte	101	#e
.byte	92	#\
.byte	110	#n
.byte	0
.globl .GLOB.STR3
.GLOB.STR3:
.byte	102	#f
.byte	97	#a
.byte	108	#l
.byte	115	#s
.byte	101	#e
.byte	92	#\
.byte	110	#n
.byte	0
.globl .GLOB.STR4
.GLOB.STR4:
.byte	116	#t
.byte	114	#r
.byte	117	#u
.byte	101	#e
.byte	92	#\
.byte	110	#n
.byte	0
.globl .GLOB.STR5
.GLOB.STR5:
.byte	102	#f
.byte	97	#a
.byte	108	#l
.byte	115	#s
.byte	101	#e
.byte	92	#\
.byte	110	#n
.byte	0
.globl .GLOB.STR6
.GLOB.STR6:
.byte	116	#t
.byte	114	#r
.byte	117	#u
.byte	101	#e
.byte	92	#\
.byte	110	#n
.byte	0
.globl .GLOB.STR7
.GLOB.STR7:
.byte	102	#f
.byte	97	#a
.byte	108	#l
.byte	115	#s
.byte	101	#e
.byte	92	#\
.byte	110	#n
.byte	0
.globl .GLOB.STR8
.GLOB.STR8:
.byte	116	#t
.byte	114	#r
.byte	117	#u
.byte	101	#e
.byte	92	#\
.byte	110	#n
.byte	0
.globl .GLOB.STR9
.GLOB.STR9:
.byte	69	#E
.byte	82	#R
.byte	82	#R
.byte	79	#O
.byte	82	#R
.byte	58	#:
.byte	32	# 
.byte	49	#1
.byte	54	#6
.byte	58	#:
.byte	32	# 
.byte	100	#d
.byte	121	#y
.byte	110	#n
.byte	97	#a
.byte	109	#m
.byte	105	#i
.byte	99	#c
.byte	32	# 
.byte	100	#d
.byte	105	#i
.byte	115	#s
.byte	112	#p
.byte	97	#a
.byte	116	#t
.byte	99	#c
.byte	104	#h
.byte	32	# 
.byte	111	#o
.byte	110	#n
.byte	32	# 
.byte	118	#v
.byte	111	#o
.byte	105	#i
.byte	100	#d
.byte	0
.globl .GLOB.STR10
.GLOB.STR10:
.byte	69	#E
.byte	82	#R
.byte	82	#R
.byte	79	#O
.byte	82	#R
.byte	58	#:
.byte	32	# 
.byte	50	#2
.byte	53	#5
.byte	58	#:
.byte	32	# 
.byte	100	#d
.byte	121	#y
.byte	110	#n
.byte	97	#a
.byte	109	#m
.byte	105	#i
.byte	99	#c
.byte	32	# 
.byte	100	#d
.byte	105	#i
.byte	115	#s
.byte	112	#p
.byte	97	#a
.byte	116	#t
.byte	99	#c
.byte	104	#h
.byte	32	# 
.byte	111	#o
.byte	110	#n
.byte	32	# 
.byte	118	#v
.byte	111	#o
.byte	105	#i
.byte	100	#d
.byte	0
.globl .GLOB.STR11
.GLOB.STR11:
.byte	69	#E
.byte	82	#R
.byte	82	#R
.byte	79	#O
.byte	82	#R
.byte	58	#:
.byte	32	# 
.byte	50	#2
.byte	54	#6
.byte	58	#:
.byte	32	# 
.byte	100	#d
.byte	121	#y
.byte	110	#n
.byte	97	#a
.byte	109	#m
.byte	105	#i
.byte	99	#c
.byte	32	# 
.byte	100	#d
.byte	105	#i
.byte	115	#s
.byte	112	#p
.byte	97	#a
.byte	116	#t
.byte	99	#c
.byte	104	#h
.byte	32	# 
.byte	111	#o
.byte	110	#n
.byte	32	# 
.byte	118	#v
.byte	111	#o
.byte	105	#i
.byte	100	#d
.byte	0
.globl .GLOB.STR12
.GLOB.STR12:
.byte	69	#E
.byte	82	#R
.byte	82	#R
.byte	79	#O
.byte	82	#R
.byte	58	#:
.byte	32	# 
.byte	51	#3
.byte	48	#0
.byte	58	#:
.byte	32	# 
.byte	100	#d
.byte	105	#i
.byte	118	#v
.byte	105	#i
.byte	100	#d
.byte	101	#e
.byte	32	# 
.byte	98	#b
.byte	121	#y
.byte	32	# 
.byte	48	#0
.byte	0
.globl .GLOB.STR13
.GLOB.STR13:
.byte	69	#E
.byte	82	#R
.byte	82	#R
.byte	79	#O
.byte	82	#R
.byte	58	#:
.byte	32	# 
.byte	51	#3
.byte	49	#1
.byte	58	#:
.byte	32	# 
.byte	100	#d
.byte	121	#y
.byte	110	#n
.byte	97	#a
.byte	109	#m
.byte	105	#i
.byte	99	#c
.byte	32	# 
.byte	100	#d
.byte	105	#i
.byte	115	#s
.byte	112	#p
.byte	97	#a
.byte	116	#t
.byte	99	#c
.byte	104	#h
.byte	32	# 
.byte	111	#o
.byte	110	#n
.byte	32	# 
.byte	118	#v
.byte	111	#o
.byte	105	#i
.byte	100	#d
.byte	0
.globl .GLOB.STR14
.GLOB.STR14:
.byte	69	#E
.byte	82	#R
.byte	82	#R
.byte	79	#O
.byte	82	#R
.byte	58	#:
.byte	32	# 
.byte	51	#3
.byte	51	#3
.byte	58	#:
.byte	32	# 
.byte	100	#d
.byte	121	#y
.byte	110	#n
.byte	97	#a
.byte	109	#m
.byte	105	#i
.byte	99	#c
.byte	32	# 
.byte	100	#d
.byte	105	#i
.byte	115	#s
.byte	112	#p
.byte	97	#a
.byte	116	#t
.byte	99	#c
.byte	104	#h
.byte	32	# 
.byte	111	#o
.byte	110	#n
.byte	32	# 
.byte	118	#v
.byte	111	#o
.byte	105	#i
.byte	100	#d
.byte	0
.globl .GLOB.STR15
.GLOB.STR15:
.byte	69	#E
.byte	82	#R
.byte	82	#R
.byte	79	#O
.byte	82	#R
.byte	58	#:
.byte	32	# 
.byte	51	#3
.byte	52	#4
.byte	58	#:
.byte	32	# 
.byte	100	#d
.byte	121	#y
.byte	110	#n
.byte	97	#a
.byte	109	#m
.byte	105	#i
.byte	99	#c
.byte	32	# 
.byte	100	#d
.byte	105	#i
.byte	115	#s
.byte	112	#p
.byte	97	#a
.byte	116	#t
.byte	99	#c
.byte	104	#h
.byte	32	# 
.byte	111	#o
.byte	110	#n
.byte	32	# 
.byte	118	#v
.byte	111	#o
.byte	105	#i
.byte	100	#d
.byte	0
.globl .GLOB.STR16
.GLOB.STR16:
.byte	69	#E
.byte	82	#R
.byte	82	#R
.byte	79	#O
.byte	82	#R
.byte	58	#:
.byte	32	# 
.byte	51	#3
.byte	52	#4
.byte	58	#:
.byte	32	# 
.byte	100	#d
.byte	121	#y
.byte	110	#n
.byte	97	#a
.byte	109	#m
.byte	105	#i
.byte	99	#c
.byte	32	# 
.byte	100	#d
.byte	105	#i
.byte	115	#s
.byte	112	#p
.byte	97	#a
.byte	116	#t
.byte	99	#c
.byte	104	#h
.byte	32	# 
.byte	111	#o
.byte	110	#n
.byte	32	# 
.byte	118	#v
.byte	111	#o
.byte	105	#i
.byte	100	#d
.byte	0
.globl .GLOB.STR17
.GLOB.STR17:
.byte	69	#E
.byte	82	#R
.byte	82	#R
.byte	79	#O
.byte	82	#R
.byte	58	#:
.byte	32	# 
.byte	51	#3
.byte	53	#5
.byte	58	#:
.byte	32	# 
.byte	100	#d
.byte	121	#y
.byte	110	#n
.byte	97	#a
.byte	109	#m
.byte	105	#i
.byte	99	#c
.byte	32	# 
.byte	100	#d
.byte	105	#i
.byte	115	#s
.byte	112	#p
.byte	97	#a
.byte	116	#t
.byte	99	#c
.byte	104	#h
.byte	32	# 
.byte	111	#o
.byte	110	#n
.byte	32	# 
.byte	118	#v
.byte	111	#o
.byte	105	#i
.byte	100	#d
.byte	0
.globl .GLOB.STR18
.GLOB.STR18:
.byte	69	#E
.byte	82	#R
.byte	82	#R
.byte	79	#O
.byte	82	#R
.byte	58	#:
.byte	32	# 
.byte	51	#3
.byte	53	#5
.byte	58	#:
.byte	32	# 
.byte	100	#d
.byte	121	#y
.byte	110	#n
.byte	97	#a
.byte	109	#m
.byte	105	#i
.byte	99	#c
.byte	32	# 
.byte	100	#d
.byte	105	#i
.byte	115	#s
.byte	112	#p
.byte	97	#a
.byte	116	#t
.byte	99	#c
.byte	104	#h
.byte	32	# 
.byte	111	#o
.byte	110	#n
.byte	32	# 
.byte	118	#v
.byte	111	#o
.byte	105	#i
.byte	100	#d
.byte	0
	.section	.rodata
	.text
	.globl	Object.abort
	.type	Object.abort, @function
Object.abort:
	.cfi_startproc
	movq	$0,%rax
	movq	$.ABORT,%rdi
	call	printf
	call	exit
	.cfi_endproc
	.section	.rodata
	.text
	.globl	Object.copy
	.type	Object.copy, @function
Object.copy:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	16(%rbp),%rax
	movq	8(%rax),%rax
	movq	%rax,%rdi
	pushq	%rdi
	movq	$0,%rax
	call	malloc
	popq	%rdx
	movq	16(%rbp),%rsi
	movq	%rax,%rdi
	call	memcpy
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.globl	Object.type_name
	.type	Object.type_name, @function
Object.type_name:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	movq	16(%rbp),%rax
	movq	(%rax),%rax
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.globl	String.concat
	.type	String.concat, @function
String.concat:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	subq	$32,%rsp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	16(%rbp),%rbx
	movq	24(%rbp),%rsi
	pushq	%rsi
	movq	32(%rbx),%rdi
	addl	32(%rsi),%edi
	movq	%rdi,-8(%rbp)
	addl	$1,%edi
	movq	$0,%rax
	call	malloc
	movq	%rax,-16(%rbp)
	movq	32(%rbx),%rdx
	movq	24(%rbx),%rsi
	movq	%rax,%rdi
	call	memcpy
	popq	%rsi
	movq	32(%rsi),%rdx
	addq	$1,%rdx
	movq	24(%rsi),%rsi
	movq	-16(%rbp),%rdi
	addq	32(%rbx),%rdi
	call	memcpy
	call	String.new
	pushq	%rcx
	movq	-16(%rbp),%rcx
	movq	%rcx,24(%rax)
	popq	%rcx
	pushq	%rcx
	movl	-8(%rbp),%ecx
	movl	%ecx,32(%rax)
	popq	%rcx
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.globl	String.length
	.type	String.length, @function
String.length:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	16(%rbp),%rbx
	movq	32(%rbx),%rbx
	pushq	%rbx
	call	Int.new
	popq	%rbx
	movl	%ebx,24(%rax)
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.section	.rodata
.substr_error:
	.string "ERROR: 0: no"
	.text
	.globl	String.substr
	.type	String.substr, @function
String.substr:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	subq	$32,%rsp
	pushq	%rbx
	pushq	%rdi
	pushq	%rsi
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	movq	16(%rbp),%rbx
	movq	24(%rbp),%rdi
	movq	24(%rdi),%rdi
	movq	%rdi,-24(%rbp)
	movq	32(%rbp),%rdi
	movq	24(%rdi),%rdi
	testl	%edi,%edi
	js	nlabel_57
	movq	%rdi,-32(%rbp)
	addl	-24(%rbp),%edi
	cmpl	32(%rbx),%edi
	jg	nlabel_57
	jmp	nlabel_58
nlabel_57:
	pushq	$.substr_error
	call	error.error
nlabel_58:
	movq	-32(%rbp),%rdi
	addq	$1,%rdi
	movq	$0,%rax
	call	malloc
	movq	%rax,-16(%rbp)
	movq	-32(%rbp),%rdx
	movq	24(%rbx),%rsi
	addl	-24(%rbp),%esi
	movq	%rax,%rdi
	call	memcpy
	call	String.new
	pushq	%rcx
	movq	-16(%rbp),%rcx
	movq	%rcx,24(%rax)
	popq	%rcx
	pushq	%rcx
	movl	-32(%rbp),%ecx
	movl	%ecx,32(%rax)
	popq	%rcx
	movq	-16(%rbp),%rbx
	movq	-32(%rbp),%rdi
	addq	%rdi,%rbx
	movb	$0,(%rbx)
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rsi
	popq	%rdi
	popq	%rbx
	leave
	ret
	.cfi_endproc
	.file	 "out"
	.section	.rodata
.FORMOFINT:
	.string "%d"
.FORMOFLONGINT:
	.string "%ld"
.ABORT:
	.string "abort\n"
.NULLSTR:
	.string ""
.FORMOFSTRING:
	.string "%s"
	.text
	.align 16
	.globl	main
	.type	main, @function
main:
	.cfi_startproc
	pushq	%rbp
	movq	%rsp,%rbp
	call	Main.new
	pushq	%rax
	movq	16(%rax),%rax
	addq	$64,%rax
	call	*(%rax)
	leave
	ret
	.cfi_endproc
	.section	.rodata
	.text
	.align 16
	.globl	error.error
	.type	error.error, @function
error.error:
	.cfi_startproc
	movq	$0,%rax
	movq	8(%rsp),%rdi
	call	printf
	call	exit
	.cfi_endproc
