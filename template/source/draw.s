.globl drawMove
.globl drawInit
.globl drawClear


x		.req	r1
y		.req	r2
colour	.req	r3
width	.req	r4
height 	.req	r5

drawInit:
	push {lr}

	mov x, #500
	mov y, #300
	mov colour, #0xffffff
	mov width, #50
	mov height, #50
	
	bl drawSquare
	
	pop {lr}
	mov pc, lr
	
drawMove:
	push {r6, r8, lr}
	
	

c1:	cmp r10, #1 // up
	bne c2
	
	sub		r6, y, #10
	cmp		r6, #0
	movgt	y, r6
		
c2:	cmp r10, #2 // down
	bne c3
	
	add		r6, y, #10
	add		r6, height
	ldr		r8, =maxHeight
	ldr		r8, [r8]
	cmp 	r6, r8
	sub		r6, height
	movle	y, r6
	
c3:	cmp r10, #3 // left
	bne c4
	
	sub		r6, x, #10
	cmp		r6, #0
	movgt	x, r6
	
c4:	cmp r10, #4 // right
	bne end
	
	add		r6, x, #10
	add		r6, width
	ldr		r8, =maxWidth
	ldr		r8 , [r8]
	cmp		r6, r8
	sub		r6, width
	movle	x, r6
	
end:
	bl drawSquare

	pop {r6, r8, lr}
	mov pc, lr


.globl draw_initialState
DrawPixel16bpp:
	push		{r4}

	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	x, y, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset
	strh	r3,	[r0, offset]
	
	 

	pop		{r4}
	bx		lr

drawSquare:
	push 		{r6, r8, lr}
	
	add		r6, width, x
	add 	r8, height, y
	bl loop_square

top1:
	
	add 		y, #1
loop_square:
	add 		x, #1

	cmp 		x, r6			//compare r1 to original position of r1+r3
	bl			DrawPixel16bpp
	bne			loop_square
	sub			x, width			//r1 = r1-r3 , back to original position
	
	cmp 		y, r8
	bne     	top1
	sub			y, height
	pop 		{r6, r8, lr}
	mov  		pc, lr
	
drawClear: // clears screen but too slowly
	push {r1-r5, lr}
	
	mov colour, #0x000000
	
	mov x, #0
	mov y, #0
	ldr width, =maxWidth
	ldr width, [width]
	ldr height, =maxHeight
	ldr height, [height]
	
	bl drawSquare
	
	pop {r1-r5, lr}
	mov pc, lr

.section .data

.align 4
maxWidth:
	.int	1023		// X Resolution (width)
maxHeight:
	.int	767			// Y Resolution (height)
