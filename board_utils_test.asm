
.include "macros.asm"
.include "print_grid.asm"
.data
	.align 2
	grid: .space 324

#macro wrapper for safe to place function
.macro safe_to_place(%x, %y, %num, %dest)
	li $a0, %x
	li $a1, %y
	li $a2, %num
	jal safe_to_place
	move %dest, $v0
.end_macro

.text
.globl main
main:
	###########################################################
	# Test Case 1: Row conflict
	# Place a 3 at (2,2), then test placing another 3 in same row.
	# Expected output: 0 (cannot place)
	###########################################################
	li $s0, 3
	store_entry(2, 2, $s0)
	safe_to_place(5, 2, 3, $s1)
	printInt($s1)		  # Expect 0
	printChar('\n')

	###########################################################
	# Test Case 2: Column conflict
	# Existing 7 at (4,1). Attempt to place 7 somewhere else in column 1.
	# Expected output: 0 (cannot place)
	###########################################################
	li $s0, 7
	store_entry(4, 1, $s0)
	safe_to_place(8, 1, 7, $s1)
	printInt($s1)		  # Expect 0
	printChar('\n')

	###########################################################
	# Test Case 3: Box conflict
	# Existing 9 at (0,0). Test placing 9 somewhere else in same 3×3 box.
	# Expected output: 0 (cannot place)
	###########################################################
	li $s0, 9
	store_entry(0, 0, $s0)
	safe_to_place(1, 1, 9, $s1)
	printInt($s1)		  # Expect 0
	printChar('\n')

	###########################################################
	# Test Case 4: Free row/column/box
	# No conflicts: test placing 4 at (6,6) where nothing blocks it.
	# Expected output: 1 (can place)
	###########################################################
	safe_to_place(6, 6, 4, $s1)
	printInt($s1)		  # Expect 1
	printChar('\n')

	###########################################################
	# Test Case 5: Row free, column free, but box conflict
	# Existing 2 at (3,3). Attempt to place 2 at (5,4) which shares the box.
	# Expected output: 0 (cannot place)
	###########################################################
	li $s0, 2
	store_entry(3, 3, $s0)
	safe_to_place(5, 4, 2, $s1)
	printInt($s1)		  # Expect 0
	printChar('\n')

	###########################################################
	# Test Case 6: Row conflict but box free
	# Existing 8 at (7,2). Try placing 8 at (3,2).
	# Expected output: 0 (cannot place)
	###########################################################
	li $s0, 8
	store_entry(7, 2, $s0)
	safe_to_place(3, 2, 8, $s1)
	printInt($s1)		  # Expect 0
	printChar('\n')

	###########################################################
	# Test Case 7: Column conflict but row/box free
	# Existing 5 at (2,5). Try placing 5 at (6,5).
	# Expected output: 0 (cannot place)
	###########################################################
	li $s0, 5
	store_entry(2, 5, $s0)
	safe_to_place(6, 5, 5, $s1)
	printInt($s1)		  # Expect 0
	printChar('\n')

	###########################################################
	# Test Case 8: Completely free position
	# No conflicting numbers anywhere for 1 at (8,8).
	# Expected output: 1 (can place)
	###########################################################
	safe_to_place(8, 8, 1, $s1)
	printInt($s1)		  # Expect 1
	printChar('\n')

	# Exit program
	li $v0, 10
	syscall
	
.include "board_utils.asm" #include after