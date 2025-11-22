.include "entry_manip.asm"
.data
.macro safe_to_place(%x, %y, %value, %bool)
	.data
		temp_row: .word 0
		temp_col: .word 0
		variable: .word 0
	.text
	main:
		jal row_safe
		jal column_safe
		jal box_safe
		j set_true # If all goes without setting bool to false and exiting the macro,
			   # %bool is set to true and the macro exits.
	row_safe:
		load_entry(temp_col, %y, variable)
		lw $t0, variable
		lw $t1, %value
		
		beq $t0, $t1, set_false
		
		lw $t0, temp_col
		addi $t0, $t0, 1
		sw $t0, temp_col
		blt $t0, 9, row_safe
		jr $ra
	column_safe:
		load_entry(%x, temp_row, variable)
		lw $t0, variable
		lw $t1, %value
		
		beq $t0, $t1, set_false
		
		lw $t0, temp_row
		addi $t0, $t0, 1
		sw $t0, temp_row
		blt $t0, 9, column_safe
		jr $ra
	box_safe:
		lw $t0, %x
		div $t0, $t0, 3 # $t0 will be 0, 1, or 2
		mul $t0, $t0, 3 # Multiply again to get 0, 3, or 6 (x coord start of each box)
		sw $t0, temp_col
		lw $t0, %y
		div $t0, $t0, 3 # $t1 will be 0, 1, or 2
		mul $t0, $t0, 3 # Multiply again to get 0, 3, or 6 (y coord start of each box)
		sw $t0, temp_row
		lw $t2, temp_col
		addi $t2, $t2, 3 #So columns from (value of initial temp_col) to (value of initial temp_col) + 3 are checked
		lw $t3, temp_row
		addi $t3, $t3, 3 #So columns from (value of iniital temp_row) to (value of initial temp_row) + 3 are checked
		j check_box
	check_box:
		load_entry(temp_col, temp_row, variable)
		lw $t0, variable
		lw $t1, %value
		
		beq $t0, $t1, set_false
		
		lw $t0, temp_col
		addi $t0, $t0, 1
		sw $t0, temp_col
		blt $t0, $t2, check_box #go through columns 
		subi $t0, $t0, 3 #If max column is reached reset temp_col
		sw $t0, temp_col
		lw $t1, temp_row
		addi $t1, $t1, 1
		sw $t1, temp_row
		blt $t1, $t3, check_box #go through rows
		jr $ra
	set_false:
		sb $zero, %bool
		j exit
	set_true:
		li $t0, 1
		sb $t0, %bool
		j exit
	exit:
.end_macro