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

.macro printString(%str)
.data
myLabel: .asciiz %str
.text
	li $v0, 4
	la $a0, myLabel
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

.macro for (%regIterator, %from, %to, %bodyMacroName)
	add %regIterator, $zero, %from
loop:
	%bodyMacroName ()
	add %regIterator, %regIteratWor, 1
	ble %regIterator, %to, loop
.end_macro

.macro modulo (%a, %b, %result)
	div     %a, %b
	mfhi    %result
.end_macro
