.equ LEDs, 0xFF200000
.equ KEY_BASE, 0xFF200050
.equ KEY_EDGE, 0xFF20005C
.global _start
_start:
	movia r8, KEY_EDGE
	movia r9, LEDs
	movia r10, KEY_BASE
	movi r11, 0 # outputs
	movi r14, 15 # reset signal
	movi r15, 255 # counting bounds
	stwio r11, (r9) # initialize
	
pause:
	ldwio r12, (r10) # input edge
	bne r12, r0, pressedp # key was pressed
	br pause
	
count:
	addi r11, r11, 1 # counting
	stwio r11, (r9) # output to LED
	ldwio r12, (r10) # input edge
	bne r12, r0, pressedc # key was pressed
	call delay
	ble r11, r15, count # check boundary
	movi r11, 0 # reset
	br count
	
pressedp:
	call wait
	stwio r14, (r8) # clear
	br count

pressedc:
	call wait
	stwio r14, (r8) # clear
	br pause

delay:
	movia r13, 2500000 # est. 10M for de1 board
cont:
	subi r13, r13, 1
	bne r13, r0, cont
	ret

wait:
	ldwio r4, (r10) # wait until released
	bne r4, r0, wait
	ret
