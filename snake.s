.data
bodyX:
.int 


.text
.equ PIXBUF, 0xc8000000		// Pixel buffer
.equ PIXBUFMAX, 0xc8040000  // Last Pixel
.equ CHARBUF, 0xc9000000    // Char Buffer
.equ LastChar, 0xc9001dc0    // LAST CHAR BUFFER
.equ BLACK, 0x00000000		// BLACK COLOUR
.equ HashTag, 0x2323

.global _start
_start:
	// CLEAR SCREEN
	ldr r0, =PIXBUF
    ldr r1, =BLACK
    ldr r2, =PIXBUFMAX
	bl clearScreen
    
    // CLEAR CHARACTERS
    ldr r0, =CHARBUF
    ldr r4, =0x00
    ldr r1, =0x50
    ldr r2, =LastChar
    bl clearCharacters
    
    bl drawBorders
    b .

clearScreen:
	cmp r0, r2
    	bxge lr
        
    strh r1, [r0]
    add r0, #0x2
    b clearScreen

clearCharacters:
	cmp r0, r2
    	bxgt lr
    
    ldr r1, =0x50
    add r1, r0, r1
    loop1:
        cmp r0, r1
            addge r0, r0, #0x30
            bge clearCharacters

        strh r4, [r0]
        add r0, #0x2
        b loop1
    	
    
drawBorders:
	push {lr}
    
    ldr r0, =CHARBUF
    ldr r3, =HashTag
    ldr r1, =0xc9001d90 // LAST ONE
    bl drawLeftSideBorder
    
    ldr r0, =0xc900004e
    ldr r3, =HashTag
    ldr r1, =0xc9001dd0 // LAST ONE
    bl drawRightSideBorder
    
    ldr r0, =CHARBUF
    ldr r3, =HashTag
    ldr r1, =0x50
    add r1, r0, r1
   	bl drawUpperBorder
    
    ldr r0, =0xc9001d80
    ldr r3, =HashTag
    ldr r1, =0x50
    add r1, r0, r1
    bl drawBottomBorder
    
    pop {pc}

	drawUpperBorder:
        cmp r0, r1
            bxge lr

        strh r3, [r0]
        add r0, #0x2
        b drawUpperBorder
        
    drawLeftSideBorder:
    	cmp r0, r1
        	bxge lr
            
        strh r3, [r0]
        add r0, #0x80
        b drawLeftSideBorder
        
    drawRightSideBorder:
    	cmp r0, r1
        	bxge lr
            
        strh r3, [r0]
        add r0, #0x80
        b drawRightSideBorder
        
    drawBottomBorder:
    	cmp r0, r1
            bxge lr

        strh r3, [r0]
        add r0, #0x2
        b drawBottomBorder

mainLoop:
	b .


nextStep:


eat:


draw:


gameover:

	b .
