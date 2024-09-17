.text
/* Program to Count the number of 1's and Zeroes in a sequence of 32-bit words,
and determines the largest of each */
.equ LEDs, 0xFF200000
.global _start
_start:

	/* Your code here  */
	
main: movia r11, TEST_NUM
	movia r10, LargestOnes
	movia r9, LargestZeroes
	movia r15, 0xffffffff
	
Next: ldw r4, (r11)
	beq r4, r0, endiloop # is 0?
	call ONES # return ones in r2
	ldw r7, (r10) # load largest ones yet
	bge r2, r7, MoreOnes
	
Ctd1: ldw r4, (r11) # reset 00
	xor r4, r4, r15 # flip input
	call ONES # return zeroes in r2
	ldw r8, (r9) # load largest zeroes yet
	bge r2, r8, MoreZeroes
	
Ctd2: addi r11, r11, 4 # go to next item
	br Next
	
MoreOnes: stw r2, (r10) # store larger no. of ones
	br Ctd1
	
MoreZeroes: stw r2, (r9) # store larger no. of zeroes
	br Ctd2
	
endiloop: movia r25, LEDs
	ldw r7, (r10) # ones
	stwio r7, (r25) # ouputs ones
	call DELAY # wait
	ldw r8, (r9) # zeroes
	stwio r8, (r25) # ouputs zeroes
	call DELAY # wait
	br endiloop

/* SUBROUTINE  */
ONES: movi r2, 0 # stores no. of 1
	movi r5, 0x1 # constant 1
	
loop: andi r3, r4, 0x1 # rightmost bit is 1?
	beq r3, r5, One # found 1
	
Back: srli r4, r4, 1 # shift right 1bit
	bne r4, r0, loop # not finished?
	ret 
	
One: addi r2, r2, 1 # r2++
	br Back # back to loop

DELAY: movia r13, 0xece243 # boundary
	movia r14, 0 # loop index
dloop: addi r14, r14, 1 # i++
	ble r14, r13, dloop
	ret
	
.data
TEST_NUM:  .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            .word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0