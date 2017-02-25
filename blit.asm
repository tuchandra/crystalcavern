
; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
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


.DATA

    ;; If you need to, you can place global variables here
    
.CODE

DrawPixel PROC USES ebx ecx x:DWORD, y:DWORD, color:DWORD
    ;; width = 640, height = 480
    ;; ScreenBitsPtr holds the backbuffer, and it's an array of 640 x 480 bytes
    ;; order (0,0), (1,0), (2,0), ..., (639, 0), (0, 1), (1, 1), ..., (639, 479)

    ;; check validity of arguments
    cmp x, 0
    jl DoneDrawing

    cmp x, 639
    jg DoneDrawing

    cmp y, 0
    jl DoneDrawing

    cmp y, 479
    jg DoneDrawing

    ;; calculate index of pixel as (x + y * 640)
    mov eax, y
    mov ebx, 640
    mul ebx
    add eax, x

    ;; calculate actual address
    add eax, ScreenBitsPtr

    ;; color is the least significant byte of the provided color
    ;; move to ecx, then can access as cl
    mov ecx, color

    ;; set color of pixel
    mov [eax], cl

DoneDrawing:
    ret

DrawPixel ENDP

BasicBlit PROC USES ebx ecx edx edi esi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
    ;; bitmap should have center at xcenter, ycenter
    LOCAL x_min:DWORD, y_min:DWORD
    
    ;; edi keeps bitmap pointer
    mov edi, ptrBitmap

    ;; (x_min, y_min) = (xcenter - dwWidth / 2, ycenter - dwHeight / 2)
    mov ecx, (EECS205BITMAP PTR [edi]).dwWidth
    sar ecx, 1
    mov edx, xcenter
    sub edx, ecx
    mov x_min, edx

    mov ecx, (EECS205BITMAP PTR [edi]).dwHeight
    sar ecx, 1
    mov edx, ycenter
    sub edx, ecx
    mov y_min, edx

    ;; Draw the bitmap, pixel by pixel
    ;;  for (y = 0; y < dwHeight; y++)
    ;;      for (x = 0; x < dwWidth; x++)
    ;;          DrawPixel(x + x_min, y + y_min, some_color)
    ;; Use ecx for x, esi for y

    ;; y = 0
    mov esi, 0
    jmp BasicBlit_eval_y
BasicBlit_loop_y:
    ;; x = 0
    mov ecx, 0
    jmp BasicBlit_eval_x

    BasicBlit_loop_x:
        ;; (x, y) = (ecx, esi)
        ;; Pixel color index = y * dwWidth + x

        mov eax, (EECS205BITMAP PTR [edi]).dwWidth
        mul esi
        add eax, ecx  ; index into color array

        ;; Get color of current pixel (byte quantity)
        mov ebx, (EECS205BITMAP PTR [edi]).lpBytes
        xor edx, edx
        mov dl, BYTE PTR [ebx + eax]

        ;; Drawing happens at x + x_min, y + y_min
        add ecx, x_min
        add esi, y_min

        ;; Check bounds -- do not attempt to draw things off screen
        cmp ecx, 0
        jl BasicBlit_no_draw

        cmp ecx, 639
        jg BasicBlit_no_draw

        cmp esi, 0
        jl BasicBlit_no_draw

        cmp esi, 479
        jg BasicBlit_no_draw

        ;; Check transparency -- if color is transparent one, don't draw
        xor eax, eax
        mov al, (EECS205BITMAP PTR [edi]).bTransparent
        cmp al, dl
        je BasicBlit_no_draw

        ;; Draw pixel
        invoke DrawPixel, ecx, esi, dl

    BasicBlit_no_draw:
        ;; Restore original values of x, y
        sub ecx, x_min
        sub esi, y_min

        ;; x++
        inc ecx

    BasicBlit_eval_x:
        ;; if x < dwWidth, loop again
        cmp ecx, (EECS205BITMAP PTR [edi]).dwWidth
        jl BasicBlit_loop_x

    ;; y++
    inc esi

BasicBlit_eval_y:
    ;; if y < dwHeight, loop again
    cmp esi, (EECS205BITMAP PTR [edi]).dwHeight
    jl BasicBlit_loop_y

    ret
BasicBlit ENDP

MultiplyIntFixed PROC USES edx x:DWORD, y:FXPT
    ;; Multiply DWORD x and FXPT y, by converting x
    ;; to fixed point, multiplying, then converting back.

    mov edx, x
    sal edx, 16  ; convert to fixed point (fractional part 0)
    mov eax, y
    imul edx  ; {edx, eax} has int * fixed as 32+32 fixed point
    mov eax, edx  ; return int part of result

    ret
MultiplyIntFixed ENDP

RotateBlit PROC USES ebx ecx edx esi edi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
    ;; locals
    LOCAL cosa:FXPT, sina:FXPT
    LOCAL shiftX:DWORD, shiftY:DWORD
    LOCAL dstWidth:DWORD, dstHeight:DWORD
    LOCAL srcX:DWORD, srcY:DWORD
    LOCAL dstX:DWORD, dstY:DWORD

    ;; calculate angles, convert to normal 16-bit int
    invoke FixedCos, angle
    mov cosa, eax

    invoke FixedSin, angle
    mov sina, eax

    ;; esi keeps bitmap pointer
    mov esi, lpBmp

    ;; shiftX = [esi].dwWidth * cosa / 2 - [esi].dwHeight * sina / 2
    invoke MultiplyIntFixed, (EECS205BITMAP PTR [esi]).dwWidth, cosa
    sar eax, 1  ; divide result by 2
    mov ebx, eax  ; protect [esi].dwWidth * cosa / 2

    invoke MultiplyIntFixed, (EECS205BITMAP PTR [esi]).dwHeight, sina
    sar eax, 1  ; divide result by 2
    sub ebx, eax  ; subtract [esi].dwHeight * sina / 2 from first term

    mov shiftX, ebx

    ;; shiftY = [esi].dwHeight * cosa / 2 + [esi].dwWidth * sina / 2
    invoke MultiplyIntFixed, (EECS205BITMAP PTR [esi]).dwHeight, cosa
    sar eax, 1  ; divide result by 2
    mov ebx, eax  ; protect [esi].dwHeight * cosa / 2 in ebx

    invoke MultiplyIntFixed, (EECS205BITMAP PTR [esi]).dwWidth, sina
    sar eax, 1  ; divide result by 2
    add ebx, eax  ; add [esi].dwWidth * sina / 2 to first term

    mov shiftY, ebx

    ;; dstWidth = dwWidth + dwHeight
    ;; dstHeight = dstWidth
    mov ecx, (EECS205BITMAP PTR [esi]).dwWidth
    add ecx, (EECS205BITMAP PTR [esi]).dwHeight
    mov dstWidth, ecx
    mov dstHeight, ecx

    ;;; Massive double for loop time!

    ;;  for (dstX = -dstWidth; dstX < dstWidth; dstX++)
    ;;      for (dstY = -dstHeight; dstY < dstHeight; dstY++)
    ;;          srcX = dstX * cosa + dstY * sina
    ;;          srcY = dstY * cosa – dstX * sina
    ;;
    ;;          if (srcX >= 0 && 
    ;;              srcX < (EECS205BITMAP PTR [esi]).dwWidth &&
    ;;              srcY >= 0 &&
    ;;              srcY < (EECS205BITMAP PTR [esi]).dwHeight &&
    ;;              (xcenter+dstX-shiftX) >= 0 && 
    ;;              (xcenter+dstX-shiftX) < 639 &&
    ;;              (ycenter+dstY-shiftY) >= 0 && 
    ;;              (ycenter+dstY-shiftY) < 479 &&
    ;;              bitmap pixel (srcX,srcY) is not transparent) 
    ;;          then
    ;;              DrawPixel(xcenter+dstX-shiftX, ycenter+dstY-shiftY,
    ;;                        bitmap pixel)

    ;; dstX = -dstWidth
    mov ebx, dstWidth
    mov dstX, ebx
    neg dstX
    jmp RotateBlit_eval_x
RotateBlit_loop_x:
    ;; dstY = -dstHeight
    mov ebx, dstHeight
    mov dstY, ebx
    neg dstY
    jmp RotateBlit_eval_y

    RotateBlit_loop_y:
        ;; srcX = dstX * cosa + dstY * sina
        invoke MultiplyIntFixed, dstX, cosa
        mov edi, eax  ; protect dstX * cosa

        invoke MultiplyIntFixed, dstY, sina
        add edi, eax  ; add to first term

        mov srcX, edi

        ;; srcY = dstY * cosa - dstX * sina
        invoke MultiplyIntFixed, dstY, cosa
        mov edi, eax  ; protect dstY * cosa

        invoke MultiplyIntFixed, dstX, sina
        sub edi, eax  ; subtract from first term

        mov srcY, edi

        ;;; Big conditional time!

        ;; srcX >= 0
        cmp srcX, 0
        jnge RotateBlit_no_draw

        ;; srcX < [esi].dwWidth
        mov edx, (EECS205BITMAP PTR [esi]).dwWidth
        cmp srcX, edx
        jnl RotateBlit_no_draw

        ;; srcY >= 0
        cmp srcY, 0
        jnge RotateBlit_no_draw

        ;; srcY < (EECS205BITMAP PTR [esi]).dwHeight
        mov edx, (EECS205BITMAP PTR [esi]).dwHeight
        cmp srcY, edx
        jnl RotateBlit_no_draw

        ;; Lots of things with xcenter + dstX - shiftX, so put in ebx
        mov ebx, xcenter
        add ebx, dstX
        sub ebx, shiftX

        ;; Similarly with ycenter + dstY - shiftY, so put in ecx
        mov ecx, ycenter
        add ecx, dstY
        sub ecx, shiftY

        ;; xcenter + dstX - shiftX >= 0
        cmp ebx, 0
        jnge RotateBlit_no_draw

        ;; xcenter + dstX - shiftX < 639
        cmp ebx, 639
        jnl RotateBlit_no_draw

        ;; ycenter + dsdtY - shiftY >= 0
        cmp ecx, 0
        jnge RotateBlit_no_draw

        ;; ycenter + dsdtY - shiftY < 479
        cmp ecx, 479
        jnl RotateBlit_no_draw

        ;;; All the conditions except transparency are checked

        ;; Compute index into color array, stored in eax
        mov eax, (EECS205BITMAP PTR [esi]).dwWidth
        imul srcY
        add eax, srcX

        ;; get color of (srcX, srcY) -- byte quantity
        mov edi, (EECS205BITMAP PTR [esi]).lpBytes
        xor edx, edx
        mov dl, BYTE PTR [edi + eax]

        ;; Check transparency -- if color is transparent one, don't draw
        xor eax, eax
        mov al, (EECS205BITMAP PTR [esi]).bTransparent
        cmp al, dl
        je RotateBlit_no_draw

        ;; Draw, finally
        invoke DrawPixel, ebx, ecx, edx

    RotateBlit_no_draw:

        ;; dstY++
        inc dstY

    RotateBlit_eval_y:
        ;; if dstY < dstHeight, loop again
        mov ebx, dstHeight
        cmp dstY, ebx
        jl RotateBlit_loop_y

    ;; dstX++
    inc dstX

RotateBlit_eval_x:
    ;; if dstX < dstWidth, loop again
    mov ebx, dstWidth
    cmp dstX, ebx
    jl RotateBlit_loop_x

    ret
RotateBlit ENDP


END