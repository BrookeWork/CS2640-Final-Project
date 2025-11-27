# TJ Vasquez
# generate_puzzle.asm

#macro wrapper for safe to place function
.macro safe_to_place(%x, %y, %num, %dest)
	move $a0, %x
	move $a1, %y
	move $a2, %num
	jal safe_to_place
	move %dest, $v0
.end_macro

.macro generate_puzzle(%targetDifficulty)
	#Initialize board
	#Place 11 initial values in Las Vegas algorithm
	li $s0, 0
	
placed_loop:
	#generate random x location in $s1 and random y location in $s2
	randi_range(0, 8, $s1)
	randi_range(0, 8, $s2)
	
	#check cell is empty
	load_entry($s1, $s2, $s3) 
	bne $s3, $zero, placed_loop
	
	#generate random number in $s3
	randi_range(1, 9, $s3)
	
	#check if it is safe to place the number in the grid
	safe_to_place($s1, $s2, $s3, $s4)
	
	printInt($s4)
	beq $s4, $zero, placed_loop
	
	#now safe to place the number
	store_entry($s1, $s2, $s3)
	printInt($s3)

	#if sucessfully placed increment $s0 and loop
	add $s0, $s0, 1
	blt $s0, 11, placed_loop
	

	#Use depth-first search to find a solution
	#Poke holes in the solution to create a puzzle
.end_macro