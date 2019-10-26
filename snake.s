.data
gameSize:
.int 0x28, 0x3c // A vérifier
headPos:
.int 0xa, 0xa



.text
.equ PIXBUF, 0xc8000000		// Pixel buffer
.equ PIXBUFMAX, 0xc8040000  // Last Pixel
.equ CHARBUF, 0xc9000000    // Char Buffer
.equ LastChar, 0xc9001dc0   // LAST CHAR BUFFER
.equ BLACK, 0x00000000		// BLACK COLOUR
.equ HashTag, 0x23232323
.equ snakeHead, 0x40 
.equ snakeBody, 0x2b2b
.equ widthChar, 0x180 // Mémore réservé de 180 à 230 exclu
.equ heightChar, 0x230 // Mémore réservé à partir de 230
.global _start
_start:
    mov r12, #0
    ldr r8, =0x180
    ldr r9, =0x230
    
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
    
    bl mainLoop
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
    ldr r3, =0x23
    ldr r1, =0xc9001d90 // LAST ONE
    bl drawLeftSideBorder
    
    ldr r0, =0xc900004e
    ldr r3, =0x2300
    ldr r1, =0xc9001dd0 // LAST ONE
    bl drawRightSideBorder
    
    ldr r0, =CHARBUF
    ldr r3, =HashTag
    ldr r1, =0x50
    add r1, r0, r1
    mov r2, #0
   	bl drawUpperBorder
    
    ldr r0, =0xc9001d80
    ldr r3, =HashTag
    ldr r1, =0x50
    add r1, r0, r1
    mov r2, #0
    bl drawBottomBorder
    
    pop {pc}
        
    drawLeftSideBorder:
    	cmp r0, r1
        	bxge lr
            
        strh r3, [r0]
        add r0, #0x80
        add r12, #1
        b drawLeftSideBorder
        
    drawRightSideBorder:
    	cmp r0, r1
        	bxge lr
            
        strh r3, [r0]
        add r0, #0x80
        b drawRightSideBorder
        
    drawUpperBorder:
        cmp r0, r1
            bxge lr

        str r3, [r0]
        str r0, [r8, r2] // Ecrit les adresses des X
        add r0, #0x4
        add r2, #4
        b drawUpperBorder
        
    drawBottomBorder:
    	cmp r0, r1
            bxge lr

        str r3, [r0]
        str r0, [r9, r2]
        add r0, #0x4
        add r2, #4
        b drawBottomBorder
        
drawCharacter: // Dessine un caractère en fonction de coordonnées et du caractère en paramètre
	strh r5, [r0]
    bx lr


mainLoop:
	// r8 et r9 réservés pour widthChar et heightChar
    ldr r5, =snakeHead
    ldr r0, [r8, #0x8]
    
	bl drawCharacter
	b .


gameover:

	b .
