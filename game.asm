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

player MONSTER< >
enemy MONSTER< >

;; Testing strings
intersect_str BYTE "intersect!", 0
no_intersect_str BYTE "do not intersect :(", 0
never_str BYTE "you should never reach here", 0
zero_str BYTE "returned 0", 0
one_str BYTE "returned 1", 0

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
; Utility function: clear the entire screen
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
; Utility function: print registers onto the screen
;                   this is a bad way to debug
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintRegs PROC USES eax ebx ecx edx esi edi
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
; Utility function: print two values onto the screen
;                   this is also a bad way to debug
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintTwoVals PROC USES eax ebx ecx edx esi edi first:DWORD, second:DWORD
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
; Collision detection
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
    ; Compute bounding box for first bitmap
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
    ; Compute bounding box for second bitmap
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
    ; Compare bounding boxes
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
; Collision detection with fixed point positions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckIntersectFixed PROC oneX:FXPT, oneY:FXPT, oneBitmap:PTR EECS205BITMAP, twoX:FXPT, twoY:FXPT, twoBitmap:PTR EECS205BITMAP

    ;; Convert everything from fixed point
    LOCAL oneXD:DWORD, oneYD:DWORD, twoXD:DWORD, twoYD:DWORD
    
    mov eax, oneX
    mov oneXD, eax
    sar oneXD, 16

    mov eax, oneY
    mov oneYD, eax
    sar oneYD, 16

    mov eax, twoX
    mov twoXD, eax
    sar twoXD, 16

    mov eax, twoY
    mov twoYD, eax
    sar twoYD, 16

    ;; Call the normal CheckIntersect
    INVOKE CheckIntersect, oneXD, oneYD, oneBitmap, twoXD, twoYD, twoBitmap

    ;; Result is already in eax
    ret
CheckIntersectFixed ENDP


GameInit PROC
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Seed random numbers
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; {edx, eax} <- internal cycle counter -- works as seed
        rdtsc
        invoke nseed, eax

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize player
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Set position
        INVOKE nrandom, GRIDX
        INVOKE GridToFixed, eax
        mov player.posX, eax

        INVOKE nrandom, GRIDY
        INVOKE GridToFixed, eax
        mov player.posY, eax

        ;; Set sprite
        mov player.sprite, OFFSET PKMN2

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initialize enemy
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Set position
        INVOKE GridToFixed, 10
        mov enemy.posX, eax

        INVOKE GridToFixed, 10
        mov enemy.posY, eax

        ;; Set sprite
        mov enemy.sprite, OFFSET PKMN3

        ret
GameInit ENDP


GamePlay PROC
        
        INVOKE ClearScreen

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render background
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
;        INVOKE BasicBlit, OFFSET StarBitmap, 200, 200


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render enemies
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
        ;; Convert positions out of fixed point
        mov ebx, enemy.posX
        sar ebx, 16

        mov ecx, enemy.posY
        sar ecx, 16

        ;; Render enemy sprite
        INVOKE BasicBlit, enemy.sprite, ebx, ecx

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Render player
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; Convert positions out of fixed point
        mov ebx, player.posX
        sar ebx, 16

        mov ecx, player.posY
        sar ecx, 16

        ;; Render player sprite
        INVOKE BasicBlit, player.sprite, ebx, ecx

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Move player -- arrow key controls
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov eax, KeyPress

        ;; Check if up arrow was pressed
        cmp eax, VK_UP
        jne GamePlay_not_up

        ;; Move player one space up
        mov ebx, 24
        sal ebx, 16
        sub player.posY, ebx

    GamePlay_not_up:
        ;; Check if down arrow was pressed
        cmp eax, VK_DOWN
        jne GamePlay_not_down

        ;; Move player one space down
        mov ebx, 24
        sal ebx, 16
        add player.posY, ebx

    GamePlay_not_down:
        ;; Check if left arrow was pressed
        cmp eax, VK_LEFT
        jne GamePlay_not_left

        ;; Move player one space left
        mov ebx, 24
        sal ebx, 16
        sub player.posX, ebx

    GamePlay_not_left:
        ;; Check if right arrow was pressed
        cmp eax, VK_RIGHT
        jne GamePlay_not_right

        ;; Move player one space right
        mov ebx, 24
        sal ebx, 16
        add player.posX, ebx

    GamePlay_not_right:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Collision detection
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;; Compare enemy and player
        INVOKE CheckIntersectFixed, enemy.posX, enemy.posY, enemy.sprite, player.posX, player.posY, player.sprite
        cmp eax, 1
        jne GamePlay_no_collision

        ;; Otherwise, there was a collision
        ;; Put player elsewhere
        INVOKE GridToFixed, 12
        mov player.posX, eax

        INVOKE GridToFixed, 8
        mov player.posY, eax

    GamePlay_no_collision:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Debug
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov eax, player.posX
        sar eax, 16

        mov ebx, player.posY
        sar ebx, 16
        INVOKE PrintTwoVals, eax, ebx



	ret
GamePlay ENDP

END