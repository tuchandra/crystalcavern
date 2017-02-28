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
level SPRITE< >

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
;; Utility function: clear the entire screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearScreen PROC USES edi eax
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

    ClearScreen_loop:
        mov (BYTE PTR [edi]), al
        inc edi

        ;; if (edi < ScreenEndPtr) loop again
        cmp edi, ScreenEndPtr
        jl ClearScreen_loop

        ret
ClearScreen ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility function: print registers onto the screen
;;                   this is a bad way to debug
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintRegs PROC USES eax ebx ecx edx
        ;; print eax
        push eax
        push OFFSET fmtStr_eax
        push OFFSET outStr_eax
        call wsprintf
        add esp, 12
        INVOKE DrawStr, offset outStr_eax, 10, 400, 0ffh

        ;; print ebx
        push ebx
        push OFFSET fmtStr_ebx
        push OFFSET outStr_ebx
        call wsprintf
        add esp, 12
        INVOKE DrawStr, offset outStr_ebx, 10, 410, 0ffh

        ;; print ecx
        push ecx
        push OFFSET fmtStr_ecx
        push OFFSET outStr_ecx
        call wsprintf
        add esp, 12
        INVOKE DrawStr, offset outStr_ecx, 10, 420, 0ffh

        ;; print edx
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
    sar oneXD, 16

    mov eax, one.posY
    mov oneYD, eax
    sar oneYD, 16

    mov eax, two.posX
    mov twoXD, eax
    sar twoXD, 16

    mov eax, two.posY
    mov twoYD, eax
    sar twoYD, 16

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
        sar eax, 16
        mov oneXD, eax

        mov eax, one.posY
        sar eax, 16
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
    ;; Coordinates are in fixed point
    mov ebx, sprite.posX
    sar ebx, 16

    mov ecx, sprite.posY
    sar ecx, 16

    ;; Render sprite
    invoke RotateBlit, sprite.bitmap, ebx, ecx, sprite.rotation

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
        ;; Level is 10 x 7 spaces
        mov level.bitmap, OFFSET LEVEL1

        INVOKE GridToFixed, 8
        mov level.posX, eax

        INVOKE GridToFixed, 8
        mov level.posY, eax

        ;; Do things?

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize items
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Set as active, set disappear time
        mov item1.bitmap, OFFSET BOX1
        mov item1.disappear, 150

        ;; Set position
        INVOKE nrandom, GRIDX
        INVOKE GridToFixed, eax
        mov item1.posX, eax

        INVOKE nrandom, GRIDY
        INVOKE GridToFixed, eax
        mov item1.posY, eax

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize player
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Set position
        ;INVOKE nrandom, GRIDX
        INVOKE GridToFixed, 8
        mov player.posX, eax

        ;INVOKE nrandom, GRIDY
        INVOKE GridToFixed, 8
        mov player.posY, eax

        ;; Set sprite and direction
        mov player.bitmap, OFFSET PKMN2_LEFT
        mov player.direction, 2

        ;; Set all sprites
        mov player.bitmap_up, OFFSET PKMN2_UP
        mov player.bitmap_down, OFFSET PKMN2_DOWN
        mov player.bitmap_left, OFFSET PKMN2_LEFT
        mov player.bitmap_right, OFFSET PKMN2_RIGHT

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize enemy
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Set position
        INVOKE GridToFixed, 10
        mov enemy.posX, eax

        INVOKE GridToFixed, 10
        mov enemy.posY, eax

        ;; Set sprite
        mov enemy.bitmap, OFFSET PKMN3

        ret
GameInit ENDP


GamePlay PROC
        ;; Clear screen
        INVOKE ClearScreen

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render background
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        INVOKE RenderSprite, level

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render active items
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        cmp item1.disappear, 0
        jng GamePlay_item_not_active

        ;; Make it disappear soon
        dec item1.disappear
        INVOKE RenderSprite, item1

    GamePlay_item_not_active:
        ;; Make sure item is inactive
        mov item1.active, 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render sprites
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
        INVOKE RenderSprite, enemy
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

        ;; Move player one space up, face up
        mov ebx, 24
        sal ebx, 16
        ;sub player.posY, ebx
        add level.posY, ebx

        mov eax, player.bitmap_up
        mov player.bitmap, eax
        mov player.direction, 0

    GamePlay_not_up:
        ;; Check if down arrow was pressed
        cmp eax, VK_DOWN
        jne GamePlay_not_down

        ;; Move player one space down, face down
        mov ebx, 24
        sal ebx, 16
        ;add player.posY, ebx
        sub level.posY, ebx

        mov eax, player.bitmap_down
        mov player.bitmap, eax
        mov player.direction, 1

    GamePlay_not_down:
        ;; Check if left arrow was pressed
        cmp eax, VK_LEFT
        jne GamePlay_not_left

        ;; Move player one space left, face left
        mov ebx, 24
        sal ebx, 16
        ;sub player.posX, ebx
        add level.posX, ebx

        mov eax, player.bitmap_left
        mov player.bitmap, eax
        mov player.direction, 2

    GamePlay_not_left:
        ;; Check if right arrow was pressed
        cmp eax, VK_RIGHT
        jne GamePlay_not_right

        ;; Move player one space right, face right
        mov ebx, 24
        sal ebx, 16
        ;add player.posX, ebx
        sub level.posX, ebx

        mov eax, player.bitmap_right
        mov player.bitmap, eax
        mov player.direction, 3

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
    ;; Item pickup -- remove this, but need mouse response now
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; If the user left clicked the item, display message
        cmp MouseStatus.buttons, MK_LBUTTON
        jne GamePlay_item_not_clicked

        INVOKE CheckIntersectMouse, item1
        cmp eax, 0
        je GamePlay_item_not_clicked

        ;; Display message, make item disappear
        INVOKE DrawStr, OFFSET str_item_pickup, 100, 100, 0ffh
        mov item1.disappear, 0
        mov item1.active, 0

    GamePlay_item_not_clicked:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Collision detection
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; Compare enemy and player
        INVOKE CheckIntersectSprite, enemy, player
        cmp eax, 1
        jne GamePlay_no_collision_enemy_player

        ;; Otherwise, there was a collision
        ;; Put player elsewhere
        INVOKE nrandom, GRIDX
        INVOKE GridToFixed, eax
        mov player.posX, eax

        INVOKE nrandom, GRIDY
        INVOKE GridToFixed, eax
        mov player.posY, eax

    GamePlay_no_collision_enemy_player:

        ;; Compare active attack and enemy
        cmp currAttack.active, 1
        jne GamePlay_no_collision

        INVOKE CheckIntersectSprite, enemy, currAttack
        cmp eax, 1
        jne GamePlay_no_collision

        ;; Knockback enemy
        mov eax, currAttack.velX
        sal eax, 4
        add enemy.posX, eax

        mov ebx, currAttack.velY
        sal ebx, 4
        add enemy.posY, ebx

        ;; Inactivate attack
        mov currAttack.active, 0

    GamePlay_no_collision:

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
    ;; Debug
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        INVOKE PrintTwoVals, MouseStatus.horiz, MouseStatus.vert



	ret
GamePlay ENDP

END