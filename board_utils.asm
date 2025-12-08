#Board utilities
#A function to check if a given number is safe to place in a specific position
# $a0 - x
# $a1 - y
# $a2 - number
# Returns:
# $v0 - 1 if safe, 0 if not safe
# uses regesters $t0 to $t5
.globl safe_to_place
safe_to_place:
	#store main return adress on stack
	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	
	#check if row is safe
	#for_range($t5, 0, 8, row_body)
	li $t5, 0
	jal row_body
	
	#check if col is safe
	#for_range($t5, 0, 8, col_body)
	li $t5, 0
	jal col_body
	
	#check if box is safe
	#calculate the start position of the current box
	li $t4, 3
	modulo($a0, $t4, $t5) #mod x and 3 into $t5
	sub $t5, $a0, $t5 #$t5 = x - $t5 to get box start x
	modulo($a1, $t4, $t4) #mod y and 3 into $t4
	sub $t4, $a1, $t4 #$t4 = y - $t4 to get box start y
	
	#for_range($t2, 0, 2, box_outer)
	li $t2, 0
	jal box_outer
	
	li $v0, 1 #if none of the previous checks branched, return 1 meaning that it is safe
	
	#load adress on stack pointer and return
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

row_body:
	load_entry($t5, $a1, $t0) 
	beq $a2, $t0, num_detected #if number in cell ($t0) equals the number to check ($a2) return 0
	add $t5, $t5, 1

	ble $t5, 8, row_body
	jr $ra

col_body:
	load_entry($a0, $t5, $t0) 
	beq $a2, $t0, num_detected #if number in cell ($t0) equals the number to check ($a2) return 0
	add $t5, $t5, 1
	
	ble $t5, 8, col_body
	jr $ra

box_outer:
	li $t3, 0

box_inner_loop:
	bge $t3, 3, box_inner_done
	
	add $t1, $t5, $t2 # t1 = t5 + outer index
	add $t0, $t4, $t3 # t0 = t4 + inner index
	
	load_entry($t1, $t0, $t0)
	
	beq $a2, $t0, num_detected #if number in cell ($t0) equals the number to check ($a2) return 0

	addi $t3, $t3, 1
	j box_inner_loop

box_inner_done:
	addi $t2, $t2, 1
	ble $t2, 2, box_outer
	jr $ra

num_detected:
	li $v0, 0 #if any of the previous checks branched, return 0 meaning that it is not safe
	#load adress on stack pointer and return
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#A function to clear a given board
# $a0 - address of board to clear
.globl clear_board
clear_board:
	add $t0, $a0, 320 # store ending address in $t0
	li $t1, 0
	
clear_board_loop:
	#store 0, increment, check if reached end of array
	sw $t1, 0($a0)
	add $a0, $a0, 4
	ble $a0, $t0, clear_board_loop
	
	jr $ra

#A function to check if removing a given cell would break the max amount of zeroes stored in $s6
# $a0 - x
# $a1 - y
# Returns:
# $v0 - 1 if does meet requirement, 0 if doesn't meet requirement
.globl meets_lower_bound
meets_lower_bound:
	
	li $t3, 0 #how many zeroes in current iteration
	li $t4, 0 #use t4 as iterator
	#check if row has less than $s6 zeroes
row_check:
	
	move $t0, $a1
	load_entry($t4, $t0, $t2)
	bnez $t2, row_loop
	
	#add zero and check if it breaks bound
	addi $t3, $t3, 1
	bge $t3, $s6, breaks_bound

row_loop:
	addi $t4, $t4, 1
	ble $t4, 8, row_check
	
	li $t3, 0
	li $t4, 0

col_check:
	
	move $t1, $a0
	load_entry($t1, $t4, $t2)
	bnez $t2, col_loop
	
	#add zero and check if it breaks bound
	addi $t3, $t3, 1
	bge $t3, $s6, breaks_bound
	
col_loop:
	addi $t4, $t4, 1
	ble $t4, 8, col_check

	li $v0, 1
	jr $ra

breaks_bound:
	li $v0, 0
	jr $ra


#A function to swap two columns within the grid
# a0 = colA
# a1 = colB
.globl swap_columns
swap_columns:
	#preserve registers
	subi $sp, $sp, 16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)

	#load base address of grid
	la $s0, grid

	#compute starting addresses of both columns
	#offset = column * 4
	sll $s1, $a0, 2 # colA offset
	sll $s2, $a1, 2 # colB offset

	add $s1, $s0, $s1 # s1 = &grid[colA]
	add $s2, $s0, $s2 # s2 = &grid[colB]

	li $s3, 9

swap_loop:
	beqz $s3, swap_done

	#load elements
	lw $t0, 0($s1)
	lw $t1, 0($s2)

	#swap them
	sw $t1, 0($s1)
	sw $t0, 0($s2)

	#move down one row
	addi $s1, $s1, 36
	addi $s2, $s2, 36

	subi $s3, $s3, 1
	j swap_loop

swap_done:
	#restore registers and return
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16

	jr $ra
	
#Performs a 90-degree clockwise rotation equivalent to:
# 1. Transpose (swap grid[i][j] with grid[j][i], j > i)
# 2. Reverse each row
.globl rotate_grid_90_right
rotate_grid_90_right:

	#preserve registers
	subi $sp, $sp, 16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)

	#load grid
	la $s0, grid

# 1. TRANSPOSE: for i 0..8, for j (i+1)..8:
#       swap( grid[i][j], grid[j][i] )

	li $s1, 0 #i = 0

transpose_outer:
	beq $s1, 9, transpose_done

	#inner loop starts at j = i + 1
	addi $s2, $s1, 1 #j = i+1

transpose_inner:
	beq $s2, 9, transpose_next_row

	#compute index1 = i*9 + j
	mul $t0, $s1, 9
	add $t0, $t0, $s2
	sll $t0, $t0, 2 # byte offset
	add $t0, $s0, $t0 #&grid[i][j]

	#compute index2 = j*9 + i
	mul $t1, $s2, 9
	add $t1, $t1, $s1
	sll $t1, $t1, 2
	add $t1, $s0, $t1 # &grid[j][i]

	#swap the two elements
	lw $t2, 0($t0)
	lw $t3, 0($t1)

	sw $t3, 0($t0)
	sw $t2, 0($t1)

	addi $s2, $s2, 1
	j transpose_inner

transpose_next_row:
	addi $s1, $s1, 1
	j transpose_outer

transpose_done:
# 2. REVERSE EACH ROW
# For each row i, swap grid[i][0] with grid[i][8],
#		       grid[i][1] with grid[i][7],
#		       grid[i][2] with grid[i][6],
#		       grid[i][3] with grid[i][5].
# Middle element stays unchanged.

	li $s1, 0 # i = 0 (row index)

reverse_rows:
	beq $s1, 9, rotate_done

	# left index = 0, right = 8
	li $s2, 0 # left column
	li $s3, 8 # right column

reverse_row_loop:
	bge $s2, $s3, reverse_next_row

	#compute left index = i*9 + left
	mul $t0, $s1, 9
	add $t0, $t0, $s2
	sll $t0, $t0, 2
	add $t0, $s0, $t0

	#compute right index = i*9 + right
	mul $t1, $s1, 9
	add $t1, $t1, $s3
	sll $t1, $t1, 2
	add $t1, $s0, $t1

	#swap
	lw $t2, 0($t0)
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	sw $t2, 0($t1)

	addi $s2, $s2, 1 #left++
	subi $s3, $s3, 1 #right--
	j reverse_row_loop

reverse_next_row:
	addi $s1, $s1, 1
	j reverse_rows

rotate_done:

	#restore registers
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16

	jr $ra
