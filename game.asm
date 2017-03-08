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

;; Sprites
player SPRITE< >
enemies SPRITE 15 DUP(<>)
currAttack SPRITE< >

level LEVEL< >

;; Cooldowns
PLAYER_COOLDOWN DWORD 1
WANDERING_ENEMY_COOLDOWN DWORD 2
TARGETED_ENEMY_COOLDOWN DWORD 3

;; Status
GamePaused DWORD 0


;; Messages
str_pause BYTE "GAME PAUSED", 0
str_dungeon BYTE "Cave of the Moon", 0

fmtStr_player_health BYTE "Player health: %d/10", 0
outStr_player_health BYTE 256 DUP(0)

SCORE DWORD 0
fmtStr_score BYTE "Score: %d", 0
outStr_score BYTE 256 DUP(0)

EnemyHealth DWORD 10
fmtStr_enemy_health BYTE "Enemy health: %d/10", 0
outStr_enemy_health BYTE 256 DUP(0)

str_arrows BYTE "ARROWS: move", 0
str_space BYTE "SPACE: attack", 0
str_p BYTE "P: pause", 0


;; Strings for PrintRegs
fmtStr_eax BYTE "eax: %d", 0
outStr_eax BYTE 256 DUP(0)

fmtStr_ebx BYTE "ebx: %d", 0
outStr_ebx BYTE 256 DUP(0)

fmtStr_ecx BYTE "ecx: %d", 0
outStr_ecx BYTE 256 DUP(0)

fmtStr_edx BYTE "edx: %d", 0
outStr_edx BYTE 256 DUP(0)

;; Strings for PrintTwoVals
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
        INVOKE DrawStr, OFFSET outStr_eax, 10, 400, 0ffh


        ;; print ebx
        pop ebx
        push ebx
        push OFFSET fmtStr_ebx
        push OFFSET outStr_ebx
        call wsprintf
        add esp, 12
        INVOKE DrawStr, OFFSET outStr_ebx, 10, 410, 0ffh


        ;; print ecx
        pop ecx
        push ecx
        push OFFSET fmtStr_ecx
        push OFFSET outStr_ecx
        call wsprintf
        add esp, 12
        INVOKE DrawStr, OFFSET outStr_ecx, 10, 420, 0ffh

        ;; print edx
        pop edx
        push edx
        push OFFSET fmtStr_edx
        push OFFSET outStr_edx
        call wsprintf
        add esp, 12
        INVOKE DrawStr, OFFSET outStr_edx, 10, 430, 0ffh

        ret
PrintRegs ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility function: print two values onto the screen
;;                   this is also a bad way to debug
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintTwoVals PROC USES eax ebx ecx edx first:DWORD, second:DWORD
        ;; print first val
        push first
        push OFFSET fmtStr_first
        push OFFSET outStr_first
        call wsprintf
        add esp, 12
        INVOKE DrawStr, OFFSET outStr_first, 150, 400, 0ffh

        ;; print second val 
        push second
        push OFFSET fmtStr_second
        push OFFSET outStr_second
        call wsprintf
        add esp, 12
        INVOKE DrawStr, OFFSET outStr_second, 150, 410, 0ffh

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
    
    ;; Get sprite positions and convert to DWORD
    mov eax, one.posX
    INVOKE GridToDWORD, eax
    mov oneXD, eax

    mov eax, one.posY
    INVOKE GridToDWORD, eax
    mov oneYD, eax

    mov eax, two.posX
    INVOKE GridToDWORD, eax
    mov twoXD, eax

    mov eax, two.posY
    INVOKE GridToDWORD, eax
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

RenderSprite PROC USES ecx edx sprite:SPRITE

    ;; Sprite positions are in grid coordinates
    INVOKE GridToDWORD, sprite.posX
    mov ecx, eax

    INVOKE GridToDWORD, sprite.posY
    mov edx, eax

    invoke BasicBlit, sprite.bitmap, ecx, edx

    ret
RenderSprite ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render sprites on screen, relative to a map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RenderSpriteOnLevel PROC USES ebx ecx edx sprite:SPRITE, currLevel:LEVEL

    ;; Sprite positions are in grid coordinates relative to level.
    ;; Subtract off level offset to convert to screen coordinates,
    ;; then convert to DWORD for rendering
    mov eax, sprite.posX
    sub eax, currLevel.offsetX
    INVOKE GridToDWORD, eax
    mov ecx, eax

    mov eax, sprite.posY
    sub eax, currLevel.offsetY
    INVOKE GridToDWORD, eax
    mov edx, eax

    invoke BasicBlit, sprite.bitmap, ecx, edx

    ret
RenderSpriteOnLevel ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate random enemy at random valid position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GenerateEnemy PROC USES ebx ecx sprite:PTR SPRITE, currLevel:LEVEL
    LOCAL tempX:DWORD, tempY:DWORD

    ;; We need a position that has the 0th bit set (so that it is
    ;; a walkable square) and the 1st bit clear (so that it is not
    ;; occupied).
    ;;
    ;; While we don't have a valid position, generate a new one

    GenerateEnemy_position_gen:

        INVOKE nrandom, currLevel.sizeX
        mov tempX, eax

        INVOKE nrandom, currLevel.sizeY
        mov tempY, eax

        ;; If 0th bit clear, not walkable; try again
        INVOKE LevelInfoTestBit, tempX, tempY, currLevel, 0
        jz GenerateEnemy_position_gen

        ;; If 1st bit set, it's occupied; try again
        INVOKE LevelInfoTestBit, tempX, tempY, currLevel, 1
        jnz GenerateEnemy_position_gen

        ;; Reaching here means we have a valid position
        mov ebx, sprite

        ;; Set sprite position
        mov eax, tempX
        mov (SPRITE PTR [ebx]).posX, eax

        mov eax, tempY
        mov (SPRITE PTR [ebx]).posY, eax

        ;; Set bit 1 in currLevel.info
        INVOKE LevelInfoSetBit, tempX, tempY, currLevel, 1

        ;; Select sprite
        push ebx
        
        INVOKE nrandom, 2
        cmp eax, 1
        jz GenerateEnemy_sprite_zero

        ;; Generated number 1 -- put PKMN 2
        mov (SPRITE PTR [ebx]).bitmap_up, OFFSET PKMN2_UP
        mov (SPRITE PTR [ebx]).bitmap_down, OFFSET PKMN2_DOWN
        mov (SPRITE PTR [ebx]).bitmap_left, OFFSET PKMN2_LEFT
        mov (SPRITE PTR [ebx]).bitmap_right, OFFSET PKMN2_RIGHT

        mov (SPRITE PTR [ebx]).bitmap, OFFSET PKMN2_DOWN
        mov (SPRITE PTR [ebx]).direction, 1

        jmp GenerateEnemy_done

    GenerateEnemy_sprite_zero:
        ;; Generated number 0 -- put PKMN 1
        mov (SPRITE PTR [ebx]).bitmap_up, OFFSET PKMN1_UP
        mov (SPRITE PTR [ebx]).bitmap_down, OFFSET PKMN1_DOWN
        mov (SPRITE PTR [ebx]).bitmap_left, OFFSET PKMN1_LEFT
        mov (SPRITE PTR [ebx]).bitmap_right, OFFSET PKMN1_RIGHT

        mov (SPRITE PTR [ebx]).bitmap, OFFSET PKMN1_DOWN
        mov (SPRITE PTR [ebx]).direction, 1


    GenerateEnemy_done:

        ret

GenerateEnemy ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Absolute value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AbsVal PROC x:DWORD
        ;; Compute absolute value of x
        mov eax, x
        cmp eax, 0
        jg AbsVal_done
    
        ;; If here, eax < 0
        neg eax

    AbsVal_done:
        ret

AbsVal ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprite distance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteDistance PROC USES edi esi ebx sprite1:PTR SPRITE, sprite2:PTR SPRITE

    ;; Compute squared distance between two sprites
    ;; (sprite2.posX - sprite1.posX)^2 + (sprite2.posY - sprite1.posY)^2

    mov esi, sprite2
    mov edi, sprite1

    ;; eax = sprite2.posX - sprite1.posX
    mov eax, (SPRITE PTR [esi]).posX
    sub eax, (SPRITE PTR [edi]).posX
    imul eax  ; square it
    mov ebx, eax  ; ebx = deltaX^2

    ;; eax = sprite2.posY - sprite1.posY    
    mov eax, (SPRITE PTR [esi]).posY
    sub eax, (SPRITE PTR [edi]).posY
    imul eax  ; square it

    add eax, ebx  ; eax = deltaY^2 + deltaX^2

    ret

SpriteDistance ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Get bearing (direction to move) from sprite1 -> sprite2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetBearing PROC USES edi esi ebx ecx edx sprite1:PTR SPRITE, sprite2:PTR SPRITE
        
        ;; Figure out the direction that sprite1 needs to move
        ;; to get to sprite2. Return number, according to the
        ;; same directions convention we've been using.
        ;; 
        ;; Directions: 0 (up), 1 (down), 2 (left), 3 (right)

        mov esi, sprite2
        mov edi, sprite1

        ;; compute differences in positions
        ;; ebx = sprite2.posX - sprite1.posX
        mov ebx, (SPRITE PTR [esi]).posX
        sub ebx, (SPRITE PTR [edi]).posX

        ;; ecx = sprite2.posY - sprite1.posY
        mov ecx, (SPRITE PTR [esi]).posY
        sub ecx, (SPRITE PTR [edi]).posY

        ;; Figure out if primary motion is left/right or up/down
        INVOKE AbsVal, ebx
        mov edx, eax

        INVOKE AbsVal, ecx

        ;; edx = abs(sprite2.posX - sprite1.posX)
        ;; eax = abs(sprite2.posY - sprite1.posY)

        cmp edx, eax
        jg GetBearing_x_larger

        ;; If here, primary motion is in up/down direction
        ;; Figure out up or down by checking sign of deltaY (ecx)
        cmp ecx, 0
        jl GetBearing_move_up

        ;; If here, ecx > 0, so sprite2.posY > sprite1.posY,
        ;; so sprite2 is below sprite1, so move down.
        mov eax, 1
        ret

    GetBearing_move_up:
        ;; If here, ecx < 0, so sprite2.posY < sprite1.posY,
        ;; so sprite2 is above sprite1, so move up
        mov eax, 0
        ret

    GetBearing_x_larger:
        ;; If here, primary motion is in left/right direction
        ;; Figure out left or right by checking sign of deltaX (ebx)

        cmp ebx, 0
        jl GetBearing_move_left

        ;; If here, ebx > 0, so sprite2.posX > sprite1.posX,
        ;; so sprite2 is right of sprite1, so move right.
        mov eax, 3
        ret

    GetBearing_move_left:
        ;; If here, ebx < 0, so sprite2.posX < sprite1.posX,
        ;; so sprite2 is left of sprite1, so move left.
        mov eax, 2
        ret

    ;; You should never reach this point, but just in case, return 0
    mov eax, 0
    ret

GetBearing ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Try to move a sprite in given direction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TryToMove PROC USES ebx ecx edi sprite:PTR SPRITE, currLevel:LEVEL, direction:DWORD, cooldown:DWORD

        ;; Try to move the sprite one square in the particular direction.
        ;; Check the destination to be walkable and empty, and move there
        ;; if possible. If move successful, reset cooldown to provided val
        ;; 
        ;; Directions: 0 (up), 1 (down), 2 (left), 3 (right)
        ;;
        ;; Return: 1 if successful, 0 otherwise

        mov edi, sprite

        ;; First, check if we're able to walk
        cmp (SPRITE PTR [edi]).move_cooldown, 0
        je TryToMove_no_cooldown

        ;; If here, we're on cooldown -- decrement cooldown and give up
        dec (SPRITE PTR [edi]).move_cooldown
        mov eax, 0
        ret

    TryToMove_no_cooldown:
        ;; Actually try to move, now

        mov ebx, (SPRITE PTR [edi]).posX
        mov ecx, (SPRITE PTR [edi]).posY

        ;; Check which direction we're trying to move in
        cmp direction, 0
        jne TryToMove_dir1

        ;; Trying to move up -- y-coord one smaller, face up
        dec ecx

        mov (SPRITE PTR [edi]).direction, 0
        mov eax, (SPRITE PTR [edi]).bitmap_up
        mov (SPRITE PTR [edi]).bitmap, eax

        jmp TryToMove_chosen_dir

    TryToMove_dir1:

        cmp direction, 1
        jne TryToMove_dir2

        ;; Trying to move down -- y-coord one larger, face down
        inc ecx

        mov (SPRITE PTR [edi]).direction, 1
        mov eax, (SPRITE PTR [edi]).bitmap_down
        mov (SPRITE PTR [edi]).bitmap, eax

        jmp TryToMove_chosen_dir

    TryToMove_dir2:

        cmp direction, 2
        jne TryToMove_dir3

        ;; Trying to move left -- x-coord one smaller
        dec ebx

        mov (SPRITE PTR [edi]).direction, 2
        mov eax, (SPRITE PTR [edi]).bitmap_left
        mov (SPRITE PTR [edi]).bitmap, eax

        jmp TryToMove_chosen_dir

    TryToMove_dir3:

        ;; Trying to move right -- x-coord one larger
        inc ebx

        mov (SPRITE PTR [edi]).direction, 3
        mov eax, (SPRITE PTR [edi]).bitmap_right
        mov (SPRITE PTR [edi]).bitmap, eax

    TryToMove_chosen_dir:

        ;; Check destination walkable
        INVOKE LevelInfoTestBit, ebx, ecx, level, 0
        jz TryToMove_done  ; if 0, not walkable

        ;; Check destination empty
        INVOKE LevelInfoTestBit, ebx, ecx, level, 1
        jnz TryToMove_done  ; if 1, occupied and can't move

        ;; Now, we know we can move.

        ;; Reset movement cooldown
        mov eax, cooldown
        mov (SPRITE PTR [edi]).move_cooldown, eax

        ;; Clear the old location
        INVOKE LevelInfoClearBit, (SPRITE PTR [edi]).posX, (SPRITE PTR [edi]).posY, level, 1

        ;; Move the sprite
        mov (SPRITE PTR [edi]).posX, ebx
        mov (SPRITE PTR [edi]).posY, ecx

        ;; Set the new location
        INVOKE LevelInfoSetBit, (SPRITE PTR [edi]).posX, (SPRITE PTR [edi]).posY, level, 1
        
        mov eax, 1
        ret

    TryToMove_done:

        ;; Not successful in moving
        mov eax, 0
        ret

TryToMove ENDP

GameInit PROC
    ;; Locals for temporary storage
    LOCAL tempX:DWORD, tempY:DWORD

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

        mov level.sizeX, 46
        mov level.sizeY, 46

        mov level.offsetX, 0
        mov level.offsetY, 6

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize player
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Set position
        mov player.posX, 7
        mov player.posY, 16

        ;; Set level info so player's square is marked as occupied
        INVOKE LevelInfoSetBit, player.posX, player.posY, level, 1

        ;; Set sprite and direction
        mov player.bitmap, OFFSET PKMN3_RIGHT
        mov player.direction, 3

        ;; Set all sprites
        mov player.bitmap_up, OFFSET PKMN3_UP
        mov player.bitmap_down, OFFSET PKMN3_DOWN
        mov player.bitmap_left, OFFSET PKMN3_LEFT
        mov player.bitmap_right, OFFSET PKMN3_RIGHT

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize enemies
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; Generate and set positions
        
        xor ecx, ecx
        mov ebx, OFFSET enemies

    GameInit_enemy_position::
        ;; push these so they don't get overwritten by 
        push ebx
        push ecx

        add ebx, ecx
        INVOKE GenerateEnemy, ebx, level

        pop ecx
        pop ebx

        ;; Move to next enemy if we're not done
        add ecx, TYPE SPRITE
        cmp ecx, SIZEOF enemies

        jl GameInit_enemy_position

        ret
GameInit ENDP


GamePlay PROC

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Check pause
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; We want pause if the last key pressed was P. From pause, player
        ;; can exit with any other key (except P again).
        mov eax, KeyDown

        ;; If P was last key pressed AND not paused, then pause.
        cmp eax, VK_P
        jne GamePlay_main

        cmp GamePaused, 0
        je GamePlay_paused

        ;; If here, P is pressed and we are paused, so unpause and move on
        mov GamePaused, 0
        jmp GamePlay_main


    GamePlay_paused:
        ;; Render paused message
        INVOKE DrawStr, OFFSET str_pause, 450, 300, 0ffh

        ;; And don't do anything else (update game objects, etc.)
        jmp GamePlay_end

    GamePlay_main:
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Clear screen; render level
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        INVOKE ClearEntireScreen
        INVOKE RenderLevel, level

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render enemies
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
        xor ecx, ecx
        mov ebx, OFFSET enemies
    
    GamePlay_render_enemies:

        ;; Only render active enemies
        cmp (SPRITE PTR [ebx + ecx]).active, 1
        jne GamePlay_no_render_enemy

        INVOKE RenderSpriteOnLevel, (SPRITE PTR [ebx + ecx]), level

    GamePlay_no_render_enemy:

        add ecx, TYPE SPRITE
        cmp ecx, SIZEOF enemies

        jl GamePlay_render_enemies

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render other sprites (player, attack)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
        INVOKE RenderSpriteOnLevel, player, level

        ;; Only render attack if active
        cmp currAttack.active, 1
        jne GamePlay_no_render_attack
        
        INVOKE RenderSpriteOnLevel, currAttack, level

    GamePlay_no_render_attack:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Move player -- arrow key controls
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov eax, KeyPress

        ;; Check if up arrow was pressed
        cmp eax, VK_UP
        jne GamePlay_not_up

        INVOKE TryToMove, OFFSET player, level, 0, PLAYER_COOLDOWN

        ;; This is bad, but TryToMove returns 1 if we moved, 0 otherwise
        ;; so we can just add the result to offsetY, since we only want
        ;; to update it if we moved successfully.
        sub level.offsetY, eax

    GamePlay_not_up:
        ;; Check if down arrow was pressed
        cmp eax, VK_DOWN
        jne GamePlay_not_down

        INVOKE TryToMove, OFFSET player, level, 1, PLAYER_COOLDOWN
        add level.offsetY, eax

    GamePlay_not_down:
        ;; Check if left arrow was pressed
        cmp eax, VK_LEFT
        jne GamePlay_not_left

        INVOKE TryToMove, OFFSET player, level, 2, PLAYER_COOLDOWN
        sub level.offsetX, eax

    GamePlay_not_left:
        ;; Check if right arrow was pressed
        cmp eax, VK_RIGHT
        jne GamePlay_not_right

        INVOKE TryToMove, OFFSET player, level, 3, PLAYER_COOLDOWN
        add level.offsetX, eax

    GamePlay_not_right:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Move enemies randomly
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        xor ecx, ecx
        mov ebx, OFFSET enemies

    GamePlay_move_enemies:
        ;; Only move active enemies
        cmp (SPRITE PTR [ebx + ecx]).active, 1
        jne GamePlay_move_done

        ;; Determine if enemy will try to move this frame
        ;; values -- 0 = move up, 1 = down, 2 = left, 3 = right
        push ecx
        push ebx

        invoke nrandom, 60

        pop ebx
        pop ecx

        push eax  ; store result of nrandom

        ;; If close enough to player, move towards it
        mov eax, ebx
        add eax, ecx
        INVOKE SpriteDistance, eax, OFFSET player
        cmp eax, 10
        jg GamePlay_move_randomly

        ;; Decide direction to move from enemy to player
        mov edx, ebx
        add edx, ecx
        INVOKE GetBearing, edx, OFFSET player
        INVOKE TryToMove, edx, level, eax, TARGETED_ENEMY_COOLDOWN

        pop eax  ; need to undo the push eax, even though we don't need this

        jmp GamePlay_move_done
    
    GamePlay_move_randomly:

        ;; restore result of nrandom
        pop eax

        cmp eax, 0  ; up
        jne GamePlay_no_enemy_move_up

        ;; Try moving up
        mov eax, ebx
        add eax, ecx
        INVOKE TryToMove, eax, level, 0, WANDERING_ENEMY_COOLDOWN

        jmp GamePlay_move_done

    GamePlay_no_enemy_move_up:
        cmp eax, 1  ; down
        jne GamePlay_no_enemy_move_down

        ;; Try moving down
        mov eax, ebx
        add eax, ecx
        INVOKE TryToMove, eax, level, 1, WANDERING_ENEMY_COOLDOWN

        jmp GamePlay_move_done

    GamePlay_no_enemy_move_down:
        cmp eax, 2  ; left
        jne GamePlay_no_enemy_move_left

        ;; Try moving left
        mov eax, ebx
        add eax, ecx
        INVOKE TryToMove, eax, level, 2, WANDERING_ENEMY_COOLDOWN

        jmp GamePlay_move_done

    GamePlay_no_enemy_move_left:

        cmp eax, 3
        jne GamePlay_move_done

        ;; Try moving right
        mov eax, ebx
        add eax, ecx
        INVOKE TryToMove, eax, level, 3, WANDERING_ENEMY_COOLDOWN


    GamePlay_move_done:
        ;; Fall through, done trying to move

        add ecx, TYPE SPRITE
        cmp ecx, SIZEOF enemies
        jl GamePlay_move_enemies

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Attack -- spacebar control
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mov eax, KeyPress
        cmp eax, VK_SPACE
        jne GamePlay_not_attack

        ;; Activate attack sprite
        mov currAttack.active, 1

        ;; Set attack position to current player
        mov eax, player.posX
        mov currAttack.posX, eax

        mov eax, player.posY
        mov currAttack.posY, eax

        ;; Initialize attack velocity; will be in some direction later
        mov ebx, 1

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
        jne GamePlay_not_attack

        mov currAttack.velX, ebx
        mov currAttack.velY, 0

    GamePlay_not_attack:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Collision detection
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; Check if attack active; if not don't do collision detection
        cmp currAttack.active, 1
        jne GamePlay_no_attack_collision_check

        ;; Check if attack hit a wall (is on a nonwalkable square)
        INVOKE LevelInfoTestBit, currAttack.posX, currAttack.posY, level, 0
        jnz GamePlay_attack_not_hit_wall  ; if not zero, square is not wall

        ;; Deactivate attack, since it is on a wall
        mov currAttack.active, 0
        jmp GamePlay_no_attack_collision_check

    GamePlay_attack_not_hit_wall:

        ;; Check if attack hit any enemies
        xor ecx, ecx
        mov ebx, OFFSET enemies

    GamePlay_enemy_collision_loop:
        ;; Check if enemy active; if not, don't do collision detection
        cmp (SPRITE PTR [ebx + ecx]).active, 1
        jne GamePlay_enemy_no_collision

        ;; Do the collision detection
        INVOKE CheckIntersectSprite, currAttack, (SPRITE PTR [ebx + ecx])
        cmp eax, 0
        jz GamePlay_enemy_no_collision

        ;; On collision behavior
        ;; Set EnemyHealth for rendering at end of frame
        dec (SPRITE PTR [ebx + ecx]).health
        mov eax, (SPRITE PTR [ebx + ecx]).health
        mov EnemyHealth, eax

        ;; Deactivate attack
        mov currAttack.active, 0

        ;; Check if enemy is dead
        cmp EnemyHealth, 0
        jg GamePlay_enemy_not_dead

        ;; Enemy is dead; deactivate sprite, clear its location
        mov (SPRITE PTR [ebx + ecx]).active, 0
        INVOKE LevelInfoClearBit, (SPRITE PTR [ebx + ecx]).posX, (SPRITE PTR [ebx + ecx]).posY, level, 1

    GamePlay_enemy_not_dead:


    GamePlay_enemy_no_collision:
        add ecx, TYPE SPRITE
        cmp ecx, SIZEOF enemies

        jl GamePlay_enemy_collision_loop


    GamePlay_no_attack_collision_check:

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

        ;; Clear right part of screen to make room, divide regions        
        INVOKE ClearRightScreen
        INVOKE DrawLine, 432, 0, 432, 480, 0ffh

        ;; Game name
        INVOKE DrawStr, OFFSET str_dungeon, 470, 26, 0ffh
        INVOKE DrawLine, 442, 60, 620, 60, 0ffh

        ;; Player health, score, enemy health
        push player.health
        push OFFSET fmtStr_player_health
        push OFFSET outStr_player_health
        call wsprintf
        add esp, 12
        INVOKE DrawStr, OFFSET outStr_player_health, 450, 80, 0ffh

        push SCORE
        push OFFSET fmtStr_score
        push OFFSET outStr_score
        call wsprintf
        add esp, 12
        INVOKE DrawStr, OFFSET outStr_score, 514, 95, 0ffh

        push EnemyHealth
        push OFFSET fmtStr_enemy_health
        push OFFSET outStr_enemy_health
        call wsprintf
        add esp, 12
        INVOKE DrawStr, OFFSET outStr_enemy_health, 458, 110, 0ffh

        INVOKE DrawLine, 442, 140, 620, 140, 0ffh

        ;; Treasures collected

        ;; Controls
        INVOKE DrawLine, 442, 350, 620, 350, 0ffh
        INVOKE DrawStr, OFFSET str_arrows, 472, 380, 0ffh
        INVOKE DrawStr, OFFSET str_space, 480, 395, 0ffh
        INVOKE DrawStr, OFFSET str_p, 512, 410, 0ffh
        

    GamePlay_end:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Debug
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;INVOKE PrintTwoVals, enemies.posX, enemies.posY


	ret
GamePlay ENDP

END