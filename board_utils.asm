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
	li $t0, 0
	#check if row has less than $s6 zeroes
row_check:
	
	move $t1, $a1
	load_entry($t0, $t1, $t2)
	bnez $t2, row_loop
	
	#add zero and check if it breaks bound
	addi $t3, $t3, 1
	bgt $t3, $s6, breaks_bound

row_loop:
	addi $t0, $t0, 1
	ble $t0, 8, row_check
	
	li $t3, 0
	li $t1, 0

col_check:
	
	move $t0, $a0
	load_entry($t0, $t1, $t2)
	bnez $t2, col_loop
	
	#add zero and check if it breaks bound
	addi $t3, $t3, 1
	bgt $t3, $s6, breaks_bound
	
col_loop:
	addi $t1, $t1, 1
	ble $t1, 8, col_check

	li $v0, 1
	jr $ra

breaks_bound:
	li $v0, 0
	jr $ra
	