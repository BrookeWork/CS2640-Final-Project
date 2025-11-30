#Commonly used macros

.macro printInt(%int)
	li $v0, 1
	add $a0, $zero, %int
	syscall
.end_macro

.macro getInt(%dest)
	li $v0, 5
	syscall
	move %dest, $v0
.end_macro

.macro printString(%label)
	li  $v0, 4
	la  $a0, %label
	syscall
.end_macro

.macro printChar(%char)
	li $v0, 11
	li $a0, %char
	syscall
.end_macro

.macro getChar(%dest)
	li $v0, 12
	syscall
	move %dest, $v0
.end_macro

.macro end
	li $v0, 10
	syscall
.end_macro

.macro for_range(%iter, %from, %to, %bodyLabel)
	add %iter, $zero, %from
loop:
	jal %bodyLabel
	add %iter, %iter, 1
	ble %iter, %to, loop
.end_macro

.macro modulo(%a, %b, %result)
	div %a, %b
	mfhi %result
.end_macro

.macro randi_range(%from, %to, %dest)
	#range_size = (%to - %from + 1)
	li $t9, %to #randi range
	addi $t9, $t9, 1
	li $t8, %from
	subu $t9, $t9, $t8

	#syscall 42: random int in [0, t9)
	li $v0, 42
	move $a1, $t9
	syscall

	#shift into target range: dest = v0 + from
	addu %dest, $a0, $t8
.end_macro

#print an array with base address and amount of numbers
.macro print_array(%base, %len)
	add $t0, $zero, %base # current pointer
	add $t1, $zero, %len # number of items

loop:
	beq $t1, $zero, exit # stop when length = 0
	
	lw $a0, 0($t0)
	li $v0, 1
	syscall
	
	# print space
	li	  $a0, 32
	li	  $v0, 11
	syscall
	
	# move to next element
	addi	$t0, $t0, 4
	addi	$t1, $t1, -1
	j loop
	
exit:
	# print newline at end
	li	  $a0, 10
	li	  $v0, 11
	syscall
.end_macro

.macro not_in_array(%num, %base, %len)
	add $t0, $zero, %num # number to search for
	add $t1, $zero, %base # array pointer
	add $t2, $zero, %len # length

loop:
	beq $t2, $zero, not_found
	# load current element and check if target
	lw $t3, 0($t1)
	beq $t3, $t0, found

	addi $t1, $t1, 4
	addi $t2, $t2, -1
	j loop

found:
	li $v0, 0
	j exit

not_found:
	li $v0, 1

exit:
.end_macro
