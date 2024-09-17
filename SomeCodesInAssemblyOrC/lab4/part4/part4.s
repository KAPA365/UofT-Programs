.equ LEDs, 0xFF200000
.equ KEY_BASE, 0xFF200050
.equ KEY_EDGE, 0xFF20005C
.equ TIMER_BASE, 0xFF202000
.equ COUNTER_DELAY, 1000000
.global _start
_start:
	movia r8, KEY_EDGE
	movia r9, LEDs
	movia r10, KEY_BASE
	movi r11, 0 # hundreths
	movi r19, 0 # whole
	movi r17, 100 # bounds
	movi r18, 8
	movi r14, 15 # reset signal
	call display
	
pause:
	ldwio r12, (r10) # input edge
	bne r12, r0, pressedp # key was pressed
	br pause
	
count:
	addi r11, r11, 1 # counting
	bge r11, r17, carry
back:
	call display
	ldwio r12, (r10) # input edge
	bne r12, r0, pressedc # key was pressed
	call delay
	br count
	
pressedp:
	call wait
	stwio r14, (r8) # clear
	br count

pressedc:
	call wait
	stwio r14, (r8) # clear
	br pause
	
carry:
	movi r11, 0 # reset hundredths
	addi r19, r19, 1 # carry
	br back

delay:
	movia r3, TIMER_BASE
	stwio r0, (r3) # clear
	movia r4, COUNTER_DELAY
	srli r5, r4, 16 # 16 bits right
	andi r4, r4, 0xFFFF # keep lower 16 bits
	stwio r4, 0x8(r3) # write to low period
	stwio r5, 0xc(r3) # - high period
	movi r4, 0b0110 # cont mode, start
	stwio r4, 0x4(r3) # contol signals
cont:
	ldwio r6, (r3) # read timer status
	andi r6, r6, 0b1 # TO bit
	beq r6, r0, cont
	stwio r0, (r3) # clear
	ret

wait:
	ldwio r7, (r10) # wait until released
	bne r7, r0, wait
	ret
	
display:
	slli r6, r19, 7
	add r6, r6, r11
	stwio r6, (r9) # output to LED
	ret