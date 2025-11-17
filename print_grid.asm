.include "entry_manip.asm"
.macro print_grid
	.data
		x_int: .word 0
		y_int: .word 0
		number: .word 0
	.text
		li $s0, 0
		sw $s0, x_int
		li $s1, 0
		sw $s0, y_int
		j loop
	loop:
		load_entry(x_int, y_int, number)
		lw $s2, number
		jal print_entry
		bgt $s0, 7, increase_y
		addi $s0, $s0, 1
		sw $s0, x_int
		j loop
	increase_y:
		bgt $s1, 7, end
		li $s0, 0
		sw $s0, x_int
		addi $s1, $s1, 1
		sw $s1, y_int
		j loop
	print_if_not_zero:
		bgt $s2, 0, print_entry
		jr $ra
	print_entry:
		li $v0, 1
		lw $a0, number
		syscall
		jr $ra
	end:
.end_macro