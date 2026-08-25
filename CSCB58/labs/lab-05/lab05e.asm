.text # 1008837840 Changze Wu
.data
Enter: .asciiz "Enter a number: "
Result: .asciiz "The result is: "
newline: .asciiz "\n"

.globl main
.text

main:
	li $v0, 4 # Load system call code for printing string
	la $a0, Enter  # Load address of the string "Enter"
	syscall 
	
	li $v0, 5 # Load system call code for reading integer
	syscall  # Perform system call
	move $s0, $v0	 # Save the integer input in $s0
	
	li $v0, 4  # Load system call code for printing string
	la $a0, Result # Load address of the string "Result"
	syscall 
	
	move $a0, $s0  # Move the integer input to $a0 for function call
	
	jal mystery # Call the mystery function
	 
	li $v0, 1  # Load system call code for printing integer
	move $a0, $a1 # Move the result from $a1 to $a0
	syscall 
	
	li $v0, 10  # Load system call code for exit
	syscall 
	
mystery:
	addi $sp, $sp, -4 # Adjust stack pointer to make room for return address
	sw $ra, 0($sp) # Save return address on the stack
	
	
	
	beq $a0, $zero, return_zero # If $a0 is zero, jump to return_zero
	sub $a0, $a0, 1 # Decrement $a0
	jal mystery # Recursive call
	add $a0, $a0, 1 # Restore $a0 after recursive call
	move $t0, $a1  # Save the result of the recursive call in $t0
	
	mul $t0, $a0, 2  # Calculate 2 * ($a0 - 1)
	sub $t0, $t0, 1 # Calculate (2 * ($a0 - 1)) - 1
	
	add $a1, $a1, $t0 # Add the result of the recursive call to (2 * ($a0 - 1)) - 1
	
	lw $ra, 0($sp)  # Restore return address
	addi $sp, $sp, 4 # Restore stack pointer
	jr $ra # Return from function
	
return_zero:
	move $a1, $zero # If input is zero, return zero
	lw $ra, 0($sp) # Restore return address
	addi $sp, $sp, 4 # Restore stack pointer
	jr $ra # Return from function
	
	
	