.text  # The numbers that turn into executable instructions
.global _start
_start:

/* r13 should contain the grade of the person with the student number, -1 if not found */
/* r10 has the student number being searched */


	movia r10, 718293		# r10 is where you put the student number being searched for

/* Your code goes here  */
	movia r8, Snumbers # addr of numlist
	movia r11, result # addr of result
	movia r12, Grades # ...
	movi r13, 0 # 0
	movi r14, -1 # -1
	
finding: ldw r9, (r8) # load num
	ldw r7, (r12) # load grade
	beq r9, r10, found # compare
	beq r9, r13, nfound # check end
	
	addi r8, r8, 4 # go to next element in list
	addi r12, r12, 4 # same
	br finding # loop
	
found: stw r7, (r11) 
	br iloop
nfound: stw r14, (r11) # r14 holds -1
	br iloop
	
iloop: br iloop

.data  	# the numbers that are the data 

/* result should hold the grade of the student number put into r10, or
-1 if the student number isn't found */ 

result: .word 0
		
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .word 99, 68, 90, 85, 91, 67, 80
        .word 66, 95, 91, 91, 99, 76, 68  
        .word 69, 93, 90, 72
	
	
