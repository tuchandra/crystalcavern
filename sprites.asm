; #########################################################################
;
;   sprites.asm - Sprites for EECS205 Assignment 4/5
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

PKMN2_UP EECS205BITMAP <24, 24, 012h,, offset PKMN2_UP + sizeof PKMN2_UP>
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,000h,000h,000h,000h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h,0c4h,000h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 000h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,000h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h
	BYTE 000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h
	BYTE 0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,000h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h
	BYTE 0f1h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h
	BYTE 0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,000h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h
	BYTE 0c4h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 000h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,000h,0c4h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h
	BYTE 0c4h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0f1h
	BYTE 0f1h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,000h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,000h,0f1h,0c4h,0fch,0f1h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h
	BYTE 000h,0c4h,0f1h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0c4h,0c4h
	BYTE 0fch,0fch,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,0c4h,000h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,0fch,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h
	BYTE 0c4h,000h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0f1h
	BYTE 0c4h,0ffh,0c4h,0f1h,0f1h,0f1h,0f1h,0c4h,0f1h,0c4h,000h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,000h,0f1h,000h,0f1h,000h,0f1h,0f1h,0f1h,0f1h,0c4h
	BYTE 0c4h,0f1h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0ffh,0c4h
	BYTE 000h,0f1h,000h,0f1h,0f1h,0f1h,0c4h,0c4h,080h,0c4h,0ffh,000h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,000h,0f1h,000h,0f1h,000h,0c4h,0f1h,0f1h,0c4h,000h
	BYTE 0c4h,0f1h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h
	BYTE 000h,0c4h,0f1h,000h,0f1h,0c4h,000h,000h,000h,000h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h,0c4h,000h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,000h,0c4h,0c4h,0c4h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,000h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h

PKMN2_DOWN EECS205BITMAP <24, 24, 012h,, offset PKMN2_DOWN + sizeof PKMN2_DOWN>
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,0c4h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,0c4h
	BYTE 012h,012h,012h,012h,012h,0c4h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,0c4h,012h,012h,012h,012h,0c4h,0c4h,0c4h,012h
	BYTE 012h,012h,000h,000h,000h,000h,000h,012h,012h,012h,012h,012h,012h,012h,012h,0c4h
	BYTE 012h,012h,012h,0c4h,0c4h,0fch,0c4h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h,0c4h,000h
	BYTE 012h,012h,012h,012h,012h,012h,012h,0c4h,012h,012h,012h,0c4h,0f1h,0f1h,0c4h,012h
	BYTE 000h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,0c4h
	BYTE 012h,012h,012h,0f1h,0f1h,0fch,0f1h,012h,000h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h
	BYTE 000h,012h,012h,012h,012h,012h,012h,0f1h,012h,012h,0f1h,0f1h,0fch,0fch,0f1h,000h
	BYTE 0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,0f1h
	BYTE 012h,012h,012h,0f1h,0ffh,0f1h,012h,000h,0ffh,000h,0f1h,0f1h,0f1h,0f1h,0f1h,0ffh
	BYTE 000h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0f1h,000h,012h,000h
	BYTE 000h,000h,0f1h,0f1h,0f1h,0f1h,0f1h,000h,000h,000h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,000h,0c4h,000h,012h,000h,04ah,000h,0f1h,0f1h,0f1h,0f1h,0f1h,000h
	BYTE 04ah,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0c4h,000h,012h,000h
	BYTE 0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,000h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,000h,0c4h,0c4h,000h,000h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h
	BYTE 0c4h,000h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,0c4h,0f1h
	BYTE 000h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,0f1h,0c4h,000h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,000h,0c4h,0f1h,0c4h,080h,000h,080h,0c4h,0c4h,0c4h,080h,000h
	BYTE 080h,0c4h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,012h,000h,0f1h,0c4h,000h
	BYTE 0c4h,0c4h,000h,000h,000h,000h,000h,0c4h,0c4h,000h,0c4h,0f1h,000h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,000h,000h,000h,0c4h,0d4h,0d4h,0ach,0ach,0ach,0ach,0ach
	BYTE 0c4h,000h,000h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,080h
	BYTE 0c4h,0d4h,0fch,0d4h,0d4h,0d4h,0d4h,0ach,0c4h,080h,000h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,080h,0d4h,0fch,0d4h,0d4h,0ach,080h
	BYTE 0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h
	BYTE 080h,080h,080h,0ach,0ach,0ach,080h,080h,080h,000h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,0c4h,0c4h,000h,000h,000h,0c4h,0c4h
	BYTE 0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0ffh
	BYTE 000h,0ffh,000h,012h,012h,012h,000h,0ffh,000h,0ffh,000h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,000h,012h,000h,012h,012h,012h,012h,012h,000h
	BYTE 012h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h

PKMN2_LEFT EECS205BITMAP <24, 24, 012h,, offset PKMN2_LEFT + sizeof PKMN2_LEFT>
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,000h,000h,000h,000h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0c4h
	BYTE 0f1h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,0f1h,0f1h
	BYTE 0f1h,0f1h,0f1h,0f1h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,000h,0c4h,0f1h,0f1h,0c4h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h
	BYTE 012h,012h,012h,012h,012h,0c4h,012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h,0ffh
	BYTE 000h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,0c4h,012h,012h,012h
	BYTE 012h,012h,000h,0f1h,0f1h,0f1h,0f1h,000h,000h,04ah,0f1h,0f1h,0c4h,000h,012h,012h
	BYTE 012h,012h,012h,0c4h,0c4h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h,000h
	BYTE 04ah,0c4h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h,012h,0c4h,0c4h,0fch,0c4h,012h,012h
	BYTE 012h,012h,000h,080h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,012h
	BYTE 012h,012h,0c4h,0fch,0fch,0c4h,012h,012h,012h,012h,012h,000h,000h,080h,0c4h,0c4h
	BYTE 0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h,0f1h,0fch,0fch,0f1h,012h,012h
	BYTE 012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h,0f1h,0c4h,0f1h,0f1h,0f1h,0f1h,000h
	BYTE 012h,012h,012h,0f1h,0ffh,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,000h
	BYTE 0d4h,0c4h,0f1h,0f1h,080h,0f1h,0f1h,0c4h,000h,012h,012h,000h,0f1h,000h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,000h,0fch,0c4h,0f1h,0c4h,080h,0f1h,0f1h,0c4h
	BYTE 000h,012h,012h,000h,0f1h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h
	BYTE 0d4h,0c4h,0f1h,080h,0c4h,0c4h,0f1h,0c4h,000h,012h,012h,000h,0f1h,000h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,000h,0ach,0d4h,080h,080h,0c4h,0c4h,0c4h,0c4h
	BYTE 080h,000h,000h,0f1h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 000h,0ach,0c4h,0f1h,0f1h,0f1h,0c4h,080h,0c4h,0f1h,0f1h,0c4h,000h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,000h,0bbh,0c4h,0f1h,0f1h,0f1h,0c4h,080h,000h
	BYTE 0c4h,0c4h,0c4h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 000h,000h,0c4h,0f1h,0c4h,080h,000h,012h,000h,000h,000h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,080h,0c4h,0c4h,0c4h,000h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 000h,0ffh,0f1h,0f1h,000h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,000h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h

PKMN2_RIGHT EECS205BITMAP <24, 24, 012h,, offset PKMN2_RIGHT + sizeof PKMN2_RIGHT>
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,000h
	BYTE 000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h
	BYTE 0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,000h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,000h,000h,012h,012h,012h,012h
	BYTE 012h,012h,0c4h,012h,012h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h,0f1h
	BYTE 0c4h,0f1h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,0c4h,012h,012h,012h,012h
	BYTE 012h,012h,000h,0c4h,0f1h,0f1h,0f1h,000h,0ffh,0f1h,0f1h,0f1h,0c4h,000h,012h,012h
	BYTE 012h,012h,012h,0c4h,0c4h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,04ah,000h
	BYTE 000h,0f1h,0f1h,0f1h,0f1h,000h,012h,012h,012h,012h,0c4h,0fch,0c4h,0c4h,012h,012h
	BYTE 012h,000h,0c4h,0f1h,0f1h,0f1h,0c4h,04ah,000h,0f1h,0f1h,0f1h,0c4h,000h,012h,012h
	BYTE 012h,012h,0c4h,0fch,0fch,0c4h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h
	BYTE 0f1h,0f1h,0f1h,0c4h,080h,000h,012h,012h,012h,012h,0f1h,0fch,0fch,0f1h,012h,012h
	BYTE 000h,0c4h,0f1h,0f1h,0f1h,0f1h,0f1h,0f1h,0c4h,0c4h,080h,000h,000h,012h,012h,012h
	BYTE 012h,012h,012h,0ffh,0f1h,012h,012h,012h,000h,0f1h,0f1h,0f1h,0f1h,0c4h,0f1h,0f1h
	BYTE 0f1h,0f1h,0c4h,000h,012h,012h,012h,012h,012h,012h,000h,0f1h,000h,012h,012h,000h
	BYTE 0c4h,0f1h,0f1h,080h,0f1h,0f1h,0c4h,0d4h,000h,000h,000h,012h,012h,012h,012h,012h
	BYTE 012h,012h,000h,0f1h,000h,012h,012h,000h,0c4h,0f1h,0f1h,080h,0c4h,0f1h,0c4h,0fch
	BYTE 000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0f1h,000h,012h,012h,000h
	BYTE 0c4h,0f1h,0c4h,0c4h,080h,0f1h,0c4h,0d4h,000h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,000h,0f1h,000h,000h,080h,0c4h,0c4h,0c4h,0c4h,080h,080h,0d4h,0ach
	BYTE 000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0c4h,0f1h,0f1h,0c4h
	BYTE 080h,0c4h,0f1h,0f1h,0f1h,0c4h,0ach,000h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,000h,0c4h,0c4h,0c4h,000h,080h,0c4h,0f1h,0f1h,0f1h,0c4h,0bbh
	BYTE 000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,000h
	BYTE 012h,000h,080h,0c4h,0f1h,0c4h,000h,000h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,0c4h,0c4h,0c4h,080h,000h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,000h,000h,0f1h,0f1h,0ffh,000h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,000h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h



PKMN2 EECS205BITMAP <24, 24, 255,, offset PKMN2 + sizeof PKMN2>
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,049h,049h,049h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,0f0h,0f0h,0f0h
	BYTE 0cdh,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,0cdh,049h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,049h,0f0h,0f0h,0f0h,0f0h,0f0h,0cdh,049h,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,049h,0cdh,0cdh,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,0f0h,0f0h,0f0h,0f0h
	BYTE 0f0h,0f0h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,0cdh,0cdh,049h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,049h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0cdh,049h,0ffh,0ffh,0ffh,0ffh
	BYTE 049h,0cdh,0cdh,0f0h,0cdh,049h,0ffh,0ffh,0ffh,049h,0f0h,0f0h,0f0h,0f0h,0ffh,049h
	BYTE 0f0h,0f0h,0cdh,049h,0ffh,0ffh,0ffh,0ffh,049h,0cdh,0f0h,0fch,0cdh,049h,0ffh,0ffh
	BYTE 0ffh,049h,0f0h,0f0h,0f0h,0f0h,049h,049h,0f0h,0cdh,0cdh,0cdh,049h,0ffh,0ffh,0ffh
	BYTE 049h,0cdh,0fch,0fch,0cdh,049h,0ffh,0ffh,0ffh,049h,0f0h,0f0h,0f0h,0f0h,049h,049h
	BYTE 0f0h,0cdh,0cdh,0cdh,049h,0ffh,0ffh,0ffh,0ffh,049h,0fch,06dh,049h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,049h,0cdh,0f0h,0f0h,0f0h,0f0h,0cdh,0cdh,0cdh,0cdh,0cdh,049h,0ffh,0ffh
	BYTE 0ffh,049h,0f0h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,049h,0cdh,0cdh,0cdh
	BYTE 0cdh,0cdh,0cdh,0cdh,0cdh,0cdh,049h,0ffh,049h,0f0h,0f0h,049h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,049h,049h,06dh,0cdh,0cdh,049h,0cdh,0cdh,0cdh,049h,049h
	BYTE 0cdh,0f0h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,0fch
	BYTE 0fch,049h,0f0h,0f0h,0cdh,0cdh,0cdh,049h,0cdh,0f0h,049h,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,0fch,0fch,0fch,049h,06dh,0cdh,0cdh,0cdh,049h
	BYTE 0cdh,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,0b6h,06dh
	BYTE 0fch,0fch,0fch,0cdh,0cdh,0cdh,0cdh,06dh,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,06dh,06dh,0b5h,0b5h,0cdh,0cdh,0cdh,06dh,06dh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,06dh,06dh,06dh,0cdh,06dh,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,0ffh,0cdh,0ffh,06dh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,06dh,06dh,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh


PKMN3 EECS205BITMAP <24, 24, 255,, offset PKMN3 + sizeof PKMN3>
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,049h,049h,049h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,049h,049h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,0bbh,0bbh,0bbh,076h
	BYTE 049h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,0bbh,0bbh,0bbh,049h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,049h,0bbh,0bbh,0bbh,0bbh,0bbh,0bbh,076h,049h,049h,0ffh,0ffh,0ffh,049h
	BYTE 0bbh,0bbh,0bbh,076h,076h,049h,0ffh,0ffh,0ffh,0ffh,049h,0bbh,0bbh,0bbh,0bbh,0bbh
	BYTE 0bbh,0bbh,049h,0cdh,049h,049h,0ffh,049h,0bbh,0bbh,076h,049h,076h,049h,0ffh,0ffh
	BYTE 0ffh,049h,0cdh,0bbh,0bbh,0bbh,0bbh,0bbh,0bbh,0bbh,076h,0cdh,0f0h,0cdh,049h,076h
	BYTE 0bbh,076h,049h,076h,076h,049h,0ffh,0ffh,0ffh,049h,0bbh,0bbh,0bbh,0bbh,0ffh,049h
	BYTE 0bbh,0bbh,076h,0b6h,0f0h,0f0h,0cdh,049h,076h,076h,049h,076h,049h,0ffh,0ffh,0ffh
	BYTE 0ffh,049h,076h,0bbh,0bbh,0bbh,049h,0cdh,0bbh,076h,076h,0ffh,0f0h,0f0h,0f0h,049h
	BYTE 076h,049h,049h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,076h,076h,0bbh,049h,0cdh
	BYTE 076h,076h,076h,049h,0ffh,0f0h,0f0h,0cdh,049h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,049h,049h,076h,076h,076h,076h,049h,049h,0bbh,0bbh,0ffh,0cdh,0cdh
	BYTE 049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,0bbh,049h,049h,049h
	BYTE 049h,0bbh,0bbh,0bbh,076h,0ffh,0cdh,0cdh,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,049h,049h,0fch,0fch,049h,0bbh,0bbh,076h,049h,0ffh,0cdh,0cdh
	BYTE 049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,0fch
	BYTE 0fch,049h,049h,049h,06dh,0b6h,0cdh,0cdh,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,06dh,076h,06dh,0b5h,0fch,0fch,0fch,0b5h,06dh,0b6h,06dh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,06dh
	BYTE 06dh,06dh,0b5h,0b5h,0bbh,06dh,0b6h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,06dh,06dh,0bbh,06dh,06dh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,06dh,076h,076h,076h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,06dh,06dh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh

ATTK1 EECS205BITMAP <16, 16, 012h,, offset ATTK1 + sizeof ATTK1>
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,0c4h,0c4h,0c4h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,0c4h,0c4h,0c4h,0c4h,0f1h,0c4h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,0c4h,0f1h,0f1h,0c4h,0c4h,0f1h,0f1h,0c4h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,0c4h,0f1h,0fch,0c4h,012h,012h,0fch,0c4h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,0c4h,0fch,0ffh,0c4h,012h,0fch,0f1h,0c4h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,0c4h,0f1h,0fch,0c4h,012h,0c4h,0c4h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,0c4h,0f1h,0f1h,0c4h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,0c4h,0c4h,0c4h,0c4h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h

BOX1 EECS205BITMAP <20, 20, 012h,, offset BOX1 + sizeof BOX1>
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,012h,012h,012h,012h,012h,000h,072h
	BYTE 072h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,072h,072h,000h,012h,012h
	BYTE 012h,012h,000h,096h,0bbh,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0bbh
	BYTE 096h,000h,012h,012h,012h,012h,000h,0bbh,0dfh,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h
	BYTE 0f2h,0f2h,0f2h,0dfh,0bbh,000h,012h,012h,012h,012h,000h,0dfh,0dfh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dfh,0dfh,000h,012h,012h,012h,012h,000h,0bbh
	BYTE 0dfh,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0dfh,0bbh,000h,012h,012h
	BYTE 012h,012h,000h,096h,0bbh,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0bbh
	BYTE 096h,000h,012h,012h,012h,012h,000h,096h,096h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,096h,096h,000h,012h,012h,012h,012h,000h,072h,096h,096h,096h,096h
	BYTE 096h,096h,096h,096h,096h,096h,096h,096h,072h,000h,012h,012h,012h,012h,000h,072h
	BYTE 072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,000h,012h,012h
	BYTE 012h,012h,000h,000h,000h,000h,000h,000h,072h,0bbh,096h,072h,000h,000h,000h,000h
	BYTE 000h,000h,012h,012h,012h,012h,000h,096h,096h,0a0h,0e0h,0e0h,000h,072h,072h,000h
	BYTE 0e0h,0e0h,0a0h,096h,096h,000h,012h,012h,012h,012h,000h,072h,072h,0a0h,0a0h,0a0h
	BYTE 0a0h,000h,000h,0a0h,0a0h,0a0h,0a0h,072h,072h,000h,012h,012h,012h,012h,000h,072h
	BYTE 072h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,072h,072h,000h,012h,012h
	BYTE 012h,012h,000h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h
	BYTE 072h,000h,012h,012h,012h,012h,012h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h

BOX2 EECS205BITMAP <20, 20, 012h,, offset BOX2 + sizeof BOX2>
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,012h,012h,012h,012h,012h,000h,030h
	BYTE 030h,088h,088h,088h,088h,088h,088h,088h,088h,088h,088h,030h,030h,000h,012h,012h
	BYTE 012h,012h,000h,054h,079h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,079h
	BYTE 054h,000h,012h,012h,012h,012h,000h,079h,0deh,0fch,0fch,0fch,0fch,0fch,0fch,0fch
	BYTE 0fch,0fch,0fch,0deh,079h,000h,012h,012h,012h,012h,000h,0deh,0deh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0deh,0deh,000h,012h,012h,012h,012h,000h,079h
	BYTE 0deh,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0deh,079h,000h,012h,012h
	BYTE 012h,012h,000h,054h,079h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,079h
	BYTE 054h,000h,012h,012h,012h,012h,000h,054h,054h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h,0d0h
	BYTE 0d0h,0d0h,0d0h,054h,054h,000h,012h,012h,012h,012h,000h,030h,054h,054h,054h,054h
	BYTE 054h,054h,054h,054h,054h,054h,054h,054h,030h,000h,012h,012h,012h,012h,000h,030h
	BYTE 030h,030h,030h,030h,030h,030h,030h,030h,030h,030h,030h,030h,030h,000h,012h,012h
	BYTE 012h,012h,000h,000h,000h,000h,000h,000h,030h,079h,054h,030h,000h,000h,000h,000h
	BYTE 000h,000h,012h,012h,012h,012h,000h,054h,054h,088h,0d0h,0d0h,000h,030h,030h,000h
	BYTE 0d0h,0d0h,088h,054h,054h,000h,012h,012h,012h,012h,000h,030h,030h,088h,088h,088h
	BYTE 088h,000h,000h,088h,088h,088h,088h,030h,030h,000h,012h,012h,012h,012h,000h,030h
	BYTE 030h,088h,088h,088h,088h,088h,088h,088h,088h,088h,088h,030h,030h,000h,012h,012h
	BYTE 012h,012h,000h,030h,030h,030h,030h,030h,030h,030h,030h,030h,030h,030h,030h,030h
	BYTE 030h,000h,012h,012h,012h,012h,012h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h

BOX3 EECS205BITMAP <20, 20, 012h,, offset BOX3 + sizeof BOX3>
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,012h,012h,012h,012h,012h,000h,072h
	BYTE 072h,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,072h,072h,000h,012h,012h
	BYTE 012h,012h,000h,096h,0bbh,013h,013h,013h,013h,013h,013h,013h,013h,013h,013h,0bbh
	BYTE 096h,000h,012h,012h,012h,012h,000h,0bbh,0dfh,09bh,09bh,09bh,09bh,09bh,09bh,09bh
	BYTE 09bh,09bh,09bh,0dfh,0bbh,000h,012h,012h,012h,012h,000h,0dfh,0dfh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dfh,0dfh,000h,012h,012h,012h,012h,000h,0bbh
	BYTE 0dfh,09bh,09bh,09bh,09bh,09bh,09bh,09bh,09bh,09bh,09bh,0dfh,0bbh,000h,012h,012h
	BYTE 012h,012h,000h,096h,0bbh,013h,013h,013h,013h,013h,013h,013h,013h,013h,013h,0bbh
	BYTE 096h,000h,012h,012h,012h,012h,000h,096h,096h,013h,013h,013h,013h,013h,013h,013h
	BYTE 013h,013h,013h,096h,096h,000h,012h,012h,012h,012h,000h,072h,096h,096h,096h,096h
	BYTE 096h,096h,096h,096h,096h,096h,096h,096h,072h,000h,012h,012h,012h,012h,000h,072h
	BYTE 072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,000h,012h,012h
	BYTE 012h,012h,000h,000h,000h,000h,000h,000h,072h,0bbh,096h,072h,000h,000h,000h,000h
	BYTE 000h,000h,012h,012h,012h,012h,000h,096h,096h,00eh,013h,013h,000h,072h,072h,000h
	BYTE 013h,013h,00eh,096h,096h,000h,012h,012h,012h,012h,000h,072h,072h,00eh,00eh,00eh
	BYTE 00eh,000h,000h,00eh,00eh,00eh,00eh,072h,072h,000h,012h,012h,012h,012h,000h,072h
	BYTE 072h,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,00eh,072h,072h,000h,012h,012h
	BYTE 012h,012h,000h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h,072h
	BYTE 072h,000h,012h,012h,012h,012h,012h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h
	BYTE 012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h,012h



.CODE

END