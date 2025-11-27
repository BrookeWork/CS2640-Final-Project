# Adam Khalil
# verify_grid.asm:
# Checks whether the global Sudoku grid is completely + correctly filled || basically solvable.
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
    li $t0, 0 # t0 = row index y = 0

row_loop_y:
    bgt $t0, 8, rows_done # if y > 8, all rows checked

    li $t3, 0 # t3 = mask = 0 for this row
    li $t1, 0 # t1 = col index x = 0

row_loop_x:
    bgt $t1, 8, next_row # if x > 8, move to next row

    # load value at (x=t1, y=t0) into t2
    load_entry($t1, $t0, $t2)

    beq $t2, $zero, verify_fail # empty cell -> not solved

    # enforce 1..9
    li $t4, 1
    blt $t2, $t4, verify_fail
    li $t4, 9
    bgt $t2, $t4, verify_fail

    # bit = 1 << (value-1)
    addi $t2, $t2, -1
    li $t4, 1
    sllv $t4, $t4, $t2

    # if (mask & bit) != 0 -> duplicate
    and $t5, $t3, $t4
    bne $t5, $zero, verify_fail

    # mask |= bit
    or $t3, $t3, $t4

    addi $t1, $t1, 1
    j row_loop_x

next_row:
    addi $t0, $t0, 1
    j row_loop_y

rows_done:
    #### Check all columns ####
    li $t1, 0 # t1 = col index x = 0

col_loop_x:
    bgt $t1, 8, cols_done # if x > 8, all cols checked

    li  $t3, 0 # mask = 0 for this column
    li  $t0, 0 # t0 = row index y = 0

col_loop_y:
    bgt $t0, 8, next_col # if y > 8, move to next column

    load_entry($t1, $t0, $t2)
    beq $t2, $zero, verify_fail

    li $t4, 1
    blt $t2, $t4, verify_fail
    li $t4, 9
    bgt $t2, $t4, verify_fail

    addi $t2, $t2, -1
    li $t4, 1
    sllv $t4, $t4, $t2

    and $t5, $t3, $t4
    bne $t5, $zero, verify_fail

    or $t3, $t3, $t4

    addi $t0, $t0, 1
    j col_loop_y

next_col:
    addi $t1, $t1, 1
    j col_loop_x

cols_done:
    # check all 3x3 boxes
    li $t6, 0 # t6 = box start y (0,3,6)

box_y_loop:
    bgt $t6, 6, boxes_done # if box_y > 6, all boxes checked
    li  $t7, 0 # t7 = box start x (0,3,6)

box_x_loop:
    bgt $t7, 6, next_box_row

    li $t3, 0 # mask = 0 for this box
    li $t0, 0 # t0 = dy = 0

box_dy_loop:
    bgt $t0, 2, box_done_cells
    li $t1, 0 # t1 = dx = 0

box_dx_loop:
    bgt $t1, 2, next_dy

    # x = box_x + dx  (t8)
    # y = box_y + dy  (t9)
    add $t8, $t7, $t1
    add $t9, $t6, $t0

    load_entry($t8, $t9, $t2)
    beq $t2, $zero, verify_fail

    li $t4, 1
    blt $t2, $t4, verify_fail
    li $t4, 9
    bgt $t2, $t4, verify_fail

    addi $t2, $t2, -1
    li $t4, 1
    sllv $t4, $t4, $t2

    and $t5, $t3, $t4
    bne $t5, $zero, verify_fail

    or $t3, $t3, $t4

    addi $t1, $t1, 1
    j box_dx_loop

next_dy:
    addi $t0, $t0, 1
    j box_dy_loop

box_done_cells:
    addi $t7, $t7, 3 # move to next box in this row
    j box_x_loop

next_box_row:
    addi $t6, $t6, 3 # move to next box row
    j box_y_loop

boxes_done:
    li $v0, 1 # all checks passed
    jr $ra

verify_fail:
    li $v0, 0
    jr $ra