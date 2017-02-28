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

PKMN1 EECS205BITMAP <24, 24, 255, , offset PKMN1 + sizeof PKMN1>
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h
	BYTE 049h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,099h,099h,099h,049h,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,071h
	BYTE 099h,071h,049h,049h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,049h,049h,071h,06dh,071h,06dh,071h,06dh,071h,049h,049h,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,071h,071h,071h,06dh
	BYTE 071h,06dh,071h,071h,06dh,071h,071h,049h,0ffh,0ffh,049h,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,049h,071h,071h,071h,06dh,071h,071h,06dh,071h,071h,071h,06dh,071h,049h
	BYTE 049h,049h,099h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,071h,071h,06dh,071h,071h
	BYTE 071h,071h,06dh,071h,071h,049h,049h,071h,099h,099h,099h,049h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,049h,071h,071h,06dh,071h,071h,071h,071h,06dh,071h,049h,071h,071h,099h
	BYTE 099h,099h,099h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,071h,06dh,071h,071h
	BYTE 071h,049h,049h,049h,071h,099h,071h,071h,099h,071h,099h,099h,049h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,049h,071h,049h,049h,06dh,071h,071h,049h,099h,099h,099h,099h,099h,099h
	BYTE 099h,099h,099h,071h,049h,049h,0ffh,0ffh,0ffh,0ffh,049h,071h,071h,071h,049h,049h
	BYTE 049h,071h,049h,099h,099h,099h,099h,071h,099h,099h,099h,071h,049h,049h,0ffh,0ffh
	BYTE 0ffh,0ffh,049h,0b6h,071h,049h,071h,071h,071h,071h,071h,099h,099h,049h,049h,099h
	BYTE 071h,099h,099h,099h,099h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,06dh,06dh,071h,06dh
	BYTE 071h,06dh,071h,099h,0ffh,0ffh,0e8h,049h,099h,099h,099h,099h,071h,049h,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,071h,071h,071h,06dh,071h,099h,0ffh,0e8h,049h
	BYTE 099h,099h,099h,071h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,071h
	BYTE 071h,071h,071h,06dh,071h,071h,071h,071h,071h,071h,06dh,06dh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,0ffh,071h,0ffh,06dh,06dh,06dh,06dh,06dh,06dh
	BYTE 06dh,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh
	BYTE 06dh,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh

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



.CODE

END