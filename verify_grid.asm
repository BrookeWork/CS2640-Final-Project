# Adam Khalil
# verify_grid.asm:
# Checks whether the global Sudoku grid is completely + correctly filled || basically solved.
# Returns:
#   $v0 = 1  if the grid is a valid solved Sudoku
#   $v0 = 0  otherwise
#
# things required:
#     'grid' symbol must exist (9x9 ints)
#     'load_entry' macro must be available (from entry_manip.asm)

.globl verify_grid
verify_grid:
    # check all rows
    li $s0, 0 # t0 = row index y = 0

row_loop_y:
    bgt $s0, 8, rows_done # if y > 8, all rows checked

    li $s3, 0 # t3 = mask = 0 for this row
    li $s1, 0 # t1 = col index x = 0

row_loop_x:
    bgt $s1, 8, next_row # if x > 8, move to next row

    # load value at (x=t1, y=t0) into t2
    load_entry($s1, $s0, $s2)

    beq $s2, $zero, verify_fail # empty cell -> not solved

    # enforce 1..9
    li $s4, 1
    blt $s2, $s4, verify_fail
    li $s4, 9
    bgt $s2, $s4, verify_fail

    # bit = 1 << (value-1)
    addi $s2, $s2, -1
    li $s4, 1
    sllv $s4, $s4, $s2

    # if (mask & bit) != 0 -> duplicate
    and $s5, $s3, $s4
    bne $s5, $zero, verify_fail

    # mask |= bit
    or $s3, $s3, $s4

    addi $s1, $s1, 1
    j row_loop_x

next_row:
    addi $s0, $s0, 1
    j row_loop_y

rows_done:
    #### Check all columns ####
    li $s1, 0 # t1 = col index x = 0

col_loop_x:
    bgt $s1, 8, cols_done # if x > 8, all cols checked

    li  $s3, 0 # mask = 0 for this column
    li  $s0, 0 # t0 = row index y = 0

col_loop_y:
    bgt $s0, 8, next_col # if y > 8, move to next column

    load_entry($s1, $s0, $s2)
    beq $s2, $zero, verify_fail

    li $s4, 1
    blt $s2, $s4, verify_fail
    li $s4, 9
    bgt $s2, $s4, verify_fail

    addi $s2, $s2, -1
    li $s4, 1
    sllv $s4, $s4, $s2

    and $s5, $s3, $s4
    bne $s5, $zero, verify_fail

    or $s3, $s3, $s4

    addi $s0, $s0, 1
    j col_loop_y

next_col:
    addi $s1, $s1, 1
    j col_loop_x

cols_done:
    # check all 3x3 boxes
    li $s6, 0 # t6 = box start y (0,3,6)

box_y_loop:
    bgt $s6, 6, boxes_done # if box_y > 6, all boxes checked
    li  $s7, 0 # t7 = box start x (0,3,6)

box_x_loop:
    bgt $s7, 6, next_box_row

    li $s3, 0 # mask = 0 for this box
    li $s0, 0 # t0 = dy = 0

box_dy_loop:
    bgt $s0, 2, box_done_cells
    li $s1, 0 # t1 = dx = 0

box_dx_loop:
    bgt $s1, 2, next_dy

    # x = box_x + dx  (t8)
    # y = box_y + dy  (t9)
    add $t8, $s7, $s1
    add $t9, $s6, $s0

    load_entry($t8, $t9, $s2)
    beq $s2, $zero, verify_fail

    li $s4, 1
    blt $s2, $s4, verify_fail
    li $s4, 9
    bgt $s2, $s4, verify_fail

    addi $s2, $s2, -1
    li $s4, 1
    sllv $s4, $s4, $s2

    and $s5, $s3, $s4
    bne $s5, $zero, verify_fail

    or $s3, $s3, $s4

    addi $s1, $s1, 1
    j box_dx_loop

next_dy:
    addi $s0, $s0, 1
    j box_dy_loop

box_done_cells:
    addi $s7, $s7, 3 # move to next box in this row
    j box_x_loop

next_box_row:
    addi $s6, $s6, 3 # move to next box row
    j box_y_loop

boxes_done:
    li $v0, 1 # all checks passed
    jr $ra

verify_fail:
    li $v0, 0
    jr $ra
