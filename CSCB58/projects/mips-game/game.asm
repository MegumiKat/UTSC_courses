##################################################################### #
# CSCB58 Winter 2024 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Changze Wu, 1008837840, wuchangz, changze.wu@mail.utoronto.ca #
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed) # - Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies) 

# Milestone 1: basic graphics
# --Draw the level , Draw the player character, Draw at least 2 additional objects

# Milestone 2: basic controls
# -- Playercanmove, Platform collision and gravity:, Vertical movement:, Collisionwithobjects, Allow restarting the game at any point by pressing the r key on the keyboard AND
# quitting the game at any point by pressing the q key.

# Milestone 3: Finished Game
# --Health, Fail condition, Win condition

# Milestone 4: Additional features and polish [
# --Movingobjects, Moving platforms, Pick-upeffects, Doublejump, Start menu 

# Which approved features have been implemented for milestone 3?
# all of above
# (See the assignment handout for the list of additional features) # 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# https://youtu.be/7cab0eqBv7c
#
# Are you OK with us sharing the video with people outside course staff?
# - yes
# 
# #####################################################################
# Game info
.eqv BASE_ADDRESS 	0x10008000
.eqv BACKGROUND_WIDTH 	64
.eqv BACKGROUND_HEIGHT 	64
.eqv REFRESH_RATE 	40 	# in miliseconds
# Colors
.eqv YELLOW		0xffc20e
.eqv BLACK		0x000000
.eqv BLUE  		0x4d6df3
.eqv DARK_BLUE  	0x2f3699
.eqv BABY_YELLOW	0xfff9bd
.eqv RED		0xed1c24
.eqv GREEN		0x52822b
.eqv ORANGE		0xff7e00
.eqv BABY_GREEN		0xa8e61d
.eqv BROWN		0x75391e
.eqv WHITE		0xffffff
.eqv PURPLE		0x6f3198
.eqv GRAY		0x464646
# Key board
.eqv KEY_W 119
.eqv KEY_Q 113
.eqv KEY_R 114
.eqv KEY_A 97
.eqv KEY_S 115
.eqv KEY_D 100
.eqv SPACE 32
# GRAVITY
.eqv GRAVITY_data 	1	
.eqv FALL 		1	
.eqv JUMP 		-5 	
# ENEMY
.eqv ENEMY_WIDTH 	7
.eqv ENEMY_HEIGHT 	6
# Player
.eqv PLAYER_WIDTH 	5 # 5
.eqv PLAYER_HEIGHT 	8 # 8
# Pisition data
.eqv PLAYER_START_X 30
.eqv PLAYER_START_Y 54

.eqv P1_X 20
.eqv P1_Y 63

.eqv P2_X 20
.eqv P2_Y 52

.eqv P3_X 30
.eqv P3_Y 42

.eqv E_X 30
.eqv E_Y 30

.eqv E2_X 30
.eqv E2_Y 20
# ITEMS
.eqv PICKUP_SIZE 4

.eqv TIME_X 10
.eqv TIME_Y 50

.eqv JUMP_X 45
.eqv JUMP_Y 50

.eqv FLY_X 25
.eqv FLY_Y 25

.eqv SLOW 25

.data
LIVE: 			.word 	3 

PLATFORM_1: .word P1_X, P1_Y, 24			
PLATFORM_2: .word P2_X, P2_Y, 12
PLATFORM_3: .word P3_X, P3_Y, 24, 10, 40, 1
ENEMY: .word E_X, E_Y, 0, 20, 50, 1
ENEMY_2: .word E2_X, E2_Y, 0, 20, 55, 1
PICKUP_TIME: .word TIME_X, TIME_Y, 0, 20, 40, 1  			
PICKUP_JUMP: .word JUMP_X, JUMP_Y, 0, 20, 50, 1 
PICKUP_FLY: .word FLY_X, FLY_Y, 0, 20, 50, 1 

.text
.globl main
main:
li $s0, 0 # STATES
li $s1, PLAYER_START_X
li $s2, PLAYER_START_Y
li $s3, 0 # IF GROUND
li $s4, 0 # FALLING SPEED
li $s5, 2 # LIVES
li $s6, 0 # JUMP STATE(0-inactive, 1-available, 2-DONE, 3-FLY)
li $s7, 0  # FLY


StartTitle:
	jal DRAW_BACKGROUND
	li $v0, 32
	li $a0, 30
	addi $t0, $zero, BASE_ADDRESS
	li $t2, BLACK
	# first line
	addi $t1, $t0, 3392 # S
	sw $t2, 0($t1)
	addi $t1, $t0, 3396
	sw $t2, 0($t1)
	addi $t1, $t0, 3400
	sw $t2, 0($t1)
	addi $t1, $t0, 3404
	sw $t2, 0($t1)
	addi $t1, $t0, 3408
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3416 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 3420
	sw $t2, 0($t1)
	addi $t1, $t0, 3424
	sw $t2, 0($t1)
	addi $t1, $t0, 3428
	sw $t2, 0($t1)
	addi $t1, $t0, 3432
	sw $t2, 0($t1)
	addi $t1, $t0, 3436
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3448 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 3452
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3468 # R
	sw $t2, 0($t1)
	addi $t1, $t0, 3472
	sw $t2, 0($t1)
	addi $t1, $t0, 3476
	sw $t2, 0($t1)
	addi $t1, $t0, 3480
	sw $t2, 0($t1)
	addi $t1, $t0, 3484
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3496 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 3500
	sw $t2, 0($t1)
	addi $t1, $t0, 3504
	sw $t2, 0($t1)
	addi $t1, $t0, 3508
	sw $t2, 0($t1)
	addi $t1, $t0, 3512
	sw $t2, 0($t1)
	addi $t1, $t0, 3516
	sw $t2, 0($t1)
	# second line
	addi $t1, $t0, 3644 # S
	sw $t2, 0($t1)
	addi $t1, $t0, 3648
	sw $t2, 0($t1)
	addi $t1, $t0, 3652
	sw $t2, 0($t1)
	addi $t1, $t0, 3656
	sw $t2, 0($t1)
	addi $t1, $t0, 3660
	sw $t2, 0($t1)
	addi $t1, $t0, 3664
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3672 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 3676
	sw $t2, 0($t1)
	addi $t1, $t0, 3680
	sw $t2, 0($t1)
	addi $t1, $t0, 3684
	sw $t2, 0($t1)
	addi $t1, $t0, 3688
	sw $t2, 0($t1)
	addi $t1, $t0, 3692
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3700 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 3704
	sw $t2, 0($t1)
	addi $t1, $t0, 3708
	sw $t2, 0($t1)
	addi $t1, $t0, 3712
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3724 # R
	sw $t2, 0($t1)
	addi $t1, $t0, 3728
	sw $t2, 0($t1)
	addi $t1, $t0, 3732
	sw $t2, 0($t1)
	addi $t1, $t0, 3736
	sw $t2, 0($t1)
	addi $t1, $t0, 3740
	sw $t2, 0($t1)
	addi $t1, $t0, 3744
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3752 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 3756
	sw $t2, 0($t1)
	addi $t1, $t0, 3760
	sw $t2, 0($t1)
	addi $t1, $t0, 3764
	sw $t2, 0($t1)
	addi $t1, $t0, 3768
	sw $t2, 0($t1)
	addi $t1, $t0, 3772
	sw $t2, 0($t1)
	syscall 
	# third line
	addi $t1, $t0, 3900 # S
	sw $t2, 0($t1)
	addi $t1, $t0, 3904
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3936 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 3940
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3952 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 3956
	sw $t2, 0($t1)
	addi $t1, $t0, 3960
	sw $t2, 0($t1)
	addi $t1, $t0, 3964
	sw $t2, 0($t1)
	addi $t1, $t0, 3968
	sw $t2, 0($t1)
	addi $t1, $t0, 3972
	sw $t2, 0($t1)
	
	addi $t1, $t0, 3980 # R
	sw $t2, 0($t1)
	addi $t1, $t0, 3984
	sw $t2, 0($t1)
	addi $t1, $t0, 3996
	sw $t2, 0($t1)
	addi $t1, $t0, 4000
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4016 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 4020
	sw $t2, 0($t1)
	# fourth line
	addi $t1, $t0, 4156 # S
	sw $t2, 0($t1)
	addi $t1, $t0, 4160
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4192 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 4196
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4208 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 4212
	sw $t2, 0($t1)
	addi $t1, $t0, 4224
	sw $t2, 0($t1)
	addi $t1, $t0, 4228
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4236 # R
	sw $t2, 0($t1)
	addi $t1, $t0, 4240
	sw $t2, 0($t1)
	addi $t1, $t0, 4252
	sw $t2, 0($t1)
	addi $t1, $t0, 4256
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4272 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 4276
	sw $t2, 0($t1)
	 
	# fifth line
	addi $t1, $t0, 4416 # S
	sw $t2, 0($t1)
	addi $t1, $t0, 4420
	sw $t2, 0($t1)
	addi $t1, $t0, 4424
	sw $t2, 0($t1)
	addi $t1, $t0, 4428
	sw $t2, 0($t1)
	addi $t1, $t0, 4432
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4448 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 4452
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4464 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 4468
	sw $t2, 0($t1)
	addi $t1, $t0, 4480
	sw $t2, 0($t1)
	addi $t1, $t0, 4484
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4492 # R
	sw $t2, 0($t1)
	addi $t1, $t0, 4496
	sw $t2, 0($t1)
	addi $t1, $t0, 4500
	sw $t2, 0($t1)
	addi $t1, $t0, 4504
	sw $t2, 0($t1)
	addi $t1, $t0, 4508
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4528 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 4532
	sw $t2, 0($t1)
	 
	# sixth line 
	addi $t1, $t0, 4688 # S
	sw $t2, 0($t1)
	addi $t1, $t0, 4692
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4704 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 4708
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4720 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 4724
	sw $t2, 0($t1)
	addi $t1, $t0, 4728
	sw $t2, 0($t1)
	addi $t1, $t0, 4732
	sw $t2, 0($t1)
	addi $t1, $t0, 4736
	sw $t2, 0($t1)
	addi $t1, $t0, 4740
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4748 # R
	sw $t2, 0($t1)
	addi $t1, $t0, 4752
	sw $t2, 0($t1)
	addi $t1, $t0, 4756
	sw $t2, 0($t1)
	addi $t1, $t0, 4760
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4784 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 4788
	sw $t2, 0($t1)
	
	# seventh line
	addi $t1, $t0, 4944 # S
	sw $t2, 0($t1)
	addi $t1, $t0, 4948
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4960 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 4964
	sw $t2, 0($t1)
	
	addi $t1, $t0, 4976 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 4980
	sw $t2, 0($t1)
	addi $t1, $t0, 4984
	sw $t2, 0($t1)
	addi $t1, $t0, 4988
	sw $t2, 0($t1)
	addi $t1, $t0, 4992
	sw $t2, 0($t1)
	addi $t1, $t0, 4996
	sw $t2, 0($t1)
	
	addi $t1, $t0, 5004 # R
	sw $t2, 0($t1)
	addi $t1, $t0, 5008
	sw $t2, 0($t1)
	addi $t1, $t0, 5012
	sw $t2, 0($t1)
	addi $t1, $t0, 5016
	sw $t2, 0($t1)
	addi $t1, $t0, 5020
	sw $t2, 0($t1)
	
	addi $t1, $t0, 5040 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 5044
	sw $t2, 0($t1)
	
	# eighth line
	addi $t1, $t0, 5184 # S
	sw $t2, 0($t1)
	addi $t1, $t0, 5188
	sw $t2, 0($t1)
	addi $t1, $t0, 5192
	sw $t2, 0($t1)
	addi $t1, $t0, 5196
	sw $t2, 0($t1)
	addi $t1, $t0, 5200
	sw $t2, 0($t1)
	addi $t1, $t0, 5204
	sw $t2, 0($t1)
	
	addi $t1, $t0, 5216 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 5220
	sw $t2, 0($t1)
	
	addi $t1, $t0, 5232 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 5236
	sw $t2, 0($t1)
	addi $t1, $t0, 5248
	sw $t2, 0($t1)
	addi $t1, $t0, 5252
	sw $t2, 0($t1)
	
	addi $t1, $t0, 5260 # R
	sw $t2, 0($t1)
	addi $t1, $t0, 5264
	sw $t2, 0($t1)
	addi $t1, $t0, 5272
	sw $t2, 0($t1)
	addi $t1, $t0, 5276
	sw $t2, 0($t1)
	addi $t1, $t0, 5280
	sw $t2, 0($t1)
	
	addi $t1, $t0, 5296 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 5300
	sw $t2, 0($t1) 
	# ninth line
	addi $t1, $t0, 5440 # S
	sw $t2, 0($t1)
	addi $t1, $t0, 5444
	sw $t2, 0($t1)
	addi $t1, $t0, 5448
	sw $t2, 0($t1)
	addi $t1, $t0, 5452
	sw $t2, 0($t1)
	addi $t1, $t0, 5456
	sw $t2, 0($t1)
	
	addi $t1, $t0, 5472 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 5476
	sw $t2, 0($t1)
	
	addi $t1, $t0, 5488 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 5492
	sw $t2, 0($t1)
	addi $t1, $t0, 5504
	sw $t2, 0($t1)
	addi $t1, $t0, 5508
	sw $t2, 0($t1)
	
	addi $t1, $t0, 5516 # R
	sw $t2, 0($t1)
	addi $t1, $t0, 5520
	sw $t2, 0($t1)
	addi $t1, $t0, 5532
	sw $t2, 0($t1)
	addi $t1, $t0, 5536
	sw $t2, 0($t1)
	addi $t1, $t0, 5540
	sw $t2, 0($t1)
	
	addi $t1, $t0, 5552 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 5556
	sw $t2, 0($t1)
	# GAME
	addi $t1, $t0, 6464 # G
	sw $t2, 0($t1)
	addi $t1, $t0, 6468
	sw $t2, 0($t1)
	addi $t1, $t0, 6472
	sw $t2, 0($t1)
	addi $t1, $t0, 6476
	sw $t2, 0($t1)
	addi $t1, $t0, 6480
	sw $t2, 0($t1)
	
	addi $t1, $t0, 6500 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 6504
	sw $t2, 0($t1)
	
	addi $t1, $t0, 6524 # M
	sw $t2, 0($t1)
	addi $t1, $t0, 6528
	sw $t2, 0($t1)
	addi $t1, $t0, 6532
	sw $t2, 0($t1)
	addi $t1, $t0, 6536
	sw $t2, 0($t1)
	addi $t1, $t0, 6544
	sw $t2, 0($t1)
	addi $t1, $t0, 6548
	sw $t2, 0($t1)
	addi $t1, $t0, 6552
	sw $t2, 0($t1)
	addi $t1, $t0, 6556
	sw $t2, 0($t1)
	
	addi $t1, $t0, 6568 # E
	sw $t2, 0($t1)
	addi $t1, $t0, 6572
	sw $t2, 0($t1)
	addi $t1, $t0, 6576
	sw $t2, 0($t1)
	addi $t1, $t0, 6580
	sw $t2, 0($t1)
	addi $t1, $t0, 6584
	sw $t2, 0($t1)
	addi $t1, $t0, 6588
	sw $t2, 0($t1)
	syscall 
	# second line
	addi $t1, $t0, 6716 # G
	sw $t2, 0($t1)
	addi $t1, $t0, 6720
	sw $t2, 0($t1)
	addi $t1, $t0, 6724
	sw $t2, 0($t1)
	addi $t1, $t0, 6728
	sw $t2, 0($t1)
	addi $t1, $t0, 6732
	sw $t2, 0($t1)
	addi $t1, $t0, 6736
	sw $t2, 0($t1)
	
	addi $t1, $t0, 6752 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 6756
	sw $t2, 0($t1)
	addi $t1, $t0, 6760
	sw $t2, 0($t1)
	addi $t1, $t0, 6764
	sw $t2, 0($t1)
	
	addi $t1, $t0, 6776 # M
	sw $t2, 0($t1)
	addi $t1, $t0, 6780
	sw $t2, 0($t1)
	addi $t1, $t0, 6784
	sw $t2, 0($t1)
	addi $t1, $t0, 6788
	sw $t2, 0($t1)
	addi $t1, $t0, 6792
	sw $t2, 0($t1)
	addi $t1, $t0, 6796
	sw $t2, 0($t1)
	addi $t1, $t0, 6800
	sw $t2, 0($t1)
	addi $t1, $t0, 6804
	sw $t2, 0($t1)
	addi $t1, $t0, 6808
	sw $t2, 0($t1)
	addi $t1, $t0, 6812
	sw $t2, 0($t1)
	addi $t1, $t0, 6816
	sw $t2, 0($t1)
	
	addi $t1, $t0, 6824 # E
	sw $t2, 0($t1)
	addi $t1, $t0, 6828
	sw $t2, 0($t1)
	addi $t1, $t0, 6832
	sw $t2, 0($t1)
	addi $t1, $t0, 6836
	sw $t2, 0($t1)
	addi $t1, $t0, 6840
	sw $t2, 0($t1)
	addi $t1, $t0, 6844
	sw $t2, 0($t1)
	# third line
	addi $t1, $t0, 6972 # G
	sw $t2, 0($t1)
	addi $t1, $t0, 6976
	sw $t2, 0($t1)
	
	addi $t1, $t0, 7004 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 7008
	sw $t2, 0($t1)
	addi $t1, $t0, 7012
	sw $t2, 0($t1)
	addi $t1, $t0, 7016
	sw $t2, 0($t1)
	addi $t1, $t0, 7020
	sw $t2, 0($t1)
	addi $t1, $t0, 7024
	sw $t2, 0($t1)
	
	addi $t1, $t0, 7032 # M
	sw $t2, 0($t1)
	addi $t1, $t0, 7036
	sw $t2, 0($t1)
	addi $t1, $t0, 7048
	sw $t2, 0($t1)
	addi $t1, $t0, 7052
	sw $t2, 0($t1)
	addi $t1, $t0, 7056
	sw $t2, 0($t1)
	addi $t1, $t0, 7068
	sw $t2, 0($t1)
	addi $t1, $t0, 7072
	sw $t2, 0($t1)
	
	addi $t1, $t0, 7080 # E
	sw $t2, 0($t1)
	addi $t1, $t0, 7084
	sw $t2, 0($t1)
	syscall 
	# fourth line
	addi $t1, $t0, 7228 # G
	sw $t2, 0($t1)
	addi $t1, $t0, 7232
	sw $t2, 0($t1)
	
	addi $t1, $t0, 7260 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 7264
	sw $t2, 0($t1)
	addi $t1, $t0, 7276
	sw $t2, 0($t1)
	addi $t1, $t0, 7280
	sw $t2, 0($t1)
	
	addi $t1, $t0, 7288 # M
	sw $t2, 0($t1)
	addi $t1, $t0, 7292
	sw $t2, 0($t1)
	addi $t1, $t0, 7304
	sw $t2, 0($t1)
	addi $t1, $t0, 7308
	sw $t2, 0($t1)
	addi $t1, $t0, 7312
	sw $t2, 0($t1)
	addi $t1, $t0, 7324
	sw $t2, 0($t1)
	addi $t1, $t0, 7328
	sw $t2, 0($t1)
	
	addi $t1, $t0, 7336 # E
	sw $t2, 0($t1)
	addi $t1, $t0, 7340
	sw $t2, 0($t1) 
	# fifth line
	addi $t1, $t0, 7484 # G
	sw $t2, 0($t1)
	addi $t1, $t0, 7488
	sw $t2, 0($t1)
	addi $t1, $t0, 7496
	sw $t2, 0($t1)
	addi $t1, $t0, 7500
	sw $t2, 0($t1)
	addi $t1, $t0, 7504
	sw $t2, 0($t1)
	
	
	addi $t1, $t0, 7516 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 7520
	sw $t2, 0($t1)
	addi $t1, $t0, 7532
	sw $t2, 0($t1)
	addi $t1, $t0, 7536
	sw $t2, 0($t1)
	
	addi $t1, $t0, 7544 # M
	sw $t2, 0($t1)
	addi $t1, $t0, 7548
	sw $t2, 0($t1)
	addi $t1, $t0, 7560
	sw $t2, 0($t1)
	addi $t1, $t0, 7564
	sw $t2, 0($t1)
	addi $t1, $t0, 7568
	sw $t2, 0($t1)
	addi $t1, $t0, 7580
	sw $t2, 0($t1)
	addi $t1, $t0, 7584
	sw $t2, 0($t1)
	
	addi $t1, $t0, 7592 # E
	sw $t2, 0($t1)
	addi $t1, $t0, 7596
	sw $t2, 0($t1)
	addi $t1, $t0, 7600
	sw $t2, 0($t1)
	addi $t1, $t0, 7604
	sw $t2, 0($t1)
	addi $t1, $t0, 7608
	sw $t2, 0($t1)
	addi $t1, $t0, 7612
	sw $t2, 0($t1) 
	# sixth line
	addi $t1, $t0, 7740 # G
	sw $t2, 0($t1)
	addi $t1, $t0, 7744
	sw $t2, 0($t1)
	addi $t1, $t0, 7760
	sw $t2, 0($t1)
	addi $t1, $t0, 7764
	sw $t2, 0($t1)
	
	
	addi $t1, $t0, 7772 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 7776
	sw $t2, 0($t1)
	addi $t1, $t0, 7780
	sw $t2, 0($t1)
	addi $t1, $t0, 7784
	sw $t2, 0($t1)
	addi $t1, $t0, 7788
	sw $t2, 0($t1)
	addi $t1, $t0, 7792
	sw $t2, 0($t1)
	
	addi $t1, $t0, 7800 # M
	sw $t2, 0($t1)
	addi $t1, $t0, 7804
	sw $t2, 0($t1)
	addi $t1, $t0, 7816
	sw $t2, 0($t1)
	addi $t1, $t0, 7820
	sw $t2, 0($t1)
	addi $t1, $t0, 7824
	sw $t2, 0($t1)
	addi $t1, $t0, 7836
	sw $t2, 0($t1)
	addi $t1, $t0, 7840
	sw $t2, 0($t1)
	
	addi $t1, $t0, 7848 # E
	sw $t2, 0($t1)
	addi $t1, $t0, 7852
	sw $t2, 0($t1)
	syscall 
	# seventh line
	addi $t1, $t0, 7996 # G
	sw $t2, 0($t1)
	addi $t1, $t0, 8000
	sw $t2, 0($t1)
	addi $t1, $t0, 8016
	sw $t2, 0($t1)
	addi $t1, $t0, 8020
	sw $t2, 0($t1)
	
	
	addi $t1, $t0, 8028 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 8032
	sw $t2, 0($t1)
	addi $t1, $t0, 8036
	sw $t2, 0($t1)
	addi $t1, $t0, 8040
	sw $t2, 0($t1)
	addi $t1, $t0, 8044
	sw $t2, 0($t1)
	addi $t1, $t0, 8048
	sw $t2, 0($t1)
	
	addi $t1, $t0, 8056 # M
	sw $t2, 0($t1)
	addi $t1, $t0, 8060
	sw $t2, 0($t1)
	addi $t1, $t0, 8072
	sw $t2, 0($t1)
	addi $t1, $t0, 8076
	sw $t2, 0($t1)
	addi $t1, $t0, 8080
	sw $t2, 0($t1)
	addi $t1, $t0, 8092
	sw $t2, 0($t1)
	addi $t1, $t0, 8096
	sw $t2, 0($t1)
	
	addi $t1, $t0, 8104 # E
	sw $t2, 0($t1)
	addi $t1, $t0, 8108
	sw $t2, 0($t1)
	syscall 
	# eighth line
	addi $t1, $t0, 8252 # G
	sw $t2, 0($t1)
	addi $t1, $t0, 8256
	sw $t2, 0($t1)
	addi $t1, $t0, 8260
	sw $t2, 0($t1)
	addi $t1, $t0, 8264
	sw $t2, 0($t1)
	addi $t1, $t0, 8268
	sw $t2, 0($t1)
	addi $t1, $t0, 8272
	sw $t2, 0($t1)
	addi $t1, $t0, 8276
	sw $t2, 0($t1)
	
	addi $t1, $t0, 8284 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 8288
	sw $t2, 0($t1)
	addi $t1, $t0, 8300
	sw $t2, 0($t1)
	addi $t1, $t0, 8304
	sw $t2, 0($t1)
	
	addi $t1, $t0, 8312 # M
	sw $t2, 0($t1)
	addi $t1, $t0, 8316
	sw $t2, 0($t1)
	addi $t1, $t0, 8328
	sw $t2, 0($t1)
	addi $t1, $t0, 8332
	sw $t2, 0($t1)
	addi $t1, $t0, 8336
	sw $t2, 0($t1)
	addi $t1, $t0, 8348
	sw $t2, 0($t1)
	addi $t1, $t0, 8352
	sw $t2, 0($t1)
	
	addi $t1, $t0, 8360 # E
	sw $t2, 0($t1)
	addi $t1, $t0, 8364
	sw $t2, 0($t1)
	addi $t1, $t0, 8368
	sw $t2, 0($t1)
	addi $t1, $t0, 8372
	sw $t2, 0($t1)
	addi $t1, $t0, 8376
	sw $t2, 0($t1)
	addi $t1, $t0, 8380
	sw $t2, 0($t1)
	syscall 
	# ninth line
	addi $t1, $t0, 8512 # G
	sw $t2, 0($t1)
	addi $t1, $t0, 8516
	sw $t2, 0($t1)
	addi $t1, $t0, 8520
	sw $t2, 0($t1)
	addi $t1, $t0, 8524
	sw $t2, 0($t1)
	addi $t1, $t0, 8528
	sw $t2, 0($t1)
	
	addi $t1, $t0, 8540 # A
	sw $t2, 0($t1)
	addi $t1, $t0, 8544
	sw $t2, 0($t1)
	addi $t1, $t0, 8556
	sw $t2, 0($t1)
	addi $t1, $t0, 8560
	sw $t2, 0($t1)
	
	addi $t1, $t0, 8568 # M
	sw $t2, 0($t1)
	addi $t1, $t0, 8572
	sw $t2, 0($t1)
	addi $t1, $t0, 8584
	sw $t2, 0($t1)
	addi $t1, $t0, 8588
	sw $t2, 0($t1)
	addi $t1, $t0, 8592
	sw $t2, 0($t1)
	addi $t1, $t0, 8604
	sw $t2, 0($t1)
	addi $t1, $t0, 8608
	sw $t2, 0($t1)
	
	addi $t1, $t0, 8616 # E
	sw $t2, 0($t1)
	addi $t1, $t0, 8620
	sw $t2, 0($t1)
	addi $t1, $t0, 8624
	sw $t2, 0($t1)
	addi $t1, $t0, 8628
	sw $t2, 0($t1)
	addi $t1, $t0, 8632
	sw $t2, 0($t1)
	addi $t1, $t0, 8636
	sw $t2, 0($t1)
	
	addi $t1, $t0, 8616 # E
	sw $t2, 0($t1)
	addi $t1, $t0, 8620
	sw $t2, 0($t1)
	addi $t1, $t0, 8624
	sw $t2, 0($t1)
	addi $t1, $t0, 8628
	sw $t2, 0($t1)
	addi $t1, $t0, 8632
	sw $t2, 0($t1)
	addi $t1, $t0, 8636
	sw $t2, 0($t1)
	
	# quit
	addi $t1, $t0, 12896 # Q
	sw $t2, 0($t1)
	addi $t1, $t0, 12900
	sw $t2, 0($t1)
	addi $t1, $t0, 12904 
	sw $t2, 0($t1)
	addi $t1, $t0, 12908 
	sw $t2, 0($t1)
	addi $t1, $t0, 13152
	sw $t2, 0($t1)
	addi $t1, $t0, 13408
	sw $t2, 0($t1)
	addi $t1, $t0, 13664
	sw $t2, 0($t1)
	addi $t1, $t0, 13920
	sw $t2, 0($t1)
	addi $t1, $t0, 13924
	sw $t2, 0($t1)
	addi $t1, $t0, 13928
	sw $t2, 0($t1)
	addi $t1, $t0, 13932
	sw $t2, 0($t1)
	addi $t1, $t0, 13936
	sw $t2, 0($t1)
	addi $t1, $t0, 13676
	sw $t2, 0($t1)
	addi $t1, $t0, 13420
	sw $t2, 0($t1)
	addi $t1, $t0, 13164
	sw $t2, 0($t1)
	addi $t1, $t0, 12908
	sw $t2, 0($t1)
	
	addi $t1, $t0, 12920 # U
	sw $t2, 0($t1)
	addi $t1, $t0, 13176
	sw $t2, 0($t1)
	addi $t1, $t0, 13432
	sw $t2, 0($t1)
	addi $t1, $t0, 13688
	sw $t2, 0($t1)
	addi $t1, $t0, 13944
	sw $t2, 0($t1)
	addi $t1, $t0, 13948
	sw $t2, 0($t1)
	addi $t1, $t0, 13952
	sw $t2, 0($t1)
	addi $t1, $t0, 13956
	sw $t2, 0($t1)
	addi $t1, $t0, 13700
	sw $t2, 0($t1)
	addi $t1, $t0, 13444
	sw $t2, 0($t1)
	addi $t1, $t0, 13188
	sw $t2, 0($t1)
	addi $t1, $t0, 12932
	sw $t2, 0($t1)
	
	addi $t1, $t0, 12940 # I
	sw $t2, 0($t1)
	addi $t1, $t0, 13196
	sw $t2, 0($t1)
	addi $t1, $t0, 13452
	sw $t2, 0($t1)
	addi $t1, $t0, 13708
	sw $t2, 0($t1)
	addi $t1, $t0, 13964
	sw $t2, 0($t1)
	
	addi $t1, $t0, 12948 # T
	sw $t2, 0($t1)
	addi $t1, $t0, 12952
	sw $t2, 0($t1)
	addi $t1, $t0, 12956
	sw $t2, 0($t1)
	addi $t1, $t0, 13208
	sw $t2, 0($t1)
	addi $t1, $t0, 13464
	sw $t2, 0($t1)
	addi $t1, $t0, 13720
	sw $t2, 0($t1)
	addi $t1, $t0, 13976
	sw $t2, 0($t1)

	
choose_start:
	li $v0, 32
	li $a0, 30
	syscall 
	li $t2, ORANGE
	addi $t1, $t0, 14688
	sw $t2, 0($t1)
	addi $t1, $t0, 14696
	sw $t2, 0($t1)
	addi $t1, $t0, 14704
	sw $t2, 0($t1)
	addi $t1, $t0, 14712
	sw $t2, 0($t1)
	addi $t1, $t0, 14720
	sw $t2, 0($t1)
	addi $t1, $t0, 14728
	sw $t2, 0($t1)
	addi $t1, $t0, 14736
	sw $t2, 0($t1)
	addi $t1, $t0, 14744
	sw $t2, 0($t1)
	addi $t1, $t0, 14752
	sw $t2, 0($t1)
	addi $t1, $t0, 14760
	sw $t2, 0($t1)
	addi $t1, $t0, 14764
	sw $t2, 0($t1)
	addi $t1, $t0, 14768
	sw $t2, 0($t1)
	addi $t1, $t0, 14508
	sw $t2, 0($t1)
	addi $t1, $t0, 14512
	sw $t2, 0($t1)
	addi $t1, $t0, 15020
	sw $t2, 0($t1)
	addi $t1, $t0, 15024
	sw $t2, 0($t1)
	syscall 
	li $t2, WHITE
	addi $t1, $t0, 9272 
	sw $t2, 0($t1)
	addi $t1, $t0, 9280 
	sw $t2, 0($t1)
	addi $t1, $t0, 9288
	sw $t2, 0($t1)
	addi $t1, $t0, 9296
	sw $t2, 0($t1)
	addi $t1, $t0, 9304
	sw $t2, 0($t1)
	addi $t1, $t0, 9312
	sw $t2, 0($t1)
	addi $t1, $t0, 9320
	sw $t2, 0($t1)
	addi $t1, $t0, 9328 
	sw $t2, 0($t1)
	addi $t1, $t0, 9336
	sw $t2, 0($t1)
	addi $t1, $t0, 9344
	sw $t2, 0($t1)
	addi $t1, $t0, 9352
	sw $t2, 0($t1)
	addi $t1, $t0, 9360
	sw $t2, 0($t1)
	addi $t1, $t0, 9368
	sw $t2, 0($t1)
	addi $t1, $t0, 9376
	sw $t2, 0($t1)
	addi $t1, $t0, 9384
	sw $t2, 0($t1)
	addi $t1, $t0, 9392
	sw $t2, 0($t1)
	addi $t1, $t0, 9400
	sw $t2, 0($t1)
	addi $t1, $t0, 9408
	sw $t2, 0($t1)
	addi $t1, $t0, 9416
	sw $t2, 0($t1)
	addi $t1, $t0, 9420
	sw $t2, 0($t1)
	addi $t1, $t0, 9164
	sw $t2, 0($t1)
	addi $t1, $t0, 9676
	sw $t2, 0($t1)
	addi $t1, $t0, 9168
	sw $t2, 0($t1)
	addi $t1, $t0, 9424
	sw $t2, 0($t1)
	addi $t1, $t0, 9680
	sw $t2, 0($t1)
	syscall 
		
	li $t9, 0xffff0000			
	lw $t8, 0($t9)
	beq $t8, 1, s_KeyPressed
	s_Loop_Sleep:
		li $v0, 32		
		li $a0, REFRESH_RATE
		syscall
		j choose_start
	s_KeyPressed:		
		lw $t4, 4($t9)
		beq $t4, KEY_S, choose_quit
		beq $t4, SPACE, R_PRESSED
		j choose_start
	
choose_quit:
	li $v0, 32
	li $a0, 30
	li $t2, ORANGE
	addi $t1, $t0, 9272
	sw $t2, 0($t1)
	addi $t1, $t0, 9280 
	sw $t2, 0($t1)
	addi $t1, $t0, 9288
	sw $t2, 0($t1)
	addi $t1, $t0, 9296
	sw $t2, 0($t1)
	addi $t1, $t0, 9304
	sw $t2, 0($t1)
	addi $t1, $t0, 9312
	sw $t2, 0($t1)
	addi $t1, $t0, 9320
	sw $t2, 0($t1)
	addi $t1, $t0, 9328 
	sw $t2, 0($t1)
	addi $t1, $t0, 9336
	sw $t2, 0($t1)
	addi $t1, $t0, 9344
	sw $t2, 0($t1)
	addi $t1, $t0, 9352
	sw $t2, 0($t1)
	addi $t1, $t0, 9360
	sw $t2, 0($t1)
	addi $t1, $t0, 9368
	sw $t2, 0($t1)
	addi $t1, $t0, 9376
	sw $t2, 0($t1)
	addi $t1, $t0, 9384
	sw $t2, 0($t1)
	addi $t1, $t0, 9392
	sw $t2, 0($t1)
	addi $t1, $t0, 9400
	sw $t2, 0($t1)
	addi $t1, $t0, 9408
	sw $t2, 0($t1)
	addi $t1, $t0, 9416
	sw $t2, 0($t1)
	addi $t1, $t0, 9420
	sw $t2, 0($t1)
	addi $t1, $t0, 9164
	sw $t2, 0($t1)
	addi $t1, $t0, 9676
	sw $t2, 0($t1)
	addi $t1, $t0, 9168
	sw $t2, 0($t1)
	addi $t1, $t0, 9424
	sw $t2, 0($t1)
	addi $t1, $t0, 9680
	sw $t2, 0($t1)
	syscall 
	li $t2, WHITE
	addi $t1, $t0, 14688
	sw $t2, 0($t1)
	addi $t1, $t0, 14696
	sw $t2, 0($t1)
	addi $t1, $t0, 14704
	sw $t2, 0($t1)
	addi $t1, $t0, 14712
	sw $t2, 0($t1)
	addi $t1, $t0, 14720
	sw $t2, 0($t1)
	addi $t1, $t0, 14728
	sw $t2, 0($t1)
	addi $t1, $t0, 14736
	sw $t2, 0($t1)
	addi $t1, $t0, 14744
	sw $t2, 0($t1)
	addi $t1, $t0, 14752
	sw $t2, 0($t1)
	addi $t1, $t0, 14760
	sw $t2, 0($t1)
	addi $t1, $t0, 14764
	sw $t2, 0($t1)
	addi $t1, $t0, 14768
	sw $t2, 0($t1)
	addi $t1, $t0, 14508
	sw $t2, 0($t1)
	addi $t1, $t0, 14512
	sw $t2, 0($t1)
	addi $t1, $t0, 15020
	sw $t2, 0($t1)
	addi $t1, $t0, 15024
	sw $t2, 0($t1)
	
	li $t9, 0xffff0000			
	lw $t8, 0($t9)
	beq $t8, 1, w_KeyPressed
	w_Loop_Sleep:
		li $v0, 32		
		li $a0, REFRESH_RATE
		syscall
		j choose_quit
	w_KeyPressed:		
		lw $t4, 4($t9)
		beq $t4, KEY_W, choose_start
		beq $t4, SPACE, EXIT
		j choose_quit
	
EXIT:
	li $v0, 10
	syscall 
	
	
MAIN_PROCESS:
	beq $s0, 1, HAS_WON
	beq $s0, 2, HAS_LOST
	
	jal GRAVITY
		
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	bne $t8, 1, COLLISION
	
	lw $t0, 4($t9)
	beq $t0, KEY_D, D_PRESSED				
	beq $t0, KEY_R, R_PRESSED
	beq $t0, KEY_Q, Q_PRESSED
	beq $t0, KEY_W, W_PRESSED
	beq $t0, KEY_A, A_PRESSED
	beq $t0, KEY_S, S_PRESSED
	j COLLISION
	W_PRESSED:
		jal UP
		j COLLISION
	D_PRESSED:
		jal RIGHT
		j COLLISION
	S_PRESSED:
		jal DOWN
		j COLLISION
	A_PRESSED:
		jal LEFT
		j COLLISION
	R_PRESSED:
		jal RESET
		j SLEEP	
	Q_PRESSED:
		j EXIT 
	COLLISION:	
		jal BOUNDARY
		jal ITEMS_MOVE
		jal OBJECT_COLLISION
		jal PLATFORM_COLLISION
		jal ENEMY_COLLISION
		jal FALLING
		
		j DRAW
	DRAW: 
		jal DRAW_BACKGROUND
		jal DRAW_LIVE
		jal DRAW_PLATFORMS
		jal DRAW_PLAYER
		jal DRAW_PICKUPS
		jal DRAW_ENEMY
		
		j WIN_FAIL
	WIN_FAIL:
		jal WIN_OR_FAIL
		j SLEEP
	HAS_WON:
		jal WIN_LABLE
		j READ_KEY
	HAS_LOST:
		jal LOSE
		j READ_KEY
	READ_KEY:
		li $t9, 0xffff0000
		lw $t8, 0($t9)
		bne $t8, 1, SLEEP
		lw $t0, 4($t9)				
		beq $t0, KEY_R, R_PRESSED
		beq $t0, KEY_Q, Q_PRESSED
		j SLEEP
	SLEEP:
		li $v0, 32
		li $a0, REFRESH_RATE 
		syscall
		j MAIN_PROCESS
UP:
	beq $s3, 0, CANT
	li $s4, JUMP
	li $s3, 0
	jr $ra
	CANT:		
		beq $s6, 2, NO
		beq $s6, 0, NO
		sub $s4, $s4, 4
	
		blt $s4, JUMP, ON
		j NOTON
	ON:
		li $s4, JUMP
	NOTON:
		li $s3, 0
		beq $s7, 1, NO
		li $s6, 2
	NO:
		jr $ra

LEFT:
	addi $s1, $s1, -2
	jr $ra
	
DOWN:
	addi $s2, $s2, 1
	jr $ra
	
RIGHT:
	addi $s1, $s1, 2
	jr $ra

GRAVITY:
	beq $s4, FALL, REACHED
	addi $s4, $s4, GRAVITY_data
	REACHED:
		jr $ra
	
BOUNDARY:
	li $t1, BACKGROUND_WIDTH
	sub $t1, $t1, PLAYER_WIDTH
	bgt $s1, $t1, R_B # right bound
	blt $s1, 0, L_B # left bound
	j FINISH
	R_B:
		move $s1, $t1
		j FINISH
	L_B:
		li $s1, 0
		j FINISH
	FINISH:
		jr $ra

ENEMY_COLLISION:
	move $a0, $ra
	CHECK_ENEMY:
		la $t0, ENEMY 
		lw $t1, 8($t0)
		lw $a1, 0($t0)
		lw $a2, 4($t0)
		jal CHECK_SINGLE_ENEMY
		beq, $v1, 0, CHECK_ENEMY_2	
	CHECK_ENEMY_2:
		la $t0, ENEMY_2
		lw $t1, 8($t0)
		lw $a1, 0($t0)
		lw $a2, 4($t0)
		jal CHECK_SINGLE_ENEMY
		beq, $v1, 0, DONE_ENEMY
	DONE_ENEMY:
		move $ra, $a0
		jr $ra	

CHECK_SINGLE_ENEMY: 
	move $t0, $a1
	addi $t0, $t0, 5
	addi $a1, $a1, -1
	
	move $t1, $a2
	addi $t1, $t1, 5
	addi $a2, $a2, -1
	
	move $t2, $s1 
	addi $t3, $t2, 1 
	move $t4, $s2 
	addi $t4, $t4, 2 
	bgt $t3, $t0, NO_ENEMY_COLLISION
	blt $t3, $a1, NO_ENEMY_COLLISION
	blt $t4, $a2, NO_ENEMY_COLLISION
	bgt $t4, $t1, NO_ENEMY_COLLISION
	COLLISION_ENEMY:
		subi $s5, $s5, 1
		li $v1, 1
		jr $ra
	NO_ENEMY_COLLISION:
		li $v1, 0
		jr $ra
DO_SLEEP:
	li $v0, 32
	la $a0, 20
	syscall 
	jr $ra
	
OBJECT_COLLISION:
	move $a0, $ra
	CHECK_PICKUP_TIME:
		la $t0, PICKUP_TIME 
		lw $t1, 8($t0)
		beq $t1, 1, CHECK_PICKUP_JUMP
		lw $a1, 0($t0)
		lw $a2, 4($t0)
		jal CHECK_SINGLE_COLLISION
	
		beq, $v1, 0, CHECK_PICKUP_JUMP
		addi $s5, $s5, 1
		la $t0, PICKUP_TIME
		li $t1, 1
		sw $t1, 8($t0)
	CHECK_PICKUP_JUMP:
		la $t0, PICKUP_JUMP
		lw $t1, 8($t0)
		beq $t1, 1, CHECK_PICKUP_FLY
		lw $a1, 0($t0)
		lw $a2, 4($t0)
		jal CHECK_SINGLE_COLLISION
	
		beq, $v1, 0, CHECK_PICKUP_FLY
		li $s6, 1
		la $t0, PICKUP_JUMP
		li $t1, 1
		sw $t1, 8($t0)
	CHECK_PICKUP_FLY:
		la $t0, PICKUP_FLY
		lw $t1, 8($t0)
		beq $t1, 1, DONE_OBJECTS
		lw $a1, 0($t0)
		lw $a2, 4($t0)
		jal CHECK_SINGLE_COLLISION
	
		beq, $v1, 0, DONE_OBJECTS
		li $s7, 1
		li $s6, 1
		la $t0, PICKUP_FLY
		li $t1, 1
		sw $t1, 8($t0)
	DONE_OBJECTS:
		move $ra, $a0
		jr $ra
	
CHECK_SINGLE_COLLISION: 
	move $t0, $a1
	addi $t0, $t0, 2 
	addi $a1, $a1, -1
	
	move $t1, $a2
	addi $t1, $t1, 2 
	addi $a2, $a2, -1
	
	move $t2, $s1 
	addi $t3, $t2, 1 
	move $t4, $s2 
	addi $t4, $t4, 2 
	bgt $t3, $t0, NO_PICKUP_COLLISION
	blt $t3, $a1, NO_PICKUP_COLLISION
	blt $t4, $a2, NO_PICKUP_COLLISION
	bgt $t4, $t1, NO_PICKUP_COLLISION
	PICKUP_COLLISION:
		li $v1, 1
		jr $ra
	NO_PICKUP_COLLISION:
		li $v1, 0
		jr $ra
		
ITEMS_MOVE:
	move $a0, $ra
	la $a1, PICKUP_FLY
	jal MOVE_OBJ
	la $a1, PLATFORM_3
	jal MOVE_OBJ
	la $a1, ENEMY
	jal MOVE_OBJ
	la $a1, ENEMY_2
	jal MOVE_OBJ
	move $ra, $a0
	jr $ra
	
MOVE_OBJ:
	lw $t0, 0($a1) 
	lw $t1, 12($a1) 
	lw $t2, 16($a1) 
	lw $t3, 20($a1)
	
	ble $t0, $t1, MOVE
	bge $t0, $t2, MOVE
	j MOVE_DIR
	MOVE:
		li $t4, -1
		mul $t3, $t3, $t4
		sw $t3, 20($a1)
	MOVE_DIR:
		add $t0, $t0, $t3
		sw $t0, 0($a1)
	jr $ra

PLATFORM_COLLISION:
	move $a0, $ra
	blt $s4, 0, DONE_COLLISION
	
	la $t0, PLATFORM_1
	lw $a1, 0($t0)
	lw $a2, 4($t0)
	lw $a3, 8($t0)
	jal CHECK_SINGLE
	beq $v0, 1, DONE_COLLISION
	
	la $t0, PLATFORM_2
	lw $a1, 0($t0)
	lw $a2, 4($t0)
	lw $a3, 8($t0)
	jal CHECK_SINGLE
	beq $v0, 1, DONE_COLLISION
	
	la $t0, PLATFORM_3
	lw $a1, 0($t0)
	lw $a2, 4($t0)
	lw $a3, 8($t0)
	jal CHECK_SINGLE
	beq $v0, 1, DONE_COLLISION

	DONE_COLLISION:
		move $ra, $a0
		jr $ra


CHECK_SINGLE: 
	move $t0, $s1
	addi $t0, $t0, 1
	move $t1, $s2
	addi $t1, $t1, PLAYER_HEIGHT
	bne $t1, $a2, NO_STAND
	blt $t0, $a1, NO_STAND
	add $t2, $a1, $a3
	bgt $t0, $t2, NO_STAND
	li $s4, 0
	li $s3, 1
	beq $s6, 0, COLLISION_NO_FLY
	li $s6, 1
	COLLISION_NO_FLY:
		li $v0, 1
		jr $ra
	NO_STAND:
		li $s3, 0
		li $v0, 0
		jr $ra
	
FALLING:
	move $t0, $s4
	add $s2, $s2, $t0
	jr $ra
	
DRAW_BACKGROUND: 
	li $t0, BASE_ADDRESS
	add $t0, $t0, 2560
	li $t1, BACKGROUND_WIDTH
	li $t2, ORANGE
	mul $t1, $t1, $t1
	mul $t1, $t1, 4
	add $t1, $t0, $t1
	CLEAR:
		bgt $t0, $t1, DONE_CLEAR
		sw $t2, 0($t0)
		addi $t0, $t0, 4
		j CLEAR
	DONE_CLEAR:
		jr $ra

DRAW_PLATFORMS:
	move $a0, $ra
	la $t0, PLATFORM_1
	lw $a1, 0($t0)
	lw $a2, 4($t0)
	lw $a3, 8($t0)
	jal DRAW_P
	
	la $t0, PLATFORM_2
	lw $a1, 0($t0)
	lw $a2, 4($t0)
	lw $a3, 8($t0)
	jal DRAW_P
	
	la $t0, PLATFORM_3
	lw $a1, 0($t0)
	lw $a2, 4($t0)
	lw $a3, 8($t0)
	jal DRAW_P
	
	move $ra, $a0
	jr $ra

DRAW_P:
	li $t0, BACKGROUND_WIDTH
	
	mul $t0, $t0, $a2
	add $t0, $t0, $a1
	mul $t0, $t0, 4
	addi $t0, $t0, BASE_ADDRESS
	
	move $t1, $a3
	mul $t1, $t1, 4
	add $t1, $t0, $t1
	li $t2, BROWN
	li $t3, GREEN
	DRAW_LOOP:
		bgt $t0, $t1, END_DRAW_LOOP
		sw $t3, 0($t0)
		sw $t2, 256($t0)
		addi $t0, $t0, 4
		j DRAW_LOOP
	
	END_DRAW_LOOP:
		jr $ra
		
DRAW_PLAYER: 
	move $t1, $s1
	move $t2, $s2
	li $t3, WHITE
	li $t7, BLUE
	li $t8, BLACK
	bne $s6, 1, FLY
	li $t8, PURPLE
	FLY:
		beqz $s7, BODY
		li $t7, RED
	
	BODY:
		li $t4, BASE_ADDRESS
		li $t5, BACKGROUND_WIDTH
		li $t6, 4
	
		mul $t5, $t5, $t2 				
		add $t5, $t5, $t1	
		mul $t5, $t5, $t6	
		add $t5, $t5, $t4	
	
		sw $t3, 0($t5)		
		sw $t3, 4($t5)
		sw $t3, 8($t5)
		sw $t3, 12($t5)
		sw $t3, 16($t5)
	
		addi $t5, $t5, 256
		sw $t3, 0($t5)
		sw $t3, 4($t5)
		sw $t3, 8($t5)
		sw $t3, 12($t5)
		sw $t3, 16($t5)
	
		addi $t5, $t5, 256
		sw $t3, 0($t5)
		sw $t8, 4($t5)
		sw $t3, 8($t5)
		sw $t8, 12($t5)
		sw $t3, 16($t5)
	
		addi $t5, $t5, 256
		sw $t3, 0($t5)
		sw $t8, 4($t5)
		sw $t3, 8($t5)
		sw $t8, 12($t5)
		sw $t3, 16($t5)
	
		addi $t5, $t5, 256
		sw $t3, 0($t5)
		sw $t3, 4($t5)
		sw $t3, 8($t5)
		sw $t3, 12($t5)
		sw $t3, 16($t5)
	
		addi $t5, $t5, 256
		sw $t7, 4($t5)
		sw $t7, 8($t5)
		sw $t7, 12($t5)
	
		addi $t5, $t5, 256
		sw $t7, 4($t5)
		sw $t7, 8($t5)
		sw $t7, 12($t5)
	
		addi $t5, $t5, 256
		sw $t3, 4($t5)
		sw $t3, 8($t5)
		sw $t3, 12($t5)
	
		jr $ra	
	
DRAW_PICKUPS:
	move $a0, $ra
	DRAW_PICKUP_TIME:
		la $t0, PICKUP_TIME
		lw $t1, 8($t0)
		beq $t1, 1, DRAW_PICKUP_JUMP
		lw $a1, 0($t0)
		lw $a2, 4($t0)
		li $a3, RED
		jal DRAW_SINGLE_PICKUP
	DRAW_PICKUP_JUMP:
		la $t0, PICKUP_JUMP
		lw $t1, 8($t0)
		beq $t1, 1, DRAW_PICKUP_FLY
		lw $a1, 0($t0)
		lw $a2, 4($t0)
		li $a3, BLUE
		jal DRAW_SINGLE_PICKUP
	DRAW_PICKUP_FLY:
		la $t0, PICKUP_FLY
		lw $t1, 8($t0)
		beq $t1, 1, DONE_DRAW
		lw $a1, 0($t0)
		lw $a2, 4($t0)
		li $a3, GREEN
		jal DRAW_SINGLE_PICKUP
	DONE_DRAW:
		move $ra, $a0
		jr $ra
	
DRAW_SINGLE_PICKUP: 
	li $t0, BACKGROUND_WIDTH
	
	mul $t0, $t0, $a2
	add $t0, $t0, $a1
	mul $t0, $t0, 4
	addi $t0, $t0, BASE_ADDRESS
	
	sw $a3 4($t0)
	sw $a3 256($t0)
	sw $a3 260($t0)
	sw $a3 264($t0)
	sw $a3 516($t0)
	jr $ra


DRAW_LIVE: 
	li $t0, BACKGROUND_WIDTH
	li $t1, BASE_ADDRESS 
	mul $t2, $t0, 4					
	mul $t4, $t2, 4			
	addi $t4, $t4, BASE_ADDRESS
	addi $t4, $t4, 12
	li $t3, 0
	li $t7, 0
	li $t5, RED
	li $t6, BLACK
	LOOP_BLACK:
		beq $t7, 2556, LOOP_LIVE
		sw $t6, 0($t1)
		addi $t1, $t1, 4
		addi $t7, $t7, 4
		j LOOP_BLACK
	LOOP_LIVE:
		bge $t3, $s5, FINISH_LIVE	
		subi $t4, $t4, 512
		subi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 8
		sw $t5, 0($t4)
		addi $t4, $t4, 256
		subi $t4, $t4, 12
		sw $t5, 0($t4)
		addi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 256
		subi $t4, $t4, 16
		sw $t5, 0($t4)
		addi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 256
		subi $t4, $t4, 12
		sw $t5, 0($t4)
		addi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 4
		sw $t5, 0($t4)
		addi $t4, $t4, 256
		subi $t4, $t4, 4
		sw $t5, 0($t4)
		
		subi $t4, $t4, 512
		addi $t4, $t4, 24
		addi $t3, $t3, 1
		j LOOP_LIVE
	FINISH_LIVE:
		jr $ra
		
DRAW_ENEMY:
	move $a0, $ra
	la $t0, ENEMY
	lw $a1, 0($t0)
	lw $a2, 4($t0)
	jal DRAW_SINGLE_ENEMY
	
	la $t0, ENEMY_2
	lw $a1, 0($t0)
	lw $a2, 4($t0)
	jal DRAW_SINGLE_ENEMY
	
	move $ra, $a0
	jr $ra
DRAW_SINGLE_ENEMY:	
	li $t0, BACKGROUND_WIDTH
	
	mul $t0, $a2, 256
	mul $a1, $a1, 4
	add $t0, $t0, $a1
	addi $t0, $t0, BASE_ADDRESS
	li $t4, PURPLE
	li $t5, RED
	
	sw $t4, 12($t0)
	addi $t0, $t0, 256
	sw $t4, 4($t0)
	sw $t4, 12($t0)
	sw $t4, 20($t0)
	addi $t0, $t0, 256
	sw $t4, 0($t0)
	sw $t4, 4($t0)
	sw $t5, 8($t0)
	sw $t4, 12($t0)
	sw $t5, 16($t0)
	sw $t4, 20($t0)
	sw $t4, 24($t0)
	addi $t0, $t0, 256
	sw $t4, 0($t0)
	sw $t4, 4($t0)
	sw $t5, 8($t0)
	sw $t4, 12($t0)
	sw $t5, 16($t0)
	sw $t4, 20($t0)
	sw $t4, 24($t0)
	addi $t0, $t0, 256
	sw $t4, 4($t0)
	sw $t4, 8($t0)
	sw $t4, 12($t0)
	sw $t4, 16($t0)
	sw $t4, 20($t0)
	addi $t0, $t0, 256
	sw $t4, 8($t0)
	sw $t4, 16($t0)
	jr $ra
			
RESET:
	RESET_MOVING_PLATFORMS:
		la $t0, PLATFORM_3
		li $t1, P3_X
		sw $t1, 0($t0)
		li $t1, 1
		sw $t1, 20($t0)
	RESET_MOVING_ENEMY:
		la $t0, ENEMY
		li $t1, E_X
		sw $t1, 0($t0)
		li $t1, 0
		sw $t1, 8($t0)
		li $t1, 1
		sw $t1, 20($t0)
		
		la $t0, ENEMY_2
		li $t1, E2_X
		sw $t1, 0($t0)
		li $t1, 0
		sw $t1, 8($t0)
		li $t1, 1
		sw $t1, 20($t0)
	RESET_PICKUPS:
		la $t0, PICKUP_TIME
		li $t1, 0
		sw $t1, 8($t0)
	
		la $t0, PICKUP_JUMP
		li $t1, JUMP_X
		sw $t1, 0($t0)
		li $t1, 0
		sw $t1, 8($t0)
		li $t1, -1
		sw $t1, 20($t0)
	
		la $t0, PICKUP_FLY
		li $t1, 0
		sw $t1, 8($t0)
	RESET_PLAYER: 
		li $s1, PLAYER_START_X
		li $s2, PLAYER_START_Y
		li $s3, 0
		li $s4, 0
		li $s5, 2
		li $s6, 0
		li $s7, 0
	li $s0, 0
	jr $ra

WIN_OR_FAIL:
	blt $s2, 10, WIN
	bgt $s2, BACKGROUND_HEIGHT, FAIL
	beq $s5, $zero, FAIL
	li $s0, 0
	jr $ra	
	WIN:
		li $s0, 1
		jr $ra
	FAIL:
		li $s0, 2
		jr $ra

WIN_LABLE:
	move $a0, $ra
	li $t5, BLACK
	li $t8, BASE_ADDRESS
	li $t7, YELLOW
	jal DRAW_BACKGROUND
	add $t6, $t8, 6468
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	
	add $t6, $t8, 3444
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	
	add $t6, $t8, 10052
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	
	add $t6, $t8, 3700
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t8, 3732
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	
	add $t6, $t8, 6852
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	move $ra, $a0
	jr $ra
	
LOSE:
	move $a0, $ra
	li $t5, BLACK
	li $t8, BASE_ADDRESS
	li $t7, YELLOW
	jal DRAW_BACKGROUND
	add $t6, $t8, 6468
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	
	add $t6, $t8, 13172
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	
	add $t6, $t8, 10052
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	add $t6, $t6, 4
	sw $t7, 0($t6)
	
	add $t6, $t8, 6852
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	
	add $t6, $t8, 10100
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t8, 10132
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	add $t6, $t6, 256
	sw $t7, 0($t6)
	move $ra, $a0
	jr $ra
