.section .text
.globl	gpio_setFunctions
.globl  gpio_readLineValues
.globl buttonCheckLoop

/*
1. MOV buttons, #0 // register sampling buttons
2. writeGPIO (CLOCK,#1)
3. writeGPI0 (LATCH,#1)
4. Wait(12s) // signal to SNES to sample buttons
5. writeGPI0 (LATCH,#0)
6. pulseLoop: // start pulsing to read from SNES

1.i= 0
2.wait(6mus)
3.writeGPIO(CLOCK,#0) // falling edge
4.wait(6mus)
5.readGPIO(DATA, b) // read biti
6.buttons[i]= b
7.writeGPIO(CLOCK,#1) // rising edge; new cycle
8.i++ // next button
9.if (i< 16) branch
pulseLoop
*/

buttonCheckLoop:	
	push {r0-r5, lr}
	.equ	baseAddr,	0x20200000
	i .req r5
	buttons .req r7
	clock .req r4
	
	mov buttons, #0			//#1

	mov r0, #11	//clock, #1
	mov r1, #1
	bl writeGPIOLine

	mov r0, #9	//latch, #1
	mov r1, #1
	bl writeGPIOLine
	
	mov r3, #12	//wait 12 ms
	bl clock_wait

	mov r0, #9	// latch, #0
	mov r1, #0
	bl writeGPIOLine

	mov i, #0

pulseLoop:
	mov r3, #6
	bl clock_wait

	mov r0, #11
	mov r1, #0
	bl writeGPIOLine

	mov r3, #6
	bl clock_wait

	mov r0, #10
	mov r1, buttons
	bl readGPIOLine

break1:

	mov 	r0, #11	//clock, #1
	mov 	r1, #1
	bl 	writeGPIOLine

	add 	i, #1

	cmp 	i, #16
	blt 	pulseLoop

	pop 	{r0-r5, lr}
	mov 	pc, lr

//r3 # of microseconds to wait
clock_wait:
	push {lr}

	ldr 	r0, =0x20003004
	ldr 	clock, [r0]
	add 	clock, r3

wait_clock:
	ldr 	r2, [r0]
	cmp 	clock, r2 //stop when CLO = r1
	bhi 	wait_clock
	
	pop 	{lr}
	mov 	pc, lr

gpio_setFunctions:
	push	{lr, r0}

	//setting GPIO9 for LATCH (set to output)
	ldr 	r0, =baseAddr       	//address of GPSEL0
	ldr	r1, [r0]
	mov 	r2, #0b0111
	lsl 	r2, #27
	bic	r1,r2 						// clear pin9 bits
	mov	r3,#1 						// output function code
	lsl 	r3, #27 				// r3 = 0 001 000 000 000
	orr	r1, r3 						// set pin9 function in r1
	str	r1, [r0] 					// write back to GPFSEL0



	//setting GPIO10 for DATA (set to input)
	ldr 	r0, =0x20200004       	//address of GPSEL0
	ldr	r1, [r0]
	mov 	r2, #0b0111

	bic	r1,r2 						// clear pin10 bits
	mov	r3,#0 						// output function code

	orr	r1, r3 						// set pin10 function in r1
	str	r1, [r0] 					// write back to GPFSEL0


	//setting GPIO11 for OUTPUT
	ldr 	r0, =0x20200004       	//address of GPSEL0
	ldr	r1, [r0]
	mov 	r2, #0b0111
	lsl 	r2, #3
	bic	r1,r2 						// clear pin11 bits
	mov	r3,#1 						// output function code
	lsl 	r3, #3 					// r3 = 0 001 000 000 000
	orr	r1, r3 						// set pin11 function in r1
	str	r1, [r0] 					// write back to GPFSEL0

	pop	{lr, r0}
	mov 	pc,lr

/*readGPIOLine input values:
 *
 *input r0: line number 
 *input r1: set 1 or 0
 *
 */

writeGPIOLine:
	push {lr}
//	r2 = clock (GPIO 11) and latch (gpio 9)

	ldr r2, =baseAddr
	mov r3, #1
	lsl r3, r0 			//align bit for pin 11	
	teq r1, #0
	streq r3, [r2, #40] 			//GPCLR0
	strne r3, [r2, #28]				//GPSET0
	pop {lr}
	mov pc,lr

/*readGPIOLine input values:
 *
 *	input r0: line number 
 *	input r1: button
 *
 */
readGPIOLine:
	push {lr}
	ldr r2, =baseAddr
	ldr r1, [r2, #52] // gplev0
	mov r3, #1
	lsl r3, r0
	and r1, r3
	teq r1, #0
	moveq r4, #0 //return 0
	movne r4, #1 //return 1

	mov r9, r4
	lsl r9, i
	orr buttons, r9
	pop {lr}
	mov pc, lr

/*
writeGPIO_afterbuttons:
	
//	r2 = clock (GPIO 11)
	mov r0, #11
	ldr r2, =baseAddr
	mov r3, #1
	lsl r3, r0 //align bit for pin 11	
	teq r1, #0
	streq r3, [r2, #40] //GPCLR0
	strne r3, [r2, #28]//GPSET0
	
	add i, #1
	bl pulseLoop
	 
	mov pc, lr */
