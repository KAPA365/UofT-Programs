.section .exceptions, "ax"
IRQ_HANDLER:
		# save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 20          # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)
		stw     r21, 12(sp)
        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts
		
SKIP_EA_DEC:
        stw     ea, 16(sp)
		movi 	r21, 0x2
        andi    r20, et, 0x3        # check if interrupt is from pushbuttons / timer
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
		beq		r20, r21, is_keys	# is it from keys?
		
is_timer:							# if not then timer
		call	TIMER_ISR
		br		END_ISR
		
is_keys:
		call    KEY_ISR
		br		END_ISR
		
END_ISR:
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
		ldw     r21, 12(sp)
        ldw     ea, 16(sp)
        addi    sp, sp, 20          # restore stack pointer
        eret                        # return from exception

.text
.equ LED_BASE, 0xFF200000
.equ KEY_BASE, 0xFF200050
.equ KEY_EDGE, 0xFF20005C
.equ TIMER_BASE, 0xFF202000
.equ COUNTER_DELAY, 25000000
.global  _start
_start:
	movia 	sp, 0x20000 
    /* Set up stack pointer */
    call    CONFIG_TIMER        # configure the Timer
    call    CONFIG_KEYS         # configure the KEYs port
    /* Enable interrupts in the NIOS-II processor */

    movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
LOOP:
    ldw     r10, 0(r9)          # global variable
    stwio   r10, 0(r8)          # write to the LEDR lights
    br      LOOP

CONFIG_TIMER:
			subi    sp, sp, 16          # make room on the stack
        	stw     r3, 0(sp)
        	stw     r4, 4(sp)
        	stw     r5, 8(sp)
			stw     ra, 12(sp)
			movia 	r3, TIMER_BASE
			stwio 	r0, (r3) # clear
			movia 	r4, COUNTER_DELAY
			srli 	r5, r4, 16 # 16 bits right
			andi 	r4, r4, 0xFFFF # keep lower 16 bits
			stwio 	r4, 0x8(r3) # write to low period
			stwio 	r5, 0xc(r3) # - high period
			movi 	r4, 0b0111 # cont mode, start, interrupt
			stwio 	r4, 0x4(r3) # contol signals
			ldw     r3, 0(sp)
        	ldw     r4, 4(sp)
        	ldw     r5, 8(sp)
			ldw     ra, 12(sp)
			addi    sp, sp, 16
			ret

CONFIG_KEYS:
			subi    sp, sp, 20          # make room on the stack
        	stw     r2, 0(sp)
        	stw     r4, 4(sp)
        	stw     r5, 8(sp)
			stw     r6, 12(sp)
			stw     ra, 16(sp)
			movia 	r2, KEY_BASE
			movi 	r4, 0xf 
			stwio 	r4, 0xC(r2) # clear all edge
			stwio 	r4, 8(r2) # turn on all interrupt
			movi 	r5, 0x3 # 0011 to turn on both 
			movi 	r6, 0x1
			wrctl 	ctl3, r5 # enable IRQ1, IRQ0
			wrctl 	ctl0, r6 # enable interrupts
        	ldw     r2, 0(sp)
        	ldw     r4, 4(sp)
        	ldw     r5, 8(sp)
			ldw     r6, 12(sp)
			ldw     ra, 16(sp)
			addi    sp, sp, 20
			ret

KEY_ISR:	
			subi    sp, sp, 36          # make room on the stack
        	stw     r4, 0(sp)
        	stw     r5, 4(sp)
        	stw     r6, 8(sp)
			stw		r2, 12(sp)
			stw		ra, 16(sp)
			stw     r7, 20(sp)
        	stw     r8, 24(sp)
			stw		r9, 28(sp)
			stw		r10, 32(sp)
			
			movia 	r2, KEY_BASE
			movia	r4, RUN
			movi	r7, 0b0001
			movi	r8, 0b0010
			movi	r9, 0b0100
			movi	r10, 0b1000
			ldwio 	r6, 0xC(r2)
			stwio 	r6, 0xC(r2)
			beq		r6, r7, key0p
			beq		r6, r8, key1p
			beq		r6, r9, key2p
			beq		r6, r10, key3p
			
			
key0p:		ldw		r5,(r4)
			xori	r5, r5, 0x1 # toggle
			stw		r5, (r4)
			br 		done
			
key1p:		ldw		r5,(r4)
			slli	r5, r5, 1 # multiply by 2
			stw		r5, (r4)
			br 		done
			
key2p:		ldw		r5,(r4)
			srli	r5, r5, 1 # multiply by 2
			stw		r5, (r4)
			br 		done

key3p:		br done # do nothing
			
done:		ldw		r5, (r4)
			ldw     r4, 0(sp)
        	ldw     r5, 4(sp)
        	ldw     r6, 8(sp)
			ldw		r2, 12(sp)
			ldw		ra, 16(sp)
			ldw     r7, 20(sp)
        	ldw     r8, 24(sp)
			ldw		r9, 28(sp)
			ldw		r10, 32(sp)
			addi    sp, sp, 36
			ret
			
TIMER_ISR:	subi    sp, sp, 20          # make room on the stack
        	stw     r4, 0(sp)
        	stw     r5, 4(sp)
        	stw     r6, 8(sp)
			stw		r7, 12(sp)
			stw		ra, 16(sp)
			movia	r4, RUN
			ldw		r5,(r4)
			movia	r6, COUNT
			ldw		r7, (r6) # r6 is counting with step RUN
			add		r7, r7, r5
			stw		r7, (r6)
			call	CONFIG_TIMER
			ldw     r4, 0(sp)
        	ldw     r5, 4(sp)
        	ldw     r6, 8(sp)
			ldw		r7, 12(sp)
			ldw		ra, 16(sp)
			addi    sp, sp, 20
			ret

.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.end