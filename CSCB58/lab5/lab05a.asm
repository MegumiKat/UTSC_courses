.data 
# TODO: What are the following 5 lines doing?
promptA: .asciiz "Enter an int A: "
promptB: .asciiz "Enter an int B: "
promptC: .asciiz "Enter an int C: "
resultDelta: .asciiz "B^2 - 4AC =  "
resultNum: .asciiz "Num of solutions = "
newline: .asciiz "\n"
.text #1008837840 Changze Wu

.globl main
main:
	# print the string
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, promptA # Load address of promptA into register $a0 (argument for syscall)
	syscall 
	# read the int from the user
	li $v0, 5 # Load immediate value 5 into register $v0 (syscall code for reading integer)
	syscall 
	move $t5, $v0 # Move the integer read from input to register $t5
	 # Repeat the above process for promptB and promptC
	li $v0, 4
	la $a0, promptB
	syscall
	#same
	li $v0, 5
	syscall 
	move $t6, $v0
	#same
	li $v0, 4
	la $a0, promptC
	syscall
	#same
	li $v0, 5
	syscall 
	move $t7, $v0
	# calculate the 4ac
	mul $t3, $t5, $t7 # Multiply A and C, store result in $t3
	mul $t3, $t3, 4 # Multiply result by 4, store in $t3
	# calculate b^2
	mul $t6, $t6, $t6 # Multiply B by itself (B^2), store result in $t6
	sub $t1, $t6, $t3 # Subtract 4AC from B^2, store result in $t1
	# different condition
	beq $t1, $zero, one # Branch if $t1 == 0, go to label one
	blt $t1, $zero, no # Branch if $t1 < 0, go to label no
	bgt $t1, $zero, two # Branch if $t1 > 0, go to label two

one:
	# set to 1
	li $t0, 1 # Load immediate value 1 into register $t0 (represents one solution)
	j end # Unconditional jump to label end
	
no:
	# same
	li $t0, 0 # Load immediate value 0 into register $t0 (represents no solution)
	j end # Unconditional jump to label end
	
two:
	# same
	li $t0, 2  # Load immediate value 2 into register $t0 (represents two solutions)
	j end # Unconditional jump to label end
	
end:
	# same in man
	li $v0, 4  # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, resultDelta  # Load address of resultDelta into register $a0 (argument for syscall)
	syscall 
	# print the delta
	li $v0, 1   # Load immediate value 1 into register $v0 (syscall code for printing integer)
	move $a0, $t1  # Move value of $t1 (B^2 - 4AC) into register $a0 (argument for syscall)
	syscall 
	# same
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, newline  # Load address of newline into register $a0 (argument for syscall)
	syscall 
	# same
	li $v0, 4  # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, resultNum # Load address of resultNum into register $a0 (argument for syscall)
	syscall 
	# print the number of solution
	li $v0, 1  # Load immediate value 1 into
	move $a0, $t0 # Move the number of solutions (stored in $t0) to register $a0 (argument for syscall)
	syscall 
	# same
	li $v0, 4 # Load immediate value 4 into register $v0 (syscall code for printing string)
	la $a0, newline # Load address of newline into register $a0 (argument for syscall)
	syscall 
	# finish process
	li $v0, 10 # Load immediate value 10 into register $v0 (syscall code for program exit)
	syscall
