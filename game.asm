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
include game.inc

;; Has keycodes
include keys.inc

.DATA

;; If you need to, you can place global variables here
intersect_str BYTE "intersect!", 0
no_intersect_str BYTE "do not intersect :(", 0
zero_str BYTE "returned 0", 0
one_str BYTE "retruned 1", 0

.CODE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Utility function: clear the entire screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearScreen PROC USES edi
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
        mov oneBottom, ecx

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
        mov twoBottom, ecx

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
        INVOKE ClearScreen
        INVOKE DrawStr, OFFSET intersect_str, 400, 360, 0ffh
        mov eax, 1
        ret
        jmp CheckIntersect_end
        ;; Some kind of error is causing this jump to not take place

    ;; reached when they do not overlap
    CheckIntersect_no_overlap:

        INVOKE DrawStr, OFFSET no_intersect_str, 400, 360, 0ffh
        mov eax, 0

    CheckIntersect_end:
        ret
CheckIntersect ENDP


GameInit PROC USES edi
        ;; Positions of stars
        LOCAL oneX:DWORD, oneY:DWORD, twoX:DWORD, twoY:DWORD

        ;; Clear screen
        INVOKE ClearScreen

        mov oneX, 100
        mov oneY, 100
        mov twoX, 200
        mov twoY, 100

        INVOKE BasicBlit, OFFSET StarBitmap, oneX, oneY
        INVOKE BasicBlit, OFFSET StarBitmap, twoX, twoY

        INVOKE CheckIntersect, oneX, oneY, OFFSET StarBitmap, twoX, twoY, OFFSET StarBitmap

        cmp eax, 0
        jne GameInit_intersect_1

        INVOKE DrawStr, OFFSET zero_str, 200, 200, 0ffh
        jmp GameInit_done

    GameInit_intersect_1:
    INVOKE DrawStr, OFFSET zero_str, 200, 200, 0ffh

    GameInit_done: 
    	ret

GameInit ENDP


GamePlay PROC


	ret
GamePlay ENDP

END