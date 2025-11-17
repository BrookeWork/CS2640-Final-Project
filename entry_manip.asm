.data
.align 2
grid: .space 364
.macro store_entry(%x, %y, %value)
	lw $t0, %y
	subi $t0, $t0, 1
	mul $t0, $t0, 9
	lw $t1, %x
	subi $t1, $t1, 1
	add $t0, $t0, $t1
	mul $t0, $t0, 4
	lw $t1, %value
	sw $t1, grid($t0)
.end_macro
.macro load_entry(%x, %y, %variable)
	lw $t0, %y
	subi $t0, $t0, 1
	mul $t0, $t0, 9
	lw $t1, %x
	subi $t1, $t1, 1
	add $t0, $t0, $t1
	mul $t0, $t0, 4
	lw $t1, grid($t0)
	sw $t1, %variable
.end_macro
