#sudoku2
# Adam Khalil, Brooke Landry, Christian Parkinson, TJ Vasquez
.include "entry_manip.asm"
.include "macros.asm"
.include "print_grid.asm"
.include "generate_sample_puzzle.asm"
#.include "verify_grid.asm"
#.include "brooke_board_utils.asm"

.data
	.align 2
	grid: .space 324
	row: .word 0
	column: .word 0
	user_value: .word 0
	welcome_msg: .asciiz "Welcome to MIPS Sudoku!\n"
	difficulty_prompt: .asciiz "Enter a target difficulty (1-5): "
	rules_msg: .asciiz "Enter row and column (1-9), then a number (1-9) to place.\n"
	unchangeable_msg: .asciiz "You cannot change a number on the grid once it is placed, so place wisely.\n"
	play_prompt: .asciiz "Enter 1 to play, 0 to exit: "
	entry_placed: .asciiz "It is now placed.\n"
	invalid_choice_msg: .asciiz "Invalid choice, please try again.\n"
	divider_msg: .asciiz "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
	row_prompt: .asciiz "Row (1-9): "
	col_prompt: .asciiz "Column (1-9): "
	num_prompt: .asciiz "Number (1-9): "
	invalid_input_msg: .asciiz "Invalid input, must be between 1 and 9.\n"
	invalid_move_msg: .asciiz "That move is not allowed by Sudoku rules.\n"
	continue_prompt: .asciiz "Enter 1 to continue playing, 0 to exit: "
	solved_msg: .asciiz "Congratulations, you solved the puzzle!\n"
	goodbye_msg: .asciiz "Goodbye!\n"

.text
main:
	printString(welcome_msg)
	printString(rules_msg)
	printString(unchangeable_msg)
	printString(play_prompt)
	getInt($t0)
	beqz $t0, exit
	#printString(difficulty_prompt)
	#getInt($t0)
	generate_sample_puzzle()
	j turns
turns:
	print_grid()
	j get_move
get_move:
	jal get_row
	jal get_col
	jal get_num
	addi $t0, $t0, -1 #Currently holds column
	addi $t1, $t1, -1 #Currently holds row
	load_entry($t0, $t1, $s2)
	bne $s2, 0, taken
	move $a0, $t0
	move $a1, $t1
	move $a2, $t2
	sw $t0, column
	sw $t1, row
	sw $t2, user_value
	jal safe_to_place
	beq $v0, 1, place
	printString(invalid_move_msg)
	j continue_or_stop
get_row:
	printString(row_prompt)
	getInt($t1)
	blt $t1, 1, bad_input_row
	bgt $t1, 9, bad_input_row
	jr $ra
bad_input_row:
	printString(invalid_input_msg)
	j get_row
get_col:
	printString(col_prompt)
	getInt($t0)
	blt $t0, 1, bad_input_col
	bgt $t0, 9, bad_input_col
	jr $ra
bad_input_col:
	printString(invalid_input_msg)
	j get_col
get_num:
	printString(num_prompt)
	getInt($t2)
	blt $t2, 1, bad_input_num
	bgt $t2, 9, bad_input_num
	jr $ra
bad_input_num:
	printString(invalid_input_msg)
	j get_num
taken:
	printString(invalid_choice_msg)
	j get_move
place:
	lw $a0, column
	lw $a1, row
	lw $a2, user_value
	store_entry($a0, $a1, $a2)
	printString(entry_placed)
	jal verify_grid
	beq $v0, 1, win
	j continue_or_stop
continue_or_stop:
	printString(continue_prompt)
	getInt($t0)
	beqz $t0, exit
	j turns
win:
	printString(solved_msg)
	j exit
exit:
	printString(goodbye_msg)
	li $v0, 10
	syscall
.include "verify_grid.asm"
.include "board_utils.asm"
