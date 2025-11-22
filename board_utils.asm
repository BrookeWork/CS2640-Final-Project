#Board utilities
.include "entry_manip.asm"
.include "macros.asm"

.macro row_body()
	load_entry($t6, $t8, $t5) 
	beq $t9, $t5, num_detected #if number in cell ($t5) equals the number to check ($t9) return 0
.end_macro

.macro col_body()
	load_entry($t8, $t6, $t5) 
	beq $t9, $t5, num_detected #if number in cell ($t5) equals the number to check ($t9) return 0
.end_macro

.macro box_outer()
	for($t3, 0, 2, box_inner)
.end_macro

.macro box_inner()
	add $t0, $t6, $t2
	add $t1, $t5, $t3
	load_entry($t0, $t1, $t4) 
	beq $t9, $t4, num_detected #if number in cell ($t4) equals the number to check ($t9) return 0
.end_macro

.globl safe_to_place
#A function to check if a given number is safe to place in a specific position
# $a0 - x
# $a1 - y
# $a2 - number
safe_to_place: 
	#move arguments to temporary registers
	move $t7, $a0
	move $t8, $a1
	move $t9, $a2
	
	#check if row is safe
	for($t6, 0, 8, row_body)
	
	#check if col is safe
	for($t6, 0, 8, col_body)
	
	#check if box is safe
	#calculate the start position of the current box
	li $t2, 3
	modulo($t7, $t2, $t6) #mod x and 3 into $t6
	sub $t6, $t7, $t6 #$t6 = x - $t6 to get box start x
	modulo($t8, $t2, $t5) #mod y and 3 into $t5
	sub $t5, $t8, $t5 #$t5 = y - $t5 to get box start y
	
	for($t2, 0, 2, box_outer)
	
	li $v0, 1 #if none of the previous checks branched, return that it is safe
	jr $ra

num_detected:
	li $v0, 0 #if any of the previous checks branched, return that it is not safe
	jr $ra