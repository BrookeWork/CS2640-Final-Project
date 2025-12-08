# MIPS Sudoku – CS 2640 Final Project
**Authors:** Adam Khalil, Brooke Landry, Christian Parkinson, TJ Vasquez

### Project Overview
A complete Sudoku puzzle generator and interactive player written entirely in **MIPS assembly** for the MARS simulator.

**Features:**
- Procedurally generates a **unique, valid, solvable** Sudoku puzzle every time
- Five difficulty levels (Easy → Evil) with realistic clue counts
- Uses Las Vegas randomization + backtracking DFS + uniqueness enforcement
- Applies random symmetric transformations (rotations, block/column swaps) for visual variety
- Full interactive gameplay with input validation and real-time grid display
- Detects completion and congratulates the player

### How to Run
1. Download MARS: http://courses.missouristate.edu/KenVollmar/MARS/
2. Open `sudoku.asm` (all `.include` files must be in the same directory)
3. Assemble (F3) → Run → Go (F5)

### Gameplay
- Choose difficulty **1–5** (Easy to Evil)
- Enter **Row (1–9)** → **Column (1–9)** → **Number (1–9)**
- Type **0** at any prompt to cancel the current turn
- Original clues cannot be overwritten
- Solve the puzzle → win!

### Difficulty Levels (Approximate Number of Given Cells)
| Level | Name     | Given Cells |
|-------|----------|-------------|
| 1     | Easy     | 65–70       |
| 2     | Medium   | 45–55       |
| 3     | Hard     | 34–40       |
| 4     | Expert   | 30–35       |
| 5     | Evil     | 22–28       |

*(Actual number is randomized within a range around the values in `given_ranges: .word 70, 50, 36, 32, 28`)*

### File Overview
- `sudoku.asm`           → main loop & UI
- `generate_puzzle.asm`  → full generator (Las Vegas + DFS + hole digging + shuffling)
- `board_utils.asm`      → safe_to_place, swaps, rotation, etc.
- `dfs.asm`              → backtracking solver (used for generation & uniqueness)
- `verify_grid.asm`      → checks if player solved it
- `print_grid.asm`       → pretty grid printing
- `entry_manip.asm` & `macros.asm` → helper macros

### Notes
- Harder puzzles (especially Evil) may take a minutes to generate due to strict uniqueness checking
- Fully tested and working in MARS 4.5+


**Happy puzzling!**