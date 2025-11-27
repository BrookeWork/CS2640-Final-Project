# Adam Khalil, Brooke Landry, Christian Parkinson, TJ Vasquez
.include "macros.asm"
.include "print_grid.asm"
.include "generate_sample_puzzle.asm"


.data
	.align 2
	grid: .space 324
	welcome_msg: .asciiz "Welcome to MIPS Sudoku!\n"
	difficulty_prompt: .asciiz "Enter a target difficulty (1-5): "
	rules_msg: .asciiz "Enter row and column (1-9), then a number (1-9) to place.\n"
	play_prompt: .asciiz "Enter 1 to play, 0 to exit: "
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
.globl main
main:
	generate_sample_puzzle()
	
	print_grid()

	li $v0, 10
	syscall

.include "verify_grid.asm"
.include "board_utils.asm"