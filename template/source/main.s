/*
	1. Draw game title and creator names
	2. Press A button to fire a bullet.
	3. Press Start button to open game menu
	4. Press any button to restart the game when game over.
	5. have to have win_or_lose condition	
For game menu:
	1. use up/down on D-pad to change menu-selection
	2. press A button on Restart Game; resets the game
	3. Press A button to Quit; terminate the game
	4. Press A button on Resume; resume the game


	initialize--> update-->clear-->draw-->Quit? --> update
	
	main file will deal with player input, update and state? 
*/
.section    .init
.globl     _start

//font: .incbin "font.bin"

_start:
    	b       	main
    
.section .text

main:
   	mov     sp, #0x8000
	
	bl		EnableJTAG
	bl		InitFrameBuffer

	// branch to the halt loop if there was an error initializing the framebuffer

	cmp		r0, #0
	beq		haltLoop$
initialize:
	bl		gpio_setFunctions
	bl 		drawInit // WORKS	
update:
	bl		buttonCheckLoop		//saves r0, r1, r2, r3, r4, r5
	bl 		updateState
breakafter:
	bl 		drawClear // doesn't work
	bl 		drawMove
breakpixel:
	bl		update
haltLoop$:
	b		haltLoop$

