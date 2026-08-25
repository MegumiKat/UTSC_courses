.text # 1008837840 Changze Wu
.data
A: .word 5, 8, -3, 4, -7, 2, 33
B: .word 0:7
LEN: .word 5  # length of the arrays
newline: .asciiz "\n"


.globl main
.text

main:
	# initialize the relevant value
	la $a0, A
	lw $t6, LEN
	la $a1, B
	
	li $t0, 0 # index for revise
	li $t4, 0 # index for print
	
	la $a2, B
	j loop # jump to loop
	
loop:
	blt $t0, $t6, do # if index < length  then revise element in B
	j Exit # else go to print 
	
do:
	lw $t2, ($a0) # load the current index element in A
	andi $t3, $t2, 1 # if element is odd
	beq $t3, 1, odd # if odd go to odd
	mul $t2, $t2, 10 #else multi 10
	sw $t2, ($a1) # store the value of corresponding index in B
	add $t0, $t0, 1 # index++
	add $a0, $a0, 4 # array position in A ++
	add $a1, $a1, 4 # B++
	j loop # go back to loop
	
odd:
	mul $t2, $t2, 5 # multi 5
	sw $t2, ($a1) # store the value in B
	add $t0, $t0, 1 #same below
	add $a0, $a0, 4
	add $a1, $a1, 4
	j loop
	
Exit:
	blt $t4, $t6, doprint # if index < length
	
	li $v0, 10 # else finish
	syscall 
	
doprint:
	li $v0, 1 # syscall print int 
	lw $t5, ($a2) # load current element
	move $a0, $t5 # move ..
	syscall # print out
	
	add $t4, $t4, 1 # index++
	add $a2, $a2, 4 # position++
	
	li $v0, 4
	la $a0, newline
	syscall 
	
	j Exit # go back to exit
	
	
