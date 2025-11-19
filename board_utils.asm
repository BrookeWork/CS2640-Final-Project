#Board utilities
.include "entry_manip.asm"

.macro row_safe(%row, %num) #A macro to check if a given number is safe to place within a specific row 0-8

.end_macro

.macro col_safe(%col, %num) #A macro to check if a given number is safe to place within a specific column 0-8

.end_macro

.macro box_safe(%x, %y, %num) #A macro to check if a given number is safe to place within a specific box

.end_macro

.globl safe_to_place
#A function to check if a given number is safe to place in a specific position
# $a0 - x
# $a1 - y
# $a2 - number
safe_to_place: 
	row_safe($a1, $a2)
	col_safe($a0, $a2)
	row_safe($a0, $a1, $a2)
	and $v0, $t0, $t1
	and $v0, $v0, $t2
	jr $ra

