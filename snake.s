.text
.equ PIXBUF, 0xc8000000		// Pixel buffer
.equ PIXBUFMAX, 0xc8040000  // Last Pixel
.equ CHARBUF, 0xc9000000    // Char Buffer
.equ LastChar, 0xc9001dc0   // LAST CHAR BUFFER
.equ HashTag, 0x23232323
.equ snakeHead, 0x40 
.equ snakeBody, 0x2b
.equ widthChar, 0x100000 // Mémore réservé pour les adresses en X
.equ heightChar, 0x101000 // Mémore réservé pour les adresses en Y
.equ UARTINOUT, 0xff201000
.equ headPos, 0x102000 // Mémoire réservé pour la position de la tête
.equ bodyPos, 0x103000 // Mémoire réservé pour la position du corps
.equ bodySize, 0x110000 // Mémoire réservé pour la taille du corps

// On a préféré définir nous-mêmes les adresses car quand l'émulateur les choississait, cela créait des conflits
// Avant de run l'émulation, désactiver le debugging check "Function nesting too deep"

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
    

clearScreen: // SUPPRIME LES COULEURS ALEATOIRES DU VGA PIXEL BUFFER
	cmp r0, r2
    	bxge lr
        
    strh r1, [r0]
    add r0, #0x2
    b clearScreen
    

clearCharacters: // SUPPRIME TOUT LES CARACTERES
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
    	
    
drawBorders: // DESSINE LES BORDURES
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
    ldr r4, =headPos
    ldr r5, =bodyPos
    mov r6, #4	// NE PAS TOUCHER (utilisé pour le décalage)

    mov r0, #10	// X SPAWN TÊTE
    mov r1, #5 // Y SPAWN TÊTE

    str r0, [r4, #0]
    str r1, [r4, #4]
    
    ldr r3, =snakeHead
    bl drawCharacter
    
    
    mov r0, #9
    mov r1, #5
    
    str r0, [r5, #0]
    str r1, [r5, #4]
    
    ldr r3, =snakeBody
    bl drawCharacter
    
    mov r0, #8
    mov r1, #5
    
    str r0, [r5, #8]
    str r1, [r5, #0xc]
    
    ldr r3, =snakeBody
    bl drawCharacter
    
    mov r0, #7
    mov r1, #5
    str r0, [r5, #0x10]
    str r1, [r5, #0x14]
    
    ldr r3, =snakeBody
    bl drawCharacter
    
    mov r0, #3
    ldr r1, =bodySize
    str r0, [r1]
    loop:
        bl getch
        b .


move: // CALCUL PROCHAINE POSITION
	ldr r1, =0x807a
    cmp r0, r1 // HAUT
    	bleq clrChar
    	beq up
        
    ldr r1, =0x8071
    cmp r0, r1 // GAUCHE
    	bleq clrChar
    	beq left
        
    ldr r1, =0x8073
    cmp r0, r1 // BAS
    	bleq clrChar
    	beq down
        
    ldr r1, =0x8064
    cmp r0, r1 // DROITE
    	bleq clrChar
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
    	push {r0, r1, r3}
    	bl drawBody // CALCUL ET AFFICHAGE NOUVEAU CORPS
        pop {r0, r1, r3}
        
    	str r0, [r4]
        str r1, [r4, #4]
        ldr r3, =snakeHead // AFFICHE LA TÊTE
        bl drawCharacter
        b loop

getch:
	ldr r1, =UARTINOUT
    ldr r0, [r1]
    	
	b move
    
    
drawBody: // CALCUL ET AFFICHAGE NOUVEAU CORPS
	push {r8, r9, r10, r11, r12, lr}
    
    mov r11, #4
    
    ldr r10, =bodySize
    ldr r10, [r10] // Nombre d'intérations à effectuer
    add r10, r10 
    sub r10, #1
    
    mul r10, r10, r11
    
    ldr r8, =0x103008
    
    ldr r11, =bodyPos
    add r10, r11, r10
    
    ldr r12, =headPos
    add r12, #4
    
    loopDrawBody: // CALCUL NOUVEAU CORPS
        cmp r10, r11
            blt callDrawElement
        
        cmp r10, r8
        	blt firstDrawBodyElement
        
        mov r0, r10
        sub r9, r10, #8
        ldr r1, [r9]
        str r1, [r0]
        
        sub r10, #4
        b loopDrawBody
    firstDrawBodyElement: // CALCUL PREMIER ELEMENT DU CORPS
    	mov r0, r10
        ldr r1, [r12]
        str r1, [r0]
        
        sub r10, #4
        sub r12, #4
        b loopDrawBody
    
	callDrawElement: // AFFICHAGE DU CORPS
    	ldr r10, =bodySize
        ldr r10, [r10]
        mov r2, #0
        ldr r3, =snakeBody
        
        loopCallDrawElement:
        	cmp r2, r10
            	popge {r8, r9, r10, r11, r12, lr}
                bxge lr
                
            mov r0, #8
            mov r1, #8
            mul r0, r0, r2
            mul r1, r1, r2
            add r1, #4
            
            add r0, r11, r0
            add r1, r11, r1
            
            ldr r0, [r0]
            ldr r1, [r1]
            
            push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, lr} // Redondant
            bl drawCharacter
            pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
            
            add r2, #1
            
            b loopCallDrawElement
        
    
clrChar: // SUPPRIME LES CARACTERES
	push {r0, r1, r2, r4, lr}
    
    ldr r0, =CHARBUF
    ldr r4, =0x00
    ldr r1, =0x50
    ldr r2, =LastChar
    bl clearCharacters
    
    bl drawBorders
    
    pop {r0, r1, r2, r4, pc}
    

drawCharacter: // Dessine un caractère en fonction de r0 (X) et r1 (Y) et r3 le caractère à écrire
	push {r8, r9, r10}
    
    ldr r8, =widthChar
    ldr r9, =heightChar
    
    mov r10, #0
	calc: // POUR r0 (X)
        cmp r0, #0
            beq endCalc
        cmp r0, #1
        	moveq r12, #0x100
            muleq r3, r3, r12
            beq endCalc
        cmp r0, #2
        	moveq r12, #0x10000
            muleq r3, r3, r12
            beq endCalc
        cmp r0, #3
            moveq r12, #0x1000000
            muleq r3, r3, r12
            beq endCalc
        // else
            sub r0, #4
            add r10, #4
            b calc       
    endCalc:
    
    mul r1, r1, r6
	
    ldr r0, [r8, r10]
    ldr r1, [r9, r1]
    sub r1, #0xc9000000
    add r2, r0, r1
    
   	ldr r1, [r2]
    add r3, r1, r3
	str r3, [r2]  // DESSINE LE CARACTERE    
    
    pop {r8, r9, r10}
    
    bx lr
    

gameover:

	b .