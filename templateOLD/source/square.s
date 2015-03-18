.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
    mov     sp, #0x8000
	
	bl		EnableJTAG

	bl		InitFrameBuffer

	// branch to the halt loop if there was an error initializing the framebuffer
	cmp		r0, #0
	beq		haltLoop$

	ldr		r1, =FrameBufferPointer
	str		r0, [r1] // storing the frame buffer pointer into the data structure.

	mov		r0, #75 //size of the square
	mov		r1, #100 // x coordinate of the origin 
	mov		r2, #100 // y coordinate of the origin
	ldr		r3,	=0xFFF0 // color
	bl		Square // calling square function
    
haltLoop$:
	b		haltLoop$

/* Draw Pixel to a 1024x768x16bpp frame buffer
 * Note: no bounds checking on the (X, Y) coordinate
 *	r1 - pixel X coord
 *	r2 - pixel Y coord
 *	r3 - colour (use low half-word)
 */
DrawPixel16bpp:
	push	{r4}

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0] // loading the frame buffer pointer from the data structure.

	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r1, r2, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset
	strh	r3,		[r0, offset]

	pop		{r4}
	bx		lr

// r0, size
// r1: x
//r2: y
// r3: color
Line:
	push	{r4-r8, lr}
	mov	r4, r0
	mov	r5, r1
	mov	r6, r2
	mov	r7, r3

	mov	r8, #0
LineLoop:
	cmp	r8, r4
	beq	LineLoopEnd

	mov	r1, r5
	mov	r2, r6
	mov	r3, r7
	bl	DrawPixel16bpp

	add	r8, #1
	add	r5, #1
	b	LineLoop

LineLoopEnd:

	pop	{r4-r8, pc}


// r0, size
// r1: x
//r2: y
// r3: color
Square:
	push	{r4-r8, lr}
	mov	r4, r0
	mov	r5, r1
	mov	r6, r2
	mov	r7, r3

	mov	r8, #0
SquareLoop:
	cmp	r8, r4
	beq	SquareLoopEnd
	
	mov	r0, r4
	mov	r1, r5
	mov	r2, r6
	mov	r3, r7
	bl	Line

	add	r8, #1
	add	r6, #1
	b	SquareLoop

SquareLoopEnd:

	pop	{r4-r8, pc}

.section .data

// Frame Buffer Pointer address.
FrameBufferPointer:
	.int	0

