#Board utilities
.include "entry_manip.asm"

.macro row_safe(%row, %num) #A macro to check if a given number is safe to place within a specific row 0-8

.end_macro

.macro col_safe(%col, %num) #A macro to check if a given number is safe to place within a specific column 0-8

.end_macro

.macro box_safe(%x, %y, %num) #A macro to check if a given number is safe to place within a specific box

.end_macro

.macro safe_to_place(%x, %y, %num) #A macro to check if a given number is safe to place in a specific position

.end_macro