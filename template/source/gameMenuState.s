/*
	1=B
	2=Y
	3=select
	4=start
	5=Up
	6=Down
	7=Left
	8=Right
 	9=A
	10=X

DOES NOT WORK

	compare the buttons and change state
 	* 
*/


updateState:
	buttons .req r7
	push {r0, lr}

check_up:
	mov r0, #16
	andS r0, buttons, r0
	//bleq menuUp
check_down:
	mov r0, #32
	andS r0, buttons, r0
	//bleq menuDown
check_a:
	mov r0, #256
	andS r0, buttons, r0
	//bleq menuAct

	pop {lr, r0}
	mov pc, lr

