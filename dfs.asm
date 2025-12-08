dfs:
    # Save registers we'll use
    addi $sp, $sp, -36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)
    
    # s7 will track solution count (0 = none, 1 = one found, 2+ = multiple)
    # Load current solution count from a global or pass it through recursion
    # For simplicity, we'll use a label to track solutions found
    
    # Find first empty cell (value = 0)
    la $s0, grid
    addi $s6, $s0, 324  # end pointer
    
dfs_find_empty:
    bge $s0, $s6, dfs_complete  # if no empty cells, solution found
    lw $t0, 0($s0)
    beqz $t0, dfs_found_empty   # found empty cell
    addi $s0, $s0, 4
    j dfs_find_empty
    
dfs_found_empty:
    # Calculate x and y coordinates
    la $t0, grid
    sub $s1, $s0, $t0
    srl $t1, $s1, 2         # index / 4
    li $t2, 9
    div $t1, $t2
    mflo $s3                # y = index / 9
    mfhi $s2                # x = index % 9
    
    # Try values 1-9
    li $s4, 1
    
dfs_try_value:
    bgt $s4, 9, dfs_backtrack  # tried all values, backtrack
    
    # Check if we already found 2+ solutions (early exit)
    la $t0, solution_count
    lw $t1, 0($t0)
    bge $t1, 2, dfs_multiple_solutions  # stop if 2+ solutions found
    
    # Check if value is safe to place
    move $a0, $s2
    move $a1, $s3
    move $a2, $s4
    
    # Save s0-s6 before calling safe_to_place (it uses t0-t5)
    addi $sp, $sp, -28
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)
    
    jal safe_to_place
    
    # Restore registers
    lw $s6, 0($sp)
    lw $s5, 4($sp)
    lw $s4, 8($sp)
    lw $s3, 12($sp)
    lw $s2, 16($sp)
    lw $s1, 20($sp)
    lw $s0, 24($sp)
    addi $sp, $sp, 28
    
    beqz $v0, dfs_next_value  # not safe, try next value
    
    # Place value and recurse
    sw $s4, 0($s0)
    jal dfs
    
    # CRITICAL: Restore cell to 0 after recursion (was dug earlier)
    sw $zero, 0($s0)
    
    # Check if we found 2+ solutions during recursion
    la $t0, solution_count
    lw $t1, 0($t0)
    bge $t1, 2, dfs_multiple_solutions
    
dfs_next_value:
    addi $s4, $s4, 1
    j dfs_try_value
    
dfs_backtrack:
    # No valid value found, return failure
    li $v0, 0
    j dfs_return
    
dfs_complete:
    # No empty cells found - found a complete solution!
    # Increment solution counter
    la $t0, solution_count
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    sw $t1, 0($t0)
    
    # Return success
    li $v0, 1
    j dfs_return

dfs_multiple_solutions:
    # Found 2+ solutions, return immediately with special code
    li $v0, 2  # Return 2 to indicate multiple solutions
    j dfs_return
    
dfs_return:
    # Restore registers
    lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36
    jr $ra