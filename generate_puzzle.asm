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
	printInt($s3)
	printChar(' ')
	
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
	printChar('\n')
	print_array($t1,11)
	
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
	srl   $t2, $s4, 2 # t2 = index / 4
	li    $t3, 9
	div   $t2, $t3
	mflo  $t1# y = t2 / 9
	mfhi  $t0# x = t2 % 9
	
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

	
	#Step 3: Poke holes in the solution to create a puzzle
	#Step 4: Propagate (shuffle) the puzzle for uniqueness
dfs_fail:
	printInt(-1)
	printChar('\n')
dfs_complete:
	printString(puzzle_gen_2)
.end_macro
