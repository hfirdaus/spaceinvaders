.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
    mov     sp, #0x8000
	
	bl		EnableJTAG

	ldr	r0, =0x20200004	// Function Select 1 Address
	ldr	r1, [r0]	// Load value into register
	mov	r2, #0b111	// Set up clear mask
	bic	r1, r2, lsl #18	// Clear bits 18-20
	mov	r2, #0b001	// Value mask (output = 001)
	orr	r1, r2, lsl #18	// OR-mask into bits 18-20
	str	r1, [r0]	// Store register to memory

loop:
	ldr r0, =0x2020001C
	mov r1, #0x00010000
	str r1, [r0]
	
	bl delay

	ldr r0, =0x20200028
	mov r1, #0x00010000
	str r1, [r0]

	bl delay
	b loop

haltLoop$:
	b	haltLoop$


delay:
	mov r0, #1
delayLoop:
	add r0, #1
	cmp r0, #0xff0000
	ble delayLoop

	bx lr

.section .data
