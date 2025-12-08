.macro store_entry_mem(%x, %y, %value)
	lw $t0, %y
	mul $t0, $t0, 9
	lw $t1, %x
	add $t0, $t0, $t1
	mul $t0, $t0, 4
	lw $t1, %value
	sw $t1, grid($t0)
.end_macro
.macro load_entry_mem(%x, %y, %variable)
	lw $t0, %y
	mul $t0, $t0, 9
	lw $t1, %x
	add $t0, $t0, $t1
	mul $t0, $t0, 4
	lw $t1, grid($t0)
	sw $t1, %variable
.end_macro

.macro load_entry(%x, %y, %variable)
	add $s0, $zero, %y #entered load_entry
	mul $s0, $s0, 9
	add $s1, $zero, %x
	add $s0, $s0, $s1
	sll $s0, $s0, 2
	la $s1, grid
	addu $s1, $s1, $s0
	lw %variable, 0($s1)
.end_macro

.macro store_entry(%x, %y, %value)
	add $t0, $zero, %y #entered store_entry
	mul $t0, $t0, 9
	add $t1, $zero, %x
	add $t0, $t0, $t1
	sll $t0, $t0, 2
	la $t1, grid
	addu $t1, $t1, $t0
	sw %value, 0($t1)
.end_macro
