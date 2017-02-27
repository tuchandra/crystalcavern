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
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

.DATA

;; Testing strings
intersect_str BYTE "intersect!", 0
no_intersect_str BYTE "do not intersect :(", 0
never_str BYTE "you should never reach here", 0
zero_str BYTE "returned 0", 0
one_str BYTE "returned 1", 0

;; Format strings
fmtStr_eax BYTE "eax: %d", 0
outStr_eax BYTE 256 DUP(0)

fmtStr_ebx BYTE "ebx: %d", 0
outStr_ebx BYTE 256 DUP(0)

fmtStr_ecx BYTE "ecx: %d", 0
outStr_ecx BYTE 256 DUP(0)

fmtStr_edx BYTE "edx: %d", 0
outStr_edx BYTE 256 DUP(0)

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

        ;mov ecx, (EECS205BITMAP PTR [edi]).dwWidth
        ;sar ecx, 1
        ;mov edx, twoX
        ;add edx, ecx
        ;mov twoRight, edx

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
        mov eax, 1
        ret

    ;; reached when they do not overlap
    CheckIntersect_no_overlap:
        mov eax, 0
        ret

CheckIntersect ENDP


GameInit PROC USES edi eax
        ;; Clear screen, just in case
        INVOKE ClearScreen


        ret
GameInit ENDP


GamePlay PROC
        
        INVOKE CheckIntersect, 100, 100, OFFSET StarBitmap, 120, 120, OFFSET StarBitmap

	ret
GamePlay ENDP

END