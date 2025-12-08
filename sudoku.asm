#sudoku2
# Adam Khalil, Brooke Landry, Christian Parkinson, TJ Vasquez
.include "entry_manip.asm"
.include "macros.asm"
.include "print_grid.asm"
.include "generate_sample_puzzle.asm"

.data
	.align 2
	grid: .space 324
	row: .word 0
	column: .word 0
	user_value: .word 0
	input_buffer: .space 10  # Buffer for string input
	welcome_msg: .asciiz "Welcome to MIPS Sudoku!\n"
	difficulty_prompt: .asciiz "Enter a target difficulty (1-5): "
	rules_msg: .asciiz "Enter row and column (1-9), then a number (1-9) to place.\n"
	unchangeable_msg: .asciiz "You cannot change a number on the grid once it is placed, so place wisely.\n"
	play_prompt: .asciiz "Enter 1 to play, 0 to exit: "
	entry_placed: .asciiz "It is now placed.\n"
	invalid_choice_msg: .asciiz "Invalid choice, please try again.\n"
	divider_msg: .asciiz "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
	row_prompt: .asciiz "Row (1-9 or 0 to restart turn): "
	col_prompt: .asciiz "Column (1-9 or 0 to restart turn): "
	num_prompt: .asciiz "Number (1-9 or 0 to restart turn): "
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
	jal get_valid_int
	move $t0, $v0
	beqz $t0, exit
	generate_sample_puzzle()
	j turns

turns:
	print_grid()
	j get_move

get_move:
	# Clear any stale register values
	li $t0, 0
	li $t1, 0
	li $t2, 0
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
	j get_move

restart_turn:
	j get_move

get_row:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
row_retry:
	printString(row_prompt)
	jal get_valid_int
	move $t1, $v0
	beqz $t1, restart_turn    # 0 = restart turn
	blt $t1, 1, bad_input_row
	bgt $t1, 9, bad_input_row
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
bad_input_row:
	printString(invalid_input_msg)
	j row_retry

get_col:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $t1, 0($sp)      # Save row from get_row
col_retry:
	printString(col_prompt)
	jal get_valid_int
	move $t0, $v0
	beqz $t0, restart_turn_col    # 0 = restart turn
	blt $t0, 1, bad_input_col
	bgt $t0, 9, bad_input_col
	lw $t1, 0($sp)      # Restore row
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
bad_input_col:
	printString(invalid_input_msg)
	j col_retry
restart_turn_col:
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	j restart_turn

get_num:
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $t1, 4($sp)      # Save row
	sw $t0, 0($sp)      # Save column
num_retry:
	printString(num_prompt)
	jal get_valid_int
	move $t2, $v0
	beqz $t2, restart_turn_num    # 0 = restart turn
	blt $t2, 1, bad_input_num
	bgt $t2, 9, bad_input_num
	lw $t0, 0($sp)      # Restore column
	lw $t1, 4($sp)      # Restore row
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
bad_input_num:
	printString(invalid_input_msg)
	j num_retry
restart_turn_num:
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	j restart_turn

# Safe integer input routine using string reading
# Returns: $v0 = integer read (only when a valid integer string was entered)
get_valid_int:
	# Save $ra and $s0 (we use $t registers freely)
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)

	# Clear input buffer (10 bytes)
	la $t9, input_buffer
	li $t8, 0
	li $t7, 10
clear_buffer_loop:
	sb $t8, 0($t9)
	addi $t9, $t9, 1
	addi $t7, $t7, -1
	bgtz $t7, clear_buffer_loop

read_input:
	# Read string input
	li $v0, 8           # syscall 8: read string
	la $a0, input_buffer
	li $a1, 10          # max 10 characters
	syscall

	# Initialize parser
	la $t0, input_buffer
	li $v0, 0           # result = 0
	li $t2, 10          # base 10
	li $t3, 0           # sign flag (0 = positive, 1 = negative)
	li $t4, 0           # invalid flag (0 = ok, 1 = invalid)
	li $t5, 0           # digit count

	# Skip leading whitespace (space or tab)
skip_leading_ws:
	lb $t1, 0($t0)
	beq $t1, 32, advance_ws
	beq $t1, 9, advance_ws
	j check_empty
advance_ws:
	addi $t0, $t0, 1
	j skip_leading_ws

check_empty:
	lb $t1, 0($t0)
	beq $t1, 10, invalid_input   # newline -> empty input
	beq $t1, 13, invalid_input   # carriage return -> empty
	beq $t1, 0, invalid_input    # null terminator -> empty

	# Optional sign
	beq $t1, 45, handle_sign     # 45 = '-'
	j parse_digits_start

handle_sign:
	li $t3, 1
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	# If sign is followed by newline or non-digit, it's invalid
	beq $t1, 10, invalid_input
	beq $t1, 13, invalid_input
	beq $t1, 0, invalid_input

parse_digits_start:
	lb $t1, 0($t0)
	beq $t1, 10, parsing_done
	beq $t1, 13, parsing_done
	beq $t1, 0, parsing_done

	# If not a digit, mark invalid
	blt $t1, 48, invalid_char
	bgt $t1, 57, invalid_char

parse_loop:
	lb $t1, 0($t0)
	beq $t1, 10, parsing_done
	beq $t1, 13, parsing_done
	beq $t1, 0, parsing_done
	blt $t1, 48, invalid_char
	bgt $t1, 57, invalid_char
	addi $t1, $t1, -48
	mul $v0, $v0, $t2
	add $v0, $v0, $t1
	addi $t5, $t5, 1
	addi $t0, $t0, 1
	j parse_loop

invalid_char:
	li $t4, 1
	j parsing_done

invalid_input:
	# Empty or otherwise invalid; prompt and re-read
	printString(invalid_input_msg)
	j read_input

parsing_done:
	# If we flagged invalid characters or parsed no digits, reject
	beq $t4, $zero, got_some_digits
	j invalid_input

got_some_digits:
	beqz $t5, invalid_input
	# Apply negative sign if needed
	beqz $t3, positive_result
	sub $v0, $zero, $v0

positive_result:
	# Restore saved registers and return
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

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
	jal get_valid_int
	move $t0, $v0
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