; #########################################################################
;
;   grid.asm - Grid functions for EECS205 Assignment 4/5
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


.DATA

.CODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert from grid tile to DWORD coordinate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GridToDWORD PROC USES ebx coord:DWORD
        ;; The coordinate (x, y) will have grid tile with corners
        ;; (24 * x, 24 * y)         (24 * (x + 1), 24 * y),
        ;; (24 * x, 24 * (y + 1))   (24 * (x + 1), 24 * (y + 1))
        ;; so the formula for the center of the tile is 
        ;; (center = 24 * coord + 12).

        ;; eax <- 16 * coord
        mov eax, coord
        sal eax, 4

        ;; ebx <- 8 * coord
        mov ebx, coord
        sal ebx, 3

        ;; eax <- 24 * coord
        add eax, ebx

        ;; eax <- 24 * coord + 12
        add eax, 12

        ret
GridToDWORD ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert from grid tile to fixed point coordinate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GridToFixed PROC coord:DWORD
        ;; We can calculate the center as before, using GridToDWORD,
        ;; but we also want to return a fixed point, so shift for that

        ;; Calculate center as DWORD
        invoke GridToDWORD, coord

        ;; Convert to fixed
        sal eax, 16

        ret
GridToFixed ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set a particular bit in level.info
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LevelInfoSetBit PROC USES eax ebx ecx edx edi x:DWORD, y:DWORD, level:LEVEL, bit:DWORD
        ;; Calculate index into info as (y * sizeX) + x
        mov eax, y
        imul level.sizeX
        add eax, x

        ;; Get relevant byte from level.info
        mov edi, level.info
        xor edx, edx
        mov dl, (BYTE PTR [edi + eax])

        ;; Create mask to set relevant bit
        mov ecx, bit  ; sal requires shift amount be immediate or in cl

        xor ebx, ebx
        mov bl, 1
        sal bl, cl

        ;; Set relevant bit
        or dl, bl

        ;; Move back to level.info
        mov (BYTE PTR [edi + eax]), dl

        ret
LevelInfoSetBit ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clear a particular bit in level.info
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LevelInfoClearBit PROC USES eax ebx ecx edx edi x:DWORD, y:DWORD, level:LEVEL, bit:DWORD
        ;; Calculate index into info as (y * sizeX) + x
        mov eax, y
        imul level.sizeX
        add eax, x

        ;; Get relevant byte from level.info
        mov edi, level.info
        xor edx, edx
        mov dl, (BYTE PTR [edi + eax])

        ;; Create mask to clear relevant bit
        mov ecx, bit  ; sal requires shift amount be immediate or in cl

        xor ebx, ebx
        mov bl, 1
        sal bl, cl
        not bl

        ;; Clear relevant bit
        and dl, bl

        ;; Move back to level.info
        mov (BYTE PTR [edi + eax]), dl

        ret
LevelInfoClearBit ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check if particular bit in level.info is set
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LevelInfoTestBit PROC USES ebx ecx edx edi x:DWORD, y:DWORD, level:LEVEL, bit:DWORD
        ;; Calculate index into info as (y * sizeX) + x
        mov eax, y
        imul level.sizeX
        add eax, x

        ;; Get relevant byte from level.info
        mov edi, level.info
        xor edx, edx
        mov dl, (BYTE PTR [edi + eax])

        ;; Create mask to set relevant bit
        mov ecx, bit  ; sal requires shift amount be immediate or in cl

        xor ebx, ebx
        mov bl, 1
        sal bl, cl

        ;; Test relevant bit
        test dl, bl
        jz LevelInfoTestBit_zero  ; bit not set

        mov eax, 1
        ret

    LevelInfoTestBit_zero:
        mov eax, 0
        ret

LevelInfoTestBit ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render level on screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RenderLevel PROC USES edi ecx edx level:LEVEL
        ;; We want the top-left of the visible bitmap to render at (0, 0)
        ;; on the screen.
        ;;
        ;; bitmap(x, y) ~ screen(0, 0)
        ;;
        ;; When we render, we need to specify where on the screen the 
        ;; center of the bitmap goes. If the visible bitmap has offset
        ;; (0, 0), the center of the bitmap would be
        ;; (bitmap.dwWidth / 2, bitmap.dwHeight / 2) 
        ;; in both bitmap and screen coordinates.
        ;;
        ;; This means that if our bitmap has offset (x, y), its 
        ;; center will be at
        ;; screen(bitmap.dwWidth / 2 - x, bitmap.dwHeight / 2 - y)
        ;;
        ;; Lastly, because each grid space is 24x24 pixels, we add 12
        ;; to both the x- and y-coords to account for this, and we 
        ;; pass this to BasicBlit.

        mov edi, level.bitmap

        ;; ecx <- bitmap.dwWidth / 2
        mov ecx, (EECS205BITMAP PTR [edi]).dwWidth
        sar ecx, 1

        ;; ecx <- bitmap.dwWidth / 2 - offsetX
        INVOKE GridToDWORD, level.offsetX
        sub ecx, eax

        ;; Add 12 to account for center of grid square
        add ecx, 12

        ;; edx <- bitmap.dwHeight / 2
        mov edx, (EECS205BITMAP PTR [edi]).dwHeight
        sar edx, 1

        ;; edx <- bitmap.dwHeight / 2 - offsetY 
        INVOKE GridToDWORD, level.offsetY
        sub edx, eax

        ;; Add 12 to account for center of grid square
        add edx, 12

        ;; Center of bitmap is at screen(ecx, edx)
        INVOKE BasicBlit, level.bitmap, ecx, edx

        ret

RenderLevel ENDP



END