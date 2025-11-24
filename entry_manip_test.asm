.include "entry_manip.asm"
.data
	.align 2
	grid: .space 324
	.align 2
	x: .word
	.align 2
	y: .word
	.align 2
	tester: .space 4
.text
main: #for testing
	li $t0, 8
	li $t1, 7
	sw $t0, x
	sw $t1, y
	li $t1, 3
	sw $t1, tester
	store_entry_mem(x,y,tester)
	load_entry_mem(x,y,tester)
	li $v0, 1
	lw $a0, tester
	syscall
	li $v0, 10
	syscall