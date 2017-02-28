; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;   Tushar Chandra (tac311)
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

.CODE

;SinTableLookup PROC angle:FXPT
SinTableLookup PROC USES ebx ecx edx angle:FXPT
    ;; Lookup a given angle into table SINTABLE
    mov ebx, PI_INC_RECIP
    mov eax, angle

    ;; Calculate index into SINTAB
    ;; angle = (index) * (pi / 256)
    ;; => index = angle * (256 / pi) = angle * PI_INT_RECIP
    imul ebx

    ;; Save eax, since we have to use it for multiplication
    ;; but don't actually want to modify it

    ;; Deal with the fixed point multiplication, since
    ;; {edx, eax} has the product
    shr eax, 16  ; truncate last 16 bits of decimal
    shl edx, 16  ; truncate first 16 bits of integer
    add eax, edx  ; now eax is a 16/16 FXPT
    shr eax, 16  ; now eax is a 16 bit int with table index

    ;; Lookup value into SINTAB. Index is 2 * eax because it
    ;; has 16-bit entries
    xor ebx, ebx
    mov bx, [SINTAB + 2 * eax]
    xor eax, eax
    mov eax, ebx

    ret
SinTableLookup ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;FixedSin PROC angle:FXPT
FixedSin PROC USES ebx ecx edx angle:FXPT

    ;; ecx stores the angle
    mov ecx, angle

FixedSin_begin:
    ;; If angle negative, add 2 pi until positive
    cmp ecx, 0
    jg FixedSin_angle_positive

    add ecx, TWO_PI
    jmp FixedSin_begin

FixedSin_angle_positive:
    ;; Check if angle in range [0, pi/2]
    cmp ecx, PI_HALF
    jg FixedSin_angle_larger_half_pi

    ;; Calculate sine
    invoke SinTableLookup, ecx

    jmp FixedSin_end

FixedSin_angle_larger_half_pi:
    ;; Check if angle is in range [pi/2, pi]
    cmp ecx, PI
    jg FixedSin_angle_larger_pi

    ;; sin(x) = sin(pi - x), so take negative and add pi
    neg ecx
    add ecx, PI

    ;; Calculate sine
    invoke SinTableLookup, ecx

    jmp FixedSin_end

FixedSin_angle_larger_pi:
    ;; Check if angle is in range [pi, 3pi/2]
    cmp ecx, PI + PI_HALF
    jg FixedSin_angle_larger_3_half_pi

    ;; sin(x + pi) = - sin(x), so subtract pi now
    sub ecx, PI

    ;; Calculate sine; take negative to finish identity
    invoke SinTableLookup, ecx
    neg eax

    jmp FixedSin_end

FixedSin_angle_larger_3_half_pi:
    ;; Check if angle is in range [3pi/2, 2pi]
    cmp ecx, TWO_PI
    jg FixedSin_angle_larger_2_pi

    ;; sin(x + pi) = - sin(x), so subtract pi to get in range [pi/2, pi]
    ;; then take negative and add pi to get in range [0, pi/2]
    sub ecx, PI
    neg ecx
    add ecx, PI

    ;; Calculate sine; take negative to finish identity
    invoke SinTableLookup, ecx
    neg eax

    jmp FixedSin_end

FixedSin_angle_larger_2_pi:
    ;; Angle larger than 2 pi; recurse on angle - 2 pi
    sub ecx, TWO_PI
    jmp FixedSin_angle_positive

FixedSin_end:
    ret

FixedSin ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;FixedCos PROC angle:FXPT
FixedCos PROC USES ecx angle:FXPT
    ;; cos(x) = sin (x + pi/2)

    ;; call the FixedSin function
    mov ecx, angle
    add ecx, PI_HALF
    invoke FixedSin, ecx

    ret
FixedCos ENDP

END
