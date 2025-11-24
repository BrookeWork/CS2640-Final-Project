#Board utilities
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

.macro box_inner(%index)
	add $t1, $t5, $t2
	add $t0, $t4, %index
	load_entry($t1, $t0, $t0)
	beq $a2, $t0, num_detected
.end_macro

box_outer:
	#for_range($t3, 0, 2, box_inner)
	box_inner(0)
	box_inner(1)
	box_inner(2)
	add $t2, $t2, 1
	ble $t2, 2, box_outer # jump back to box outer
	jr $ra

.globl safe_to_place
#A function to check if a given number is safe to place in a specific position
# $a0 - x
# $a1 - y
# $a2 - number
# uses regesters $t0 to $t5
safe_to_place:
	move $t3, $ra
	
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
	
	li $v0, 1 #if none of the previous checks branched, return that it is safe
	jr $t3

num_detected:
	li $v0, 0 #if any of the previous checks branched, return that it is not safe
	jr $t3
