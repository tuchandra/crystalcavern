; #########################################################################
;
;   game.inc - Includes for EECS205 Assignment 4/5
;
;
; #########################################################################

;; Mouse information
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

;; Assorted mouse keys
MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;; Library functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD

;; Pokemon sprites
EXTERNDEF PKMN1:EECS205BITMAP
EXTERNDEF PKMN2:EECS205BITMAP
EXTERNDEF PKMN3:EECS205BITMAP

;; Type definitions
FXPT TYPEDEF SDWORD

;; Grid size (number of squares, +1 for the exclusive random upper bound)
GRIDX = 26 + 1
GRIDY = 18 + 1

;; Definition for MONSTER (Pokemon wandering on map)
;; sprite: DWORD pointer to EECS205BITMAP
;; (posX, posY) - FXPT coordinates
;; health, etc.
_MONSTER STRUCT
    sprite DWORD    ?
    posX   FXPT     ?
    posY   FXPT     ?
_MONSTER ENDS

MONSTER TYPEDEF _MONSTER

;; User defined functions
GameInit PROTO
GamePlay PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP