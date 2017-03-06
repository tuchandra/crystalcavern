; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
;   Tushar Chandra (tac311)
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include grid.inc
include game.inc

;; Has keycodes
include keys.inc

;; For printing to screen
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

;; For random numbers
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib

.DATA

player SPRITE< >
enemy SPRITE< >
currAttack SPRITE< >
item1 SPRITE< >

level LEVEL< >

;; Testing strings
str_item_pickup BYTE "You obtained an item!", 0

;; Format strings for PrintRegs
fmtStr_eax BYTE "eax: %d", 0
outStr_eax BYTE 256 DUP(0)

fmtStr_ebx BYTE "ebx: %d", 0
outStr_ebx BYTE 256 DUP(0)

fmtStr_ecx BYTE "ecx: %d", 0
outStr_ecx BYTE 256 DUP(0)

fmtStr_edx BYTE "edx: %d", 0
outStr_edx BYTE 256 DUP(0)

;; Format strings for PrintTwoVals
fmtStr_first BYTE "first: %d", 0
outStr_first BYTE 256 DUP(0)

fmtStr_second BYTE "second: %d", 0
outStr_second BYTE 256 DUP(0)



.CODE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility function: print registers onto the screen
;;                   this is a bad way to debug
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintRegs PROC USES eax ebx ecx edx
        ;; save original values since wsprintf / DrawStr mess with them
        push edx
        push ecx
        push ebx
        push eax

        ;; print eax
        pop eax
        push eax
        push OFFSET fmtStr_eax
        push OFFSET outStr_eax
        call wsprintf
        add esp, 12
        INVOKE DrawStr, offset outStr_eax, 10, 400, 0ffh


        ;; print ebx
        pop ebx
        push ebx
        push OFFSET fmtStr_ebx
        push OFFSET outStr_ebx
        call wsprintf
        add esp, 12
        INVOKE DrawStr, offset outStr_ebx, 10, 410, 0ffh


        ;; print ecx
        pop ecx
        push ecx
        push OFFSET fmtStr_ecx
        push OFFSET outStr_ecx
        call wsprintf
        add esp, 12
        INVOKE DrawStr, offset outStr_ecx, 10, 420, 0ffh

        ;; print edx
        pop edx
        push edx
        push OFFSET fmtStr_edx
        push OFFSET outStr_edx
        call wsprintf
        add esp, 12
        INVOKE DrawStr, offset outStr_edx, 10, 430, 0ffh

        ret
PrintRegs ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility function: print two values onto the screen
;;                   this is also a bad way to debug
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintTwoVals PROC first:DWORD, second:DWORD
        ;; print first val
        push first
        push OFFSET fmtStr_first
        push OFFSET outStr_first
        call wsprintf
        add esp, 12
        INVOKE DrawStr, offset outStr_first, 150, 400, 0ffh

        ;; print second val 
        push second
        push OFFSET fmtStr_second
        push OFFSET outStr_second
        call wsprintf
        add esp, 12
        INVOKE DrawStr, offset outStr_second, 150, 410, 0ffh

        ret
PrintTwoVals ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility function: clear the entire screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearEntireScreen PROC USES edi eax
        ;; Find end of screen
        LOCAL ScreenEndPtr:DWORD
        mov eax, ScreenBitsPtr
        add eax, 307199  ; Screen is 640 * 480 = 307200 px
        mov ScreenEndPtr, eax

        ;; Initailize loop
        mov edi, ScreenBitsPtr
        xor eax, eax

        ;; for (i = ScreenBitsPtr; i < ScreenEnd; i++) 
        ;;     Screen[i] <- black pixel

    ClearEntireScreen_loop:
        mov (BYTE PTR [edi]), al
        inc edi

        ;; if (edi < ScreenEndPtr) loop again
        cmp edi, ScreenEndPtr
        jl ClearEntireScreen_loop

        ret
ClearEntireScreen ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility function: clear the right part of the screen,
;;                   beyond 432 pixels. Keep the rest of
;;                   the screen untouched.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearRightScreen PROC USES edi eax
        ;; Find end of row, end of screen
        ;; Screen is 640 x 480 px wide
        LOCAL RowEndPtr:DWORD, ScreenEndPtr:DWORD

        ;; Point to last pixel in row
        mov eax, ScreenBitsPtr
        add eax, 639
        mov RowEndPtr, eax

        ;; Points to last pixel of the screen
        mov eax, ScreenBitsPtr
        add eax, 307199  ; 640 * 480 = 307200 px
        mov ScreenEndPtr, eax

        ;; Initailize loop
        mov edi, ScreenBitsPtr
        add edi, 432

        ;; Black pixel
        xor eax, eax

    ClearRightScreen_loop:
        mov (BYTE PTR [edi]), al
        inc edi

        ;; If end of screen, exit
        cmp edi, ScreenEndPtr
        jnl ClearRightScreen_end

        ;; If at end of row, incremement RowEndPtr and jump to col 432
        ;; of the next row -- otherwise, loop again
        cmp edi, RowEndPtr
        jne ClearRightScreen_loop

        ;; Set RowEndPtr to end of next row
        add RowEndPtr, 640

        ;; Move to row 432 of next row
        add edi, 432

        ;; Loop again for next row
        jmp ClearRightScreen_loop

    ClearRightScreen_end:

        ret
ClearRightScreen ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Collision detection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckIntersect PROC USES ebx ecx edx edi oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Pseudocode
    ;; Remember that (oneX, oneY) and (twoX, twoY) represent centers
    ;;
    ;; Compute these:
    ;; oneLeft = oneX - oneBitmap.dwWidth / 2
    ;; oneRight = oneX + oneBitmap.dwWidth / 2 = oneLeft + oneBitmap.dwWidth
    ;; oneTop = oneY - oneBitmap.dwHeight / 2
    ;; oneBottom = oneY + oneBitmap.dwHeight / 2 = oneTop + oneBitmap.dwHeight
    ;;
    ;; Likewise for twoLeft, twoRight, twoTop, twoBottom
    ;;
    ;; if (oneLeft > twoRight) return 0
    ;; if (oneRight < twoLeft) return 0
    ;; if (oneTop > twoBottom) return 0
    ;; if (oneBottom < twoTop) return 0
    ;; else return true
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        LOCAL oneLeft:DWORD, oneRight:DWORD, oneTop:DWORD, oneBottom:DWORD
        LOCAL twoLeft:DWORD, twoRight:DWORD, twoTop:DWORD, twoBottom:DWORD

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Compute bounding box for first bitmap
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov edi, oneBitmap
        
        ;; oneLeft = oneX - oneBitmap.dwWidth / 2
        mov ecx, (EECS205BITMAP PTR [edi]).dwWidth
        sar ecx, 1
        mov edx, oneX
        sub edx, ecx
        mov oneLeft, edx

        ;; oneRight = oneLeft + oneBitmap.dwWidth
        sal ecx, 1  ; ecx <- dwWidth (ecx had dwWidth / 2)
        add edx, ecx
        mov oneRight, edx

        ;; oneTop = oneY - oneBitmap.dwHeight / 2
        mov ecx, (EECS205BITMAP PTR [edi]).dwHeight
        sar ecx, 1
        mov edx, oneY
        sub edx, ecx
        mov oneTop, edx

        ;; oneBottom = oneTop + oneBitmap.dwHeight
        sal ecx, 1  ; ecx <- dwHeight (ecx had dwHeight / 2)
        add edx, ecx
        mov oneBottom, edx

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Compute bounding box for second bitmap
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov edi, twoBitmap

        ;; twoLeft = twoX - twoBitmap.dwWidth / 2
        mov ecx, (EECS205BITMAP PTR [edi]).dwWidth
        sar ecx, 1
        mov edx, twoX
        sub edx, ecx
        mov twoLeft, edx

        ;; twoRight = twoLeft + twoBitmap.dwWidth
        sal ecx, 1  ; ecx <- dwWidth (ecx had dwWidth / 2)
        add edx, ecx
        mov twoRight, edx

        ;; twoTop = twoY - twoBitmap.dwHeight / 2
        mov ecx, (EECS205BITMAP PTR [edi]).dwHeight
        sar ecx, 1
        mov edx, twoY
        sub edx, ecx
        mov twoTop, edx

        ;; twoBottom = twoTop + twoBitmap.dwHeight
        sal ecx, 1  ; ecx <- dwHeight (ecx had dwHeight / 2)
        add edx, ecx
        mov twoBottom, edx

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Compare bounding boxes
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; if (oneRight < twoLeft) return 0
        ;; one is entirely to the left of two
        mov ebx, oneRight
        cmp ebx, twoLeft
        jl CheckIntersect_no_overlap

        ;; if (oneLeft > twoRight) return 0
        ;; one is entirely to the right of two
        mov ebx, oneLeft
        cmp ebx, twoRight
        jg CheckIntersect_no_overlap

        ;; if (oneBottom < twoTop) return 0
        ;; one is entirely above two
        mov ebx, oneBottom
        cmp ebx, twoTop
        jl CheckIntersect_no_overlap

        ;; if (oneTop > twoBottom) return 0
        ;; one is entirely below two
        mov ebx, oneTop
        cmp ebx, twoBottom
        jg CheckIntersect_no_overlap

        ;; else, they overlap
        mov eax, 1
        ret

    ;; reached when they do not overlap
    CheckIntersect_no_overlap:
        mov eax, 0
        ret

CheckIntersect ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Collision detection for two sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckIntersectSprite PROC one:SPRITE, two:SPRITE
    
    LOCAL oneXD:DWORD, oneYD:DWORD, twoXD:DWORD, twoYD:DWORD
    
    ;; Get sprite positions and convert from fixed point
    mov eax, one.posX
    mov oneXD, eax

    mov eax, one.posY
    mov oneYD, eax

    mov eax, two.posX
    mov twoXD, eax

    mov eax, two.posY
    mov twoYD, eax

    ;; Call the normal CheckIntersect
    INVOKE CheckIntersect, oneXD, oneYD, one.bitmap, twoXD, twoYD, two.bitmap

    ;; Result is already in eax
    ret
CheckIntersectSprite ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Collision detection for mouse and sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckIntersectMouse PROC USES ebx ecx edx edi one:SPRITE

        LOCAL oneXD:DWORD, oneYD:DWORD
        LOCAL oneLeft:DWORD, oneRight:DWORD, oneTop:DWORD, oneBottom:DWORD
        
        ;; Get sprite positions and convert from fixed point
        mov eax, one.posX
        mov oneXD, eax

        mov eax, one.posY
        mov oneYD, eax

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Compute bounding box for sprite
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov edi, one.bitmap
        
        ;; oneLeft = one.X - one.bitmap.dwWidth / 2
        mov ecx, (EECS205BITMAP PTR [edi]).dwWidth
        sar ecx, 1
        mov edx, oneXD
        sub edx, ecx
        mov oneLeft, edx

        ;; oneRight = oneLeft + oneBitmap.dwWidth
        sal ecx, 1  ; ecx <- dwWidth (ecx had dwWidth / 2)
        add edx, ecx
        mov oneRight, edx

        ;; oneTop = one.Y - one.bitmap.dwHeight / 2
        mov ecx, (EECS205BITMAP PTR [edi]).dwHeight
        sar ecx, 1
        mov edx, oneYD
        sub edx, ecx
        mov oneTop, edx

        ;; oneBottom = oneTop + oneBitmap.dwHeight
        sal ecx, 1  ; ecx <- dwHeight (ecx had dwHeight / 2)
        add edx, ecx
        mov oneBottom, edx

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Check if mouse is in bounding box
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; if (MouseStatus.horiz > oneRight) return 0
        mov eax, MouseStatus.horiz
        cmp eax, oneRight
        jg CheckIntersectMouse_no_overlap

        ;; if (MouseStatus.horiz < oneLeft) return 0
        mov eax, MouseStatus.horiz
        cmp eax, oneLeft
        jl CheckIntersectMouse_no_overlap

        ;; if (MouseStatus.vert > oneBottom) return 0
        mov eax, MouseStatus.vert
        cmp eax, oneBottom
        jg CheckIntersectMouse_no_overlap

        ;; if (MouseStatus.vert < oneTop) return 0
        mov eax, MouseStatus.vert
        cmp eax, oneTop
        jl CheckIntersectMouse_no_overlap

        ;; else, they overlap
        mov eax, 1
        ret

    CheckIntersectMouse_no_overlap:
        ;; no overlap, return 0
        mov eax, 0
        ret

CheckIntersectMouse ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render sprites on the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RenderSprite PROC USES ebx ecx sprite:SPRITE

    ;; Sprite positions are in grid coordinates
    INVOKE GridToDWORD, sprite.posX
    mov ecx, eax

    INVOKE GridToDWORD, sprite.posY
    mov edx, eax

    invoke BasicBlit, sprite.bitmap, ecx, edx

    ret
RenderSprite ENDP


GameInit PROC
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Assorted things
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Seed random numbers
        ;; {edx, eax} <- internal cycle counter -- works as seed
        rdtsc
        invoke nseed, eax

        ;; Initialize attack sprite, set as inactive
        mov currAttack.bitmap, OFFSET ATTK1
        mov currAttack.active, 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize level
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov level.bitmap, OFFSET MAP1
        mov level.info, OFFSET MAPINFO1

        mov level.sizeX, 26
        mov level.sizeY, 26

        mov level.offsetX, 0
        mov level.offsetY, 0

        ;; Do things?

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize items
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize player
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Set position
        mov player.posX, 7
        mov player.posY, 7

        ;; Set level info so player's square is marked as occupied
        INVOKE LevelInfoSetBit, player.posX, player.posY, level, 1

        ;; Set sprite and direction
        mov player.bitmap, OFFSET PKMN2_LEFT
        mov player.direction, 2

        ;; Set all sprites
        mov player.bitmap_up, OFFSET PKMN2_UP
        mov player.bitmap_down, OFFSET PKMN2_DOWN
        mov player.bitmap_left, OFFSET PKMN2_LEFT
        mov player.bitmap_right, OFFSET PKMN2_RIGHT

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize enemies
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
        ret
GameInit ENDP


GamePlay PROC
        ;; Clear screen
        INVOKE ClearEntireScreen

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render background
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        INVOKE RenderLevel, level

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render active items
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render sprites
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
        ;; Render enemies


        ;; Render player
        INVOKE RenderSprite, player

        ;; Only render attack if active
        cmp currAttack.active, 1
        jne GamePlay_no_render_attack
        
        INVOKE RenderSprite, currAttack

    GamePlay_no_render_attack:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Move player -- arrow key controls
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov eax, KeyPress

        ;; Check if up arrow was pressed
        cmp eax, VK_UP
        jne GamePlay_not_up

        ;; Face up
        mov eax, player.bitmap_up
        mov player.bitmap, eax
        mov player.direction, 0

        ;; Check if player can actually move up
        ;;
        ;; These coords are relative to the screen, not level
        ;; Because the player is at screen(posX, posY), and
        ;; screen(0, 0) ~ bitmap(offsetX, offsetY),
        ;; screen(posX, posY) ~ bitmap(offsetX + posX, offsetY + posY)
        mov ebx, player.posX
        add ebx, level.offsetX

        mov ecx, player.posY
        add ecx, level.offsetY

        ;; The tile above the player has y-coord one smaller
        dec ecx

        ;; Calculate index into byte array of map info
        mov edi, level.bitmap
        mov eax, level.sizeX
        imul eax, ecx  ; eax <- level.sizeX * (player.posY - 1)
        add eax, ebx   ; eax <- index of pixel above player

        ;; Access byte of interest
        mov esi, level.info
        xor edx, edx
        mov dl, BYTE PTR [esi + eax]

        ;; Last bit is set if player can walk, clear if cannot
        test dl, 1
        jz GamePlay_not_up

        ;; Move player one space up
        dec level.offsetY

        ;; Modify level info array
        ;; New position (level.offsetX + player.posX, level.offsetY + player.posY)
        ;; so set the "occupied" bit to 1. Then clear the "occupied" bit of the
        ;; old square.
        mov eax, level.offsetX
        add eax, player.posX

        mov ebx, level.offsetY
        add ebx, player.posY

        INVOKE LevelInfoSetBit, eax, ebx, level, 1
        
        ;; Old position is one below current position
        inc ebx
        INVOKE LevelInfoClearBit, eax, ebx, level, 1

    GamePlay_not_up:
        ;; Check if down arrow was pressed
        cmp eax, VK_DOWN
        jne GamePlay_not_down

        ;; Face down
        mov eax, player.bitmap_down
        mov player.bitmap, eax
        mov player.direction, 1

        ;; Check if player can actually move down
        ;; See above section for explanation of this code
        mov ebx, player.posX
        add ebx, level.offsetX

        mov ecx, player.posY
        add ecx, level.offsetY

        ;; The tile below the player has y-coord one larger
        inc ecx

        ;; Calculate index into byte array of map info
        mov edi, level.bitmap
        mov eax, level.sizeX
        imul eax, ecx  ; eax <- level.sizeX * (player.posY + 1)
        add eax, ebx   ; eax <- index of pixel below player

        ;; Access byte of interest
        mov esi, level.info
        xor edx, edx
        mov dl, BYTE PTR [esi + eax]

        ;; Last bit is set if player can walk, clear if cannot
        test dl, 1
        jz GamePlay_not_down

        ;; Move player one space down
        inc level.offsetY

        ;; Modify level info array
        ;; New position (level.offsetX + player.posX, level.offsetY + player.posY)
        ;; so set the "occupied" bit to 1. Then clear the "occupied" bit of the
        ;; old square.
        mov eax, level.offsetX
        add eax, player.posX

        mov ebx, level.offsetY
        add ebx, player.posY

        INVOKE LevelInfoSetBit, eax, ebx, level, 1

        ;; Old position is one above current position
        dec ebx
        INVOKE LevelInfoClearBit, eax, ebx, level, 1


    GamePlay_not_down:
        ;; Check if left arrow was pressed
        cmp eax, VK_LEFT
        jne GamePlay_not_left

        ;; Face left
        mov eax, player.bitmap_left
        mov player.bitmap, eax
        mov player.direction, 2

        ;; Check if player can actually move left
        ;; See above section for explanation of this code
        mov ebx, player.posX
        add ebx, level.offsetX

        mov ecx, player.posY
        add ecx, level.offsetY

        ;; The tile to the left of the player has x-coord one smaller
        dec ebx

        ;; Calculate index into byte array of map info
        mov edi, level.bitmap
        mov eax, level.sizeX
        imul eax, ecx  ; eax <- level.sizeX * (player.posY)
        add eax, ebx   ; eax <- index of pixel left of player

        ;; Access byte of interest
        mov esi, level.info
        xor edx, edx
        mov dl, BYTE PTR [esi + eax]

        ;; Last bit is set if player can walk, clear if cannot
        test dl, 1
        jz GamePlay_not_left

        ;; Move player one space left
        dec level.offsetX

        ;; Modify level info array
        ;; New position (level.offsetX + player.posX, level.offsetY + player.posY)
        ;; so set the "occupied" bit to 1. Then clear the "occupied" bit of the
        ;; old square.
        mov eax, level.offsetX
        add eax, player.posX

        mov ebx, level.offsetY
        add ebx, player.posY

        INVOKE LevelInfoSetBit, eax, ebx, level, 1

        ;; Old position is one right of new position
        inc eax
        INVOKE LevelInfoClearBit, eax, ebx, level, 1


    GamePlay_not_left:
        ;; Check if right arrow was pressed
        cmp eax, VK_RIGHT
        jne GamePlay_not_right

        ;; Face right
        mov eax, player.bitmap_right
        mov player.bitmap, eax
        mov player.direction, 3

        ;; Check if player can actually move right
        ;; See above section for explanation of this code
        mov ebx, player.posX
        add ebx, level.offsetX

        mov ecx, player.posY
        add ecx, level.offsetY

        ;; The tile below the player has x-coord one larger
        inc ebx

        ;; Calculate index into byte array of map info
        mov edi, level.bitmap
        mov eax, level.sizeX
        imul eax, ecx  ; eax <- level.sizeX * (player.posY)
        add eax, ebx   ; eax <- index of pixel right of player

        ;; Access byte of interest
        mov esi, level.info
        xor edx, edx
        mov dl, BYTE PTR [esi + eax]

        ;; Last bit is set if player can walk, clear if cannot
        test dl, 1
        jz GamePlay_not_right

        ;; Move player one space right
        inc level.offsetX

        ;; Modify level info array 
        ;; New position (level.offsetX + player.posX, level.offsetY + player.posY)
        ;; so set the "occupied" bit to 1. Then clear the "occupied" bit of the
        ;; old square.
        mov eax, level.offsetX
        add eax, player.posX

        mov ebx, level.offsetY
        add ebx, player.posY

        INVOKE LevelInfoSetBit, eax, ebx, level, 1

        ;; Old position is one left of new position
        dec eax
        INVOKE LevelInfoClearBit, eax, ebx, level, 1

    GamePlay_not_right:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Attack -- spacebar control
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp eax, VK_SPACE
        jne GamePlay_not_space

        ;; Initialize attack sprite
        mov currAttack.bitmap, OFFSET ATTK1
        mov currAttack.active, 1

        ;; Set attack position to current player
        mov eax, player.posX
        mov currAttack.posX, eax

        mov eax, player.posY
        mov currAttack.posY, eax

        ;; Initialize attack velocity (this will be in some direction) 
        mov ebx, 1
        sal ebx, 16

        ;; Set attack velocity in direction of current player
        ;; Direction is 0 (up), 1 (down), 2 (left), 3 (right)
        mov eax, player.direction
        cmp eax, 0
        jne GamePlay_attack_not_up

        neg ebx
        mov currAttack.velX, 0
        mov currAttack.velY, ebx

    GamePlay_attack_not_up:
        cmp eax, 1
        jne GamePlay_attack_not_down

        mov currAttack.velX, 0
        mov currAttack.velY, ebx

    GamePlay_attack_not_down:
        cmp eax, 2
        jne GamePlay_attack_not_left

        neg ebx
        mov currAttack.velX, ebx
        mov currAttack.velY, 0

    GamePlay_attack_not_left:
        cmp eax, 3
        jne GamePlay_not_space

        mov currAttack.velX, ebx
        mov currAttack.velY, 0

    GamePlay_not_space:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Collision detection
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Update sprites
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; Update currAttack position, if active
        cmp currAttack.active, 1
        jne GamePlay_attack_not_active

        ;; Add velocity to position
        mov eax, currAttack.velX
        add currAttack.posX, eax

        mov eax, currAttack.velY
        add currAttack.posY, eax

    GamePlay_attack_not_active:


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Display messages
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        INVOKE ClearRightScreen
        INVOKE DrawLine, 432, 0, 432, 480, 0ffh

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Debug
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;INVOKE PrintTwoVals, MouseStatus.horiz, MouseStatus.vert


	ret
GamePlay ENDP

END