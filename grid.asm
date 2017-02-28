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

.DATA

.CODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert from grid tile to fixed point coordinate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GridToFixed PROC USES ebx coord:DWORD
    ;; The coordinate (x, y) will have grid tile with corners
    ;; (24 * x, 24 * y)         (24 * (x + 1), 24 * y),
    ;; (24 * x, 24 * (y + 1))   (24 * (x + 1), 24 * (y + 1))
    ;; so the formula for the center of the tile is 
    ;; (center = 24 * coord + 12)
    ;; but we also want to return a fixed point, so shift for that

    ;; Calculate center
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

    ;; Convert to fixed
    sal eax, 16

    ret
GridToFixed ENDP


END