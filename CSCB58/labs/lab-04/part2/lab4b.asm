.data 
promptA: .asciiz "Enter an int A: "
promptB: .asciiz "Enter an int B: "
resultAdd: .asciiz "A + B + C = "
promptC: .asciiz "Enter an int C: "
newline: .asciiz "\n"

.globl main
.text
main:
	li $v0, 4
	la $a0, promptA
	syscall 
	
	li $v0, 5
	syscall 
	move $t0, $v0
	
	li $v0, 4
	la $a0, promptB
	syscall 
	
	li $v0, 5
	syscall 
	move $t1, $v0
	
	li $v0, 4
	la $a0, promptC
	syscall 
	
	li $v0, 5
	syscall 
	move $t2, $v0
	
	add $t0, $t0, $t1
	add $t0, $t0, $t2
	
	li $v0, 4
	la $a0, resultAdd
	syscall 
	
	li $v0, 1
	move $a0, $t0
	syscall 
	
	li $v0, 4
	la $a0, newline
	syscall 
	
	li $v0, 10
	syscall 
