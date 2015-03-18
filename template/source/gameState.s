.globl updateState

/*
r1
0 = do nothing
1 = UP
2 = DOWN
3 = LEFT
4 = RIGHT
*/

updateState:
	push {r0-r5, lr}
	buttons .req r7
	mov r10, #0
//check start

check_up:
	mov r0, #16
	and r0, buttons
	cmp r0, #0
	moveq r10, #1 // up
	
check_down:
	mov r0, #32
	and r0, buttons
	cmp r0, #0
	moveq r10, #2 // down
	
check_left:
	mov r0, #64
	and r0, buttons
	cmp r0, #0
	moveq r10, #3 // left
	
check_right:
	mov r0, #128
	and r0, buttons
	cmp r0, #0
	moveq r10, #4 // right
// check A

end:
	pop {r0-r5, lr}
	mov pc, lr
