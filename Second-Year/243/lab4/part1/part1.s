.equ LEDs, 0xFF200000
.equ KEY_BASE, 0xFF200050
.global _start
_start:
	movia r8, KEY_BASE
	movia r9, LEDs
	movi r10, 0 # outputs
	movi r14, 1
	movi r15, 15
	stwio r10, (r9) # initialize
poll:
	ldwio r11, (r8) # inputs
	andi r12, r11, 0x1 # get 0th bit
	bne r12, r0, K0
	andi r12, r11, 0x2 # get 1st bit
	bne r12, r0, K1
	andi r12, r11, 0x4 # get 2nd bit
	bne r12, r0, K2
	andi r12, r11, 0x8 # get 3rd bit
	bne r12, r0, K3
	br poll
K0:
	movi r10, 1
	br wait
K1:	
	beq r10, r0, K0 # change to one
	beq r10, r15, wait # boundary check
	addi r10, r10, 1
	br wait
K2: 
	beq r10, r0, K0 # change to one
	beq r10, r14, wait # boundary check
	subi r10, r10, 1
	br wait
K3:
	movi r10, 0
	br wait
wait:
	stwio r10, (r9) # output to LED
	ldwio r11, (r8)
	beq r11, r0, poll
	br wait