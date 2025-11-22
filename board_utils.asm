#Board utilities
.include "entry_manip.asm"
.include "macros.asm"

.macro row_body()
	load_entry($t5, $a1, $t0) 
	beq $a2, $t0, num_detected #if number in cell ($t0) equals the number to check ($a2) return 0
.end_macro

.macro col_body()
	load_entry($a0, $t5, $t0) 
	beq $a2, $t0, num_detected #if number in cell ($t0) equals the number to check ($a2) return 0
.end_macro

.macro box_outer()
	for($t3, 0, 2, box_inner)
.end_macro

.macro box_inner()
	add $t0, $t5, $t2
	add $t1, $t4, $t3
	load_entry($t0, $t1, $t0) 
	beq $a2, $t0, num_detected #if number in cell ($t0) equals the number to check ($a2) return 0
.end_macro

.globl safe_to_place
#A function to check if a given number is safe to place in a specific position
# $a0 - x
# $a1 - y
# $a2 - number
# uses regesters $t0 to $t5
safe_to_place: 
	
	#check if row is safe
	for($t5, 0, 8, row_body)
	
	#check if col is safe
	for($t5, 0, 8, col_body)
	
	#check if box is safe
	#calculate the start position of the current box
	li $t4, 3
	modulo($a0, $t4, $t5) #mod x and 3 into $t5
	sub $t5, $a0, $t5 #$t5 = x - $t5 to get box start x
	modulo($a1, $t4, $t4) #mod y and 3 into $t4
	sub $t4, $a1, $t4 #$t4 = y - $t4 to get box start y
	
	for($t2, 0, 2, box_outer)
	
	li $v0, 1 #if none of the previous checks branched, return that it is safe
	jr $ra

num_detected:
	li $v0, 0 #if any of the previous checks branched, return that it is not safe
	jr $ra
