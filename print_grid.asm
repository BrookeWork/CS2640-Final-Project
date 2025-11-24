#A macro that prints a grid in a neat format
.include "entry_manip.asm"
.macro print_grid
	.data
		x_int: .word 0
		y_int: .word 0
		number: .word 0
		start: .asciiz   "    1 2 3   4 5 6   7 8 9\n"
		divider: .asciiz "  +-------+-------+-------+\n"
		vertDivider: .asciiz " |"
	.text
		li $s0, 0
		sw $s0, x_int
		li $s1, 0
		sw $s0, y_int
		printString(start)
		printString(divider)
		printInt(1)
		printString(vertDivider)
		j loop
	loop:
		load_entry_mem(x_int, y_int, number)
		lw $s2, number
		jal print_entry
		
		#print vertical divider after columns 2, 5, and 8
		beq $s0, 2, print_vert_divider
		beq $s0, 5, print_vert_divider
		beq $s0, 8, print_vert_divider
		
	loop2:
		bgt $s0, 7, increase_y
		addi $s0, $s0, 1
		sw $s0, x_int
		
		j loop
	
	print_vert_divider:
		printString(vertDivider)
		j loop2
	
	increase_y:
		printChar('\n')
		bgt $s1, 7, end
		li $s0, 0
		sw $s0, x_int
		addi $s1, $s1, 1
		sw $s1, y_int
		
		#print horizontal divider after rows 3 and 6
		beq $s1, 3, print_horiz_divider
		beq $s1, 6, print_horiz_divider
		
	print_line_num:
		#print line index - 1
		add $s1, $s1, 1
		printInt($s1)
		sub $s1, $s1, 1
		printString(vertDivider)
		
		j loop
	
	print_horiz_divider:
		printString(divider)
		j print_line_num
	
	print_if_not_zero:
		bgt $s2, 0, print_entry
		jr $ra
	print_entry:
		printChar(' ')
		li $v0, 1
		lw $a0, number
		syscall
		jr $ra
	end:
		printString(divider)
.end_macro
