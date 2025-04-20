/******************************************************************************
 * Write an interrupt service routine
 *****************************************************************************/
.section .exceptions, "ax"
IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 16          # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 12(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        call    KEY_ISR             # if yes, call the pushbutton ISR

END_ISR:
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     ea, 12(sp)
        addi    sp, sp, 16          # restore stack pointer
        eret                        # return from exception

/*********************************************************************************
 * set where to go upon reset
 ********************************************************************************/
.section .reset, "ax"
        movia   r8, _start
        jmp    r8

/*********************************************************************************
 * Main program
 ********************************************************************************/
.text
.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030
.equ KEYs, 0xff200050
.global  _start
_start:
        /*
        1. Initialize the stack pointer
        2. set up keys to generate interrupts
        3. enable interrupts in NIOS II
        */
			movia 	sp, 0x20000 
			movia 	r2, KEYs 
			movi 	r4, 0xf 
			stwio 	r4, 0xC(r2) # clear all edge
			stwio 	r4, 8(r2) # turn on all interrupt
			movi 	r5, 0x2 
			movi 	r6, 0x1
			wrctl 	ctl3, r5 # enable IRQ1
			wrctl 	ctl0, r6 # enable interrupts

IDLE:   	br  	IDLE

KEY_ISR:	
			subi    sp, sp, 36          # make room on the stack
			stw     r4, 0(sp)
			stw     r5, 4(sp)
			stw     r7, 8(sp)
			stw     r8, 12(sp)
			stw     r9, 16(sp)
			stw     r10, 20(sp)
			stw     r11, 24(sp)
			stw		ra, 28(sp)
			stw		r6, 32(sp)
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
		
key0p:		movi	r5, 0
			movi	r4, 0
			movia	r7, HEX_BASE1
			ldwio	r8, (r7)
			srli	r9, r8, 0
			andi	r10, r9, 0x7f
			bne		r10, r0, hex0b
			
back0:		
			call	HEX_DISP
			br 		done
			
hex0b:		movi	r4, 0x10
			br 		back0

key1p:		movi	r5, 1
			movi	r4, 1
			movia	r7, HEX_BASE1
			ldwio	r8, (r7)
			srli	r9, r8, 8
			andi	r10, r9, 0x7f
			bne		r10, r0, hex1b
			
back1:		
			call	HEX_DISP
			br 		done
			
hex1b:		movi	r4, 0x10
			br 		back1
			
key2p:		movi	r5, 2
			movi	r4, 2
			movia	r7, HEX_BASE1
			ldwio	r8, (r7)
			srli	r9, r8, 16
			andi	r10, r9, 0x7f
			bne		r10, r0, hex2b
			
back2:		
			call	HEX_DISP
			br 		done
			
hex2b:		movi	r4, 0x10
			br 		back2
			
key3p:		movi	r5, 3
			movi	r4, 3
			movia	r7, HEX_BASE1
			ldwio	r8, (r7)
			srli	r9, r8, 24
			andi	r10, r9, 0x7f
			bne		r10, r0, hex3b
			
back3:		
			call	HEX_DISP
			br 		done
			
hex3b:		movi	r4, 0x10
			br 		back3
			
done:		ldw     r4, 0(sp)
			ldw     r5, 4(sp)
			ldw     r7, 8(sp)
			ldw     r8, 12(sp)
			ldw     r9, 16(sp)
			ldw     r10, 20(sp)
			ldw     r11, 24(sp)
			ldw		ra, 28(sp)
			ldw		r6, 32(sp)
			addi    sp, sp, 36         # restore stack pointer
			ret

HEX_DISP:   subi    sp, sp, 28          # make room on the stack
			stw     r2, 0(sp)
			stw     r4, 4(sp)
			stw     r5, 8(sp)
			stw     r6, 12(sp)
			stw     r7, 16(sp)
			stw     r8, 20(sp)
			stw		ra, 24(sp)
			movia    r8, BIT_CODES         # starting address of the bit codes
	    	andi     r6, r4, 0x10	   # get bit 4 of the input into r6
	   	 	beq      r6, r0, not_blank 
	    	mov      r2, r0
	    	br       DO_DISP
not_blank:  andi     r4, r4, 0x0f	   # r4 is only 4-bit
            add      r4, r4, r8            # add the offset to the bit codes
            ldb      r2, 0(r4)             # index into the bit codes

#Display it on the target HEX display
DO_DISP:    
			movia    r8, HEX_BASE1         # load address
			movi     r6, 4
			blt      r5, r6, FIRST_SET      # hex4 and hex 5 are on 0xff200030
			sub      r5, r5, r6            # if hex4 or hex5, we need to adjust the shift
			addi     r8, r8, 0x0010        # we also need to adjust the address
FIRST_SET:
			slli     r5, r5, 3             # hex*8 shift is needed
			addi     r7, r0, 0xff          # create bit mask so other values are not corrupted
			sll      r7, r7, r5 
			addi     r4, r0, -1
			xor      r7, r7, r4  
    		sll      r4, r2, r5            # shift the hex code we want to write
			ldwio    r5, 0(r8)             # read current value       
			and      r5, r5, r7            # and it with the mask to clear the target hex
			or       r5, r5, r4	           # or with the hex code
			stwio    r5, 0(r8)		       # store back
END:		
			ldw     r2, 0(sp)
			ldw     r4, 4(sp)
			ldw     r5, 8(sp)
			ldw     r6, 12(sp)
			ldw     r7, 16(sp)
			ldw     r8, 20(sp)
			ldw		ra, 24(sp)
			addi    sp, sp, 28          # restore stack pointer
			ret

BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

            .end
