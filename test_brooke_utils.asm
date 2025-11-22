#test_brooke_utils.asm
.include "brooke_board_utils.asm"
.include "print_grid.asm"
.macro print_bool(%bool)
	lb $t0, %bool
	beq $t0, 0, bool_is_zero
	li $v0, 1
	li $a0, 1
	syscall
	j exit
	bool_is_zero:
	li $v0, 1
	li $a0, 0
	syscall
	exit:
.end_macro
.data
x: .word 2
y: .word 2
other_val: .word 3
value: .word 9
bool: .byte '\n'
.text
main:
	li $t0, 0
	li $t1, 0
	#store_entry(x, y, other_val)
	print_grid
	li $v0, 11
	lb $a0, bool
	syscall
	safe_to_place(x, y, value, bool)
	print_bool(bool)
	
	store_entry(x, y, value)
	safe_to_place(x, y, value, bool)
	print_bool(bool)
	
	lw $t0, x
	addi $t0, $t0, 4
	sw $t0, x
	lw $t0, y
	addi $t0, $t0, 4
	sw $t0, y
	
	
	safe_to_place(x, y, value, bool)
	print_bool(bool)
	
	li $v0, 10
	syscall