/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:

	/* Put your code here */
	movia r12, Answer
	movia r10, InputWord
	ldw r7, (r10) # load word
	movi r5, 0x1
	movi r6, 0x0
	movi r11, 0 # stores no. of 1
	
Prop: andi r9, r7, 0x1 # rightmost bit is 1?
	beq r9, r5, One # found 1
	
Back: srli r7, r7, 1 # shift right 1bit
	bne r7, r0, Prop # not finished?
	stw r11, (r12) # store ans
	br endiloop
	
One: addi r11, r11, 1 # r11++
	br Back # back to loop

endiloop: br endiloop

InputWord: .word 0x4a01fead

Answer: .word 0
	
	