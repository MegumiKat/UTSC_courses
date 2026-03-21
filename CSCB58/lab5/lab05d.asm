.text # 1008837840 Changze Wu
.data
promptA: .asciiz "Enter an int A: "
promptB: .asciiz "Enter an int B: "
promptC: .asciiz "Enter an int C: "
before: .asciiz " Before function "
resultAdd: .asciiz "A + B + C = "
sol: .asciiz "Num solutions for Ax^2 + Bx + C is = "
newline: .asciiz "\n"

.globl main
.text 

main:
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, promptA # Load address of promptA into register $a0 (argument for syscall)
	syscall 
	
	li $v0, 5 # Load immediate value 5 into register $v0 (syscall code for reading integer)
	syscall 
	move $s0, $v0 # Move the input integer to register $s0
	
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, promptB # Load address of promptB into register $a0 (argument for syscall)
	syscall 
	
	li $v0, 5 # Load immediate value 5 into register $v0 (syscall code for reading integer)
	syscall 
	move $s1, $v0 # Move the input integer to register $s1
	
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, promptC # Load address of promptC into register $a0 (argument for syscall)
	syscall  
	
	li $v0, 5 # Load immediate value 5 into register $v0 (syscall code for reading integer)
	syscall 
	move $s2, $v0 # Move the input integer to register $s2
	
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, before # Load address of before into register $a0 (argument for syscall)
	syscall
	
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, newline # Load address of newline into register $a0 (argument for syscall)
	syscall
	
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, resultAdd # Load address of resultAdd into register $a0 (argument for syscall)
	syscall 
	
	jal do_addition # Jump and link to do_addition function
	
	move $t3, $v0
	
	li $v0, 1 # Load immediate value 1 into register $v0 (syscall code for printing integer)
	move $a0, $t3 # Move the result of addition (stored in $t3) to register $a0 (argument for syscall)
	syscall 
	
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, newline # Load address of newline into register $a0 (argument for syscall)
	syscall 
	
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, sol # Load address of sol into register $a0 (argument for syscall)
	syscall 
	
	jal n_solutions # Jump and link to n_solutions function
	
	li $v0, 1 # Load immediate value 1 into register $v0 (syscall code for printing integer)
	move $a0, $t4 # Move the number of solutions (stored in $t4) to register $a0 (argument for syscall)
	syscall 
	
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, newline # Load address of newline into register $a0 (argument for syscall)
	syscall 
	
	li $v0, 10 # Load immediate value 10 into register $v0 (syscall code for program exit)
	syscall 
	
do_addition:
	add $v0, $s0, $s1 # Add values of A and B, store result in $t3
	add $v0, $t3, $s2 # Add value of C to result, store final result in $t3

	jr $ra # Jump back to the calling function
	
	
n_solutions:
	addi $sp, $sp, -16 # Allocate space on the stack for saving registers
	sw $ra, 0($sp) # Save return address on the stack
	sw $t0, 4($sp) # Save temporary register $t0 on the stack
	sw $t1, 8($sp) # Save temporary register $t1 on the stack
	sw $t2, 12($sp) # Save temporary register $t2 on the stack
	
	mul $t0, $s0, $s2 # Multiply the value of A (stored in $s0) by the value of C (stored in $s2), store the result in $t0
	mul $t0, $t0, 4 # Multiply the result by 4, as indicated by the comment
	mul $t1, $s1, $s1 # Multiply the value of B (stored in $s1) by itself, store the result in $t1
	sub $s3, $t1, $t0 # Subtract the value of $t0 (A * C * 4) from the value of $t1 (B^2), store the result in $s3
	
	bgt $s3, $zero, two # Branch if $s3 > 0, if true, jump to label 'two'
	blt $s3, $zero, zero # Branch if $s3 < 0, if true, jump to label 'zero'
	beq $s3, $zero, one # Branch if $s3 == 0, if true, jump to label 'one'
	
two:
	add $t4, $zero, 2 # Store the value 2 in $t4
	j end # Jump to label 'end'
	
one:
	add $t4,$zero, 1 # Store the value 1 in $t4
	j end # Jump to label 'end'
	
zero:
	add $t4, $zero, $zero # Store the value 0 in $t4
	j end # Jump to label 'end'
	
end:
	lw $t2, 12($sp) # Load the value from the stack (presumably $t2) back into $t2
	lw $t1, 8($sp) # Load the value from the stack (presumably $t1) back into $t1
	lw $t0, 4($sp) # Load the value from the stack (presumably $t0) back into $t0
	lw $ra, 0($sp) # Load the return address from the stack back into $ra
	addi $sp, $sp, 16 # Deallocate the space on the stack
	jr $ra # Jump back to the calling function
	

	
	
	
	
