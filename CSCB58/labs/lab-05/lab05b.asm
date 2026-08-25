.data
promptA: .asciiz "Enter an int A: "
promptB: .asciiz "Enter an int B: "
resultGCD: .asciiz "GCD(A, B) = "
newline: .asciiz "\n"

.globl main
.text #1008837840

main:
	# print the string
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, promptA # Load address of promptA into register $a0 (argument for syscall)
	syscall 
	# read the int from the user
	li $v0, 5 # Load immediate value 5 into register $v0 (syscall code for reading integer)
	syscall 
	move $t8, $v0 # Move the integer read from input to register $t8
	# Repeat the above process for promptB
	li $v0, 4
	la $a0, promptB
	syscall 
	# same
	li $v0, 5
	syscall 
	move $t9, $v0
	 # Jump and link to start loop
	jal loop
	# same
	li $v0, 4
	la $a0, newline
	syscall 
	# Print the result string "GCD(A, B) = "
	li $v0, 4
	la $a0, resultGCD
	syscall 
	# Print the result of the GCD
	li $v0, 1
	move $a0, $t0
	syscall 
	# finish the process
	li $v0, 10
	syscall 
		
	
loop:
	#if a==b the exit
	beq $t8, $t9, Exit
	#else
	bgt $t8, $t9, if # if a > b go to if
	sub $t9, $t9, $t8 # else b = b - a
	
	j loop
	
if:
	sub $t8, $t8, $t9 # This is essentially swapping a and b in order to maintain the condition a > b
	j loop # go back to loop
	
Exit:
	move $t0, $t9 # change 
	jr $ra # go back to main and return the t0
