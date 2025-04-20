.global _start
.equ LEDs, 0xFF200000
_start: movi r8, 0 # result
		movi r9, 1 # counter
		movi r10, 30 # end loop
		
myloop: add r8, r8, r9 # r8 + r9
		addi r9, r9, 1 # r9++
		ble r9, r10, myloop # r9 <= r10

		mov r12, r8
		movia r25, LEDs
		stwio r12, (r25)
	done: br done # done