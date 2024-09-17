/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
	/* Put your code here */
main: movia r12, Answer
	movia r10, InputWord
	ldw r4, (r10) # load word
	call ONES # parameter r4, return r2
	stw r2, (r12) # store ans
	
endiloop: br endiloop

ONES: movi r2, 0 # stores no. of 1
	movi r15, 0x1 # constant 1
	
loop: andi r14, r4, 0x1 # rightmost bit is 1?
	beq r14, r15, Found # found 1
	
Back: srli r4, r4, 1 # shift right 1bit
	bne r4, r0, loop # not finished?
	ret 
	
Found: addi r2, r2, 1 # r2++
	br Back # back to loop

InputWord: .word 0x4a01fead

Answer: .word 0
	
	