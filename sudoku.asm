.include "macros.asm"
.include "print_grid.asm"
.include "board_utils.asm"
.include "generate_puzzle.asm"
.include "verify_grid.asm"

.data
	.align 2
	grid: .space 324
	welcome_msg: .asciiz "Welcome to MIPS Sudoku!\n"
	rules_msg: .asciiz "Enter row and column (1-9), then a number (1-9) to place.\n"
	play_prompt: .asciiz "Enter 1 to play, 0 to exit: "
	invalid_choice_msg: .asciiz "Invalid choice, please try again.\n"
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
	li $s0, 1
	store_entry(1, 2, $s0)
	store_entry(8, 0, $s0)
	li $s0, 5
	store_entry(5, 6, $s0)
	store_entry(7, 2, $s0)
	li $s0, 9
	store_entry(6, 7, $s0)
	store_entry(3, 3, $s0)
	print_grid()

	li $v0, 10
	syscall