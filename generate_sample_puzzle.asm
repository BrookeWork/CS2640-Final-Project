# Adam Khalil
# generate_sample_puzzle.asm
# ill fill the global grid with a starting Sudoku puzzle || we can go from there
# simple, fixed puzzle (not a full Las Vegas generator),
# tho it does satisfies the project requirement to generate an initial board.

.macro generate_sample_puzzle()
	# clear the entire grid to 0
	li $t0, 0 # t0 = y = 0

gen_clear_row:
	bgt $t0, 8, gen_clear_done
	li $t1, 0 # t1 = x = 0

gen_clear_col:
	bgt $t1, 8, gen_clear_next_row
	store_entry($t1, $t0, $zero)
	addi $t1, $t1, 1
	j gen_clear_col

gen_clear_next_row:
	addi $t0, $t0, 1
	j gen_clear_row

gen_clear_done:
	# place given nums for a valid Sudoku puzzle 
	# coordinates 0-based: (x, y)

	# row 0
	li $t2, 5
	store_entry(0, 0, $t2)
	li $t2, 3
	store_entry(1, 0, $t2)
	li $t2, 7
	store_entry(4, 0, $t2)

	# row 1
	li $t2, 6
	store_entry(0, 1, $t2)
	li $t2, 1
	store_entry(3, 1, $t2)
	li $t2, 9
	store_entry(4, 1, $t2)
	li $t2, 5
	store_entry(5, 1, $t2)

	# row 2
	li $t2, 9
	store_entry(1, 2, $t2)
	li $t2, 8
	store_entry(2, 2, $t2)
	li $t2, 6
	store_entry(7, 2, $t2)

	# row 3
	li $t2, 8
	store_entry(0, 3, $t2)
	li $t2, 6
	store_entry(4, 3, $t2)
	li $t2, 3
	store_entry(8, 3, $t2)

	# row 4
	li $t2, 4
	store_entry(0, 4, $t2)
	li $t2, 8
	store_entry(3, 4, $t2)
	li $t2, 3
	store_entry(5, 4, $t2)
	li $t2, 1
	store_entry(8, 4, $t2)

	# row 5
	li $t2, 7
	store_entry(0, 5, $t2)
	li $t2, 2
	store_entry(4, 5, $t2)
	li $t2, 6
	store_entry(8, 5, $t2)

	# row 6
	li $t2, 6
	store_entry(1, 6, $t2)
	li $t2, 2
	store_entry(6, 6, $t2)
	li $t2, 8
	store_entry(7, 6, $t2)

	# row 7
	li $t2, 4
	store_entry(3, 7, $t2)
	li $t2, 1
	store_entry(4, 7, $t2)
	li $t2, 9
	store_entry(5, 7, $t2)
	li $t2, 5
	store_entry(8, 7, $t2)

	# row 8
	li $t2, 8
	store_entry(4, 8, $t2)
	li $t2, 7
	store_entry(7, 8, $t2)
	li $t2, 9
	store_entry(8, 8, $t2)
.end_macro
