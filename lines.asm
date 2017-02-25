; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;   Tushar Chandra (tac311)
;
; #########################################################################

      .686
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA
	;;   If you need to, you can place global variables here
	
.CODE
    ;;   Don't forget to add the USES the directive here
    ;;   Place any registers that you modify (either explicitly or implicitly)
    ;;   into the USES list so that caller's values can be preserved
        
    ;;   For example, if your procedure uses only the eax and ebx registers
    ;;   DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD

DrawLine PROC USES eax ebx ecx edx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
    ;; Locals
    LOCAL deltax:DWORD, deltay:DWORD
    LOCAL incx:DWORD, incy:DWORD
    LOCAL currx:DWORD, curry:DWORD
    LOCAL error:DWORD, prev_error:DWORD

    ;; Absolute value routines 
    ;; (I couldn't get procs working, so there's repeated code)

    ;; deltax = abs(x0 - x1)
    mov eax, x0
    sub eax, x1
    mov ebx, eax  ; backup x0 - x1 in ebx
    neg eax  ; now eax = x1 - x0
    cmovl eax, ebx  ; if eax is negative, restore positive difference
    mov deltax, eax

    ;; deltay = abs(y0 - y1)
    mov eax, y0
    sub eax, y1
    mov ebx, eax  ; backup y0 - y1 in ebx
    neg eax  ; now eax = y1 - y0
    cmovl eax, ebx  ; if eax negative, restore positive difference
    mov deltay, eax

    ;; if (x0 < x1) incx = 1 
    ;; else -1
    mov eax, x1
    cmp x0, eax
    jnl set_incx
    mov incx, 1
    jmp done_set_incx
set_incx:  ; reached if x0 not less than x1
    mov incx, -1
done_set_incx:

    ;; if (y0 < y1) incy = 1
    ;; else -1
    mov eax, y1
    cmp y0, eax
    jnl set_incy
    mov incy, 1
    jmp done_set_incy
set_incy:  ; reached if y0 not less than y1
    mov incy, -1
done_set_incy:

    ;; if (deltax > deltay) error = deltax / 2 
    ;; else error = - deltay / 2
    mov eax, deltay
    cmp deltax, eax
    jng set_error  ; jump if deltax not greater than deltay

    mov ebx, deltax
    shr ebx, 1  ; right shift for efficient division
    mov error, ebx  ; error = deltax / 2

    jmp done_set_error
set_error:
    mov ebx, deltay
    shr ebx, 1  ; right shift for efficient division
    neg ebx
    mov error, ebx  ; error = -deltay / 2
done_set_error:

    ;; initialize currx, curry
    mov ecx, x0
    mov edx, y0
    mov currx, ecx
    mov curry, edx

    invoke DrawPixel, currx, curry, color
    
    ;; while loop time!
    jmp loop_eval

loop_body:
    invoke DrawPixel, currx, curry, color

    ;; update prev_error
    mov ebx, error
    mov prev_error, ebx

    ;; if (prev_error > - deltax)
    ;;      error -= deltay
    ;;      currx += incx
    mov eax, deltax
    neg eax  ; eax = -deltax
    cmp prev_error, eax
    jng done_xstep  ; jump if prev_error not greater than -deltax
    
    mov eax, deltay
    sub error, eax  ; error -= deltay

    mov ecx, currx
    add ecx, incx
    mov currx, ecx  ; currx += incx
 done_xstep:
 
    ;; if (prev_error < deltay)
    ;;      error += deltax
    ;;      curry += incy
    mov eax, deltay
    cmp prev_error, eax
    jnl done_ystep  ; jump if prev_error not less than deltay
    
    mov eax, deltax
    add error, eax  ; error += deltax

    mov edx, curry
    add edx, incy
    mov curry, edx  ; curry += incy
 done_ystep:

loop_eval:
    ;; if (currx != x1 OR curry != y1) loop again
    mov ecx, currx
    cmp ecx, x1
    jne loop_body

    mov edx, curry
    cmp edx, y1
    jne loop_body

    ;; done!
	ret
DrawLine ENDP

END