.text
.equ PIXBUF, 0xc8000000		// Pixel buffer
.equ PIXBUFMAX, 0xc8040000  // Last Pixel
.equ CHARBUF, 0xc9000000    // Char Buffer
.equ LastChar, 0xc9001dc0   // LAST CHAR BUFFER
.equ HashTag, 0x23232323
.equ snakeHead, 0x40 
.equ snakeBody, 0x2b2b
.equ widthChar, 0x100000 // Mémore résvé pour les adresses en X
.equ heightChar, 0x101000 // Mémore réservé pour les adresses en Y
.equ direction, 0x5000 // La direction : 0 -> haut, 1 -> gauche, 2 -> bas, 3 -> droit
.equ UARTINOUT, 0xff201000
.equ headPos, 0x800

.global _start
_start:
    ldr r8, =widthChar
    ldr r9, =heightChar
    
	// CLEAR SCREEN
	ldr r0, =PIXBUF
    ldr r1, =0x0
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
    ldr r3, =0x23232323
    ldr r1, =0xc9001d90 // LAST ONE
    mov r2, #0
    bl drawLeftSideBorder
    
    ldr r0, =0xc900004e
    ldr r3, =0x23232323
    ldr r1, =0xc9001dd0 // LAST ONE
    bl drawRightSideBorder
    
    ldr r0, =0xc9001d80
    ldr r3, =HashTag
    ldr r1, =0x50
    add r1, r0, r1
    bl drawBottomBorder
    
    ldr r0, =CHARBUF
    ldr r3, =HashTag
    ldr r1, =0x50
    add r1, r0, r1
    mov r2, #0
   	bl drawUpperBorder
    
    pop {pc}
        
    drawLeftSideBorder:
    	cmp r0, r1
        	bxge lr
            
        str r3, [r0]
        str r0, [r9, r2] // Ecrit les adresses des Y
        add r0, #0x80
        add r2, #4
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
        add r0, #0x4
        b drawBottomBorder


mainLoop:
	// r8 et r9 réservés pour widthChar et heightChar
    // r7 réservé pour la direction
    
    ldr r3, =snakeHead
    ldr r4, =headPos
    mov r6, #4	// NE PAS TOUCHER (utilisé pour le décalage)
    ldr r7, =direction

    mov r0, #10	// X SPAWN
    mov r1, #5 // Y SPAWN

    str r0, [r4, #0]
    str r1, [r4, #4]
    
    bl drawCharacter
    
    loop:
        bl getch
        b .


move:
	ldr r1, =0x807a
    cmp r0, r1 // HAUT
    	beq up
        
    ldr r1, =0x8071
    cmp r0, r1 // GAUCHE
    	beq left
        
    ldr r1, =0x8073
    cmp r0, r1 // BAS
    	beq down
        
    ldr r1, =0x8064
    cmp r0, r1 // DROITE
    	beq right
   	// else
   		b getch
    
    up:
    	ldr r0, [r4]
        ldr r1, [r4, #4]
        
        sub r1, #1
    	b endMove
    left:
    	ldr r0, [r4]
        ldr r1, [r4, #4]
        
        sub r0, #1
        b endMove
    down:
    	ldr r0, [r4]
        ldr r1, [r4, #4]
    
    	add r1, #1
    	b endMove
    right:
    	ldr r0, [r4]
        ldr r1, [r4, #4]
    
    	add r0, #1
    	b endMove
    endMove:
    	str r0, [r4]
        str r1, [r4, #4]
        bl drawCharacter
        b loop


getch:
	ldr r1, =UARTINOUT
    ldr r0, [r1]
    	
	b move


drawCharacter: // Dessine un caractère en fonction de r0 (X) et r1 (Y)
	push {r10, r11}
    
    ldr r3, =snakeHead
    mov r10, #0
	firstCalc: // POUR r0
        cmp r0, #0
            beq endFirstCalc
        cmp r0, #1
        	moveq r12, #0x100
            muleq r3, r3, r12
            beq endFirstCalc
        cmp r0, #2
        	moveq r12, #0x10000
            muleq r3, r3, r12
            beq endFirstCalc
        cmp r0, #3
            moveq r12, #0x1000000
            muleq r3, r3, r12
            beq endFirstCalc
        // else
            sub r0, #4
            add r10, #4
            b firstCalc       
    endFirstCalc:
    
    mul r1, r1, r6
	
    ldr r0, [r8, r10]
    ldr r1, [r9, r1]
    sub r1, #0xc9000000
    add r2, r0, r1
    
	str r3, [r2]
    
    pop {r10, r11}
    
    bx lr
    

gameover:

	b .
