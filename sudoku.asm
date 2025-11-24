.include "macros.asm"
.include "print_grid.asm"

.data
	.align 2
	grid: .space 324

.text
main:
	li $s0, 1
	store_entry(1, 2, $s0)
	store_entry(8, 0, $s0)
	li $s0, 5
	store_entry(5, 6, $s0)
	store_entry(7, 2, $s0)
	li $s0, 9
	store_entry(6, 7, $s0)
	store_entry(3, 3, $s0)
	print_grid()

	li $v0, 10
	syscall