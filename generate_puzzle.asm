# TJ Vasquez
# generate_puzzle.asm

#macro wrapper for safe to place function
.macro safe_to_place(%x, %y, %num, %dest)
	move $a0, %x
	move $a1, %y
	move $a2, %num
	jal safe_to_place
	move %dest, $v0
.end_macro

.macro generate_puzzle(%targetDifficulty)
	#Step 1: Place 11 initial values in Las Vegas algorithm
	li $s0, 0
	
placed_loop:
	#generate random x location in $s1 and random y location in $s2
	randi_range(0, 8, $s1)
	randi_range(0, 8, $s2)
	
	#check cell is empty
	load_entry($s1, $s2, $s3) 
	bne $s3, $zero, placed_loop
	
	#generate random number in $s3
	randi_range(1, 9, $s3)
	
	#check if it is safe to place the number in the grid
	safe_to_place($s1, $s2, $s3, $s4)
	
	beq $s4, $zero, placed_loop
	
	#now safe to place the number
	store_entry($s1, $s2, $s3)
	#printInt($s3)
	#printChar(' ')
	
	#store the index in indicies list
	li $t0, 0
	mul $t0, $s2, 9
	add $t0, $t0, $s1
	sll $t0, $t0, 2
	la $t1, initial_indicies
	sll $s0, $s0, 2
	addu $t1, $t1, $s0
	srl $s0, $s0, 2
	sw $t0, 0($t1)

	#if sucessfully placed increment $s0 and loop
	add $s0, $s0, 1
	blt $s0, 11, placed_loop
	
	la $t1, initial_indicies
	#printChar('\n')
	#print_array($t1,11)
	
	printString(puzzle_gen_1)
	
depth_first_search:
	#Step 2: Use depth-first search to find a solution
	la $s0, grid
	li $s4, 0 #index
	li $s7, 0 #backtracking counter
	
dfs_loop:
	#generate a random starting point
	randi_range(1, 9, $s1)
	move $s3, $s1 # store copy as starting point
	#store terminal point in array
	la $s0, terminal_vals
	addu $s0, $s0, $s4
	sw $s3, 0($s0)
	
	
find_next_safe_num:
	#calculate x and y
	srl $t2, $s4, 2 # t2 = index / 4
	li $t3, 9
	div $t2, $t3
	mflo $t1# y = t2 / 9
	mfhi $t0# x = t2 % 9
	
	#check if $s1 is safe to place
	safe_to_place($t0, $t1, $s1, $s2)
	#if safe to place, place it and continue
	beq $s2, 1, continue_dfs
	
	#if not safe to place, try next number
	add $s1, $s1, 1
	bge $s1, 10, overflow_reset
	
next_safe_up:
	#if next number equals starting number-1, go back up
	beq $s1, $s3, dfs_up

	j find_next_safe_num

overflow_reset: #reset to 1 if above 9
	li $s1, 1
	j next_safe_up

dfs_up:
	#if no valid solutions
	#go back one index, get the value, increase it and try again
dec_index:
	#loop back to next cell that we can modify
	subu $s4, $s4, 4
	
	#if we go below 0, dfs has failed
	blt $s4, 0, dfs_fail
	
	#skip immutable cells
	la $t1, initial_indicies
	not_in_array($s4, $t1, 11)
	beq $v0, $zero, dec_index
	
	addi $s7, $s7, 1
	#load value from cell and clear cell
	la $s0, grid
	addu $s0, $s0, $s4
	lw $s1, 0($s0)
	sw $zero, 0($s0)
	
	#load terminal value
	la $s0, terminal_vals
	addu $s0, $s0, $s4
	lw $s3, 0($s0)
	
	add $s1, $s1, 1
	bge $s1, 10, overflow_reset_up
	
	#printChar('u')
	#printChar(' ')
	#printInt($s1)
	#printChar('\n')
	beq $s1, $s3, dfs_up
	j find_next_safe_num

overflow_reset_up: #reset to 1 if above 9
	li $s1, 1
	beq $s1, $s3, dfs_up
	j find_next_safe_num

continue_dfs:
	#printInt($s4)
	#printChar(' ')
	#printInt($s3)
	#printChar(' ')
	#printInt($s1)
	#printChar('\n')	

	#place valid number in grid
	la $s0, grid
	addu $s0, $s0, $s4
	sw $s1, 0($s0)

	#loop to next cell that we can modify
inc_index:
	addu $s4, $s4, 4
	la $t1, initial_indicies
	not_in_array($s4, $t1, 11)
	beq $v0, $zero, inc_index
	
	blt $s4, 0, dfs_fail
	ble $s4, 320, dfs_loop
	
	j dfs_complete

dfs_fail:
	printInt(-1)
	printChar('\n')
dfs_complete:
	printString(puzzle_gen_2)
	#Step 3: Poke holes in the solution to create a puzzle
	
	#calculate lower bound of cells dug in $s7 and lower bound of givens per row/column in $s6
	#get lower bound by generating a random number between given_ranges[difficulty] and given_ranges[difficulty - 1] - 1
	la $s0, given_ranges
	li $t0, %targetDifficulty
	sll $t0, $t0, 2
	add $s0, $s0, $t0
	lw $s7, 0($s0)
	subi $s0, $s0, 4
	lw $s6, 0($s0)
	subi $s6, $s6, 1
	randi_range($s7, $s6, $s7)
	#subtract amount from 81 to get iterator
	li $t0, 81
	sub $s7, $t0, $s7
	
	#get max amount of zeroes per row by adding 3
	li $s6, %targetDifficulty
	addi $s6, $s6, 3
	beq $s6, 8, evil
	j dig

#set bound to 9 if evil difficulty
evil:
	li $s6, 9

dig:
	#dig cells
	printInt($s6)
	printChar(' ')
	printInt($s7)
	printChar('\n')
	
	#load grid into s0
	la $s0, grid
	addi $t9, $s0, 324 #end pointer
	
check_cell:
	#get x and y of current index
	la $t0, grid
	sub $s1, $s0, $t0
	srl $t1, $s1, 2 # t1 = index / 4
	li $t3, 9
	div $t1, $t3
	mflo $s3# y = t1 / 9
	mfhi $s2# x = t1 % 9
	
	#move into arguments and check if it meets the lower bound requirement
	move $a0, $s2
	move $a1, $s3

	jal meets_lower_bound
	
	beqz $v0, cannot_dig
	
	j dig_cell
	
cannot_dig:
	#if cell cannot be dug, check the next one
	addi $s0, $s0, 4
	bge $s0, $t9, digging_complete
	j check_cell
	 
dig_cell:
	
	#if cell sucessfully dug, decrement counter and jump
	subi $s7, $s7, 1
	sw $zero, 0($s0)
	addi $s0, $s0, 4
	
	bge $s0, $t9, digging_complete
	bgtz $s7, check_cell
	
digging_complete:
	printString(puzzle_gen_3)
	printInt($s7)
	printChar('\n')
	
	#Step 4: Propagate (shuffle non-destructively) the puzzle for uniqueness
propagate:
	#get how many times we will propagate the board in s0
	randi_range(2, 10, $s0)

propagate_loop_start:
	#choose which type of propagation to do
	randi_range(0, 2, $s1)
	beq $s1, 0, rotate
	beq $s1, 1, swap_block_columns
	beq $s1, 2, swap_random_columns

rotate:
	#rotate the whole grid 90 degrees clockwise using helper function
	jal rotate_grid_90_right
	j propagate_loop

swap_block_columns:
	#swap two columns of blocks
	
	#get the index of the two block columns
	randi_range(0, 2, $s2)
	randi_range(1, 2, $s3)
	add $s3, $s3, $s2
	li $t0, 3
	modulo($s3, $t0, $s3)
	
	mul $a0, $t0, $s2
	mul $a1, $t0, $s3
	
	#swap the 3 columns in the block
	jal swap_columns
	
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal swap_columns
	
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal swap_columns
	
	j propagate_loop

swap_random_columns:
	#swap two columns in the same column of blocks
	
	#generate a random column of blocks
	randi_range(0, 2, $s2)
	li $t0, 3
	mul $s2, $t0, $s2
	
	#generate random columns
	randi_range(0, 2, $s3)
	randi_range(1, 2, $s4)
	add $s4, $s4, $s3
	li $t0, 3
	modulo($s4, $t0, $s4)
	
	#offset by block
	add $a0, $s3, $s2
	add $a1, $s4, $s2
	
	jal swap_columns
	
	j propagate_loop
	
propagate_loop:
	subi $s0, $s0, 1
	bnez $s0, propagate_loop_start

done:
	printString(puzzle_gen_4)
.end_macro
