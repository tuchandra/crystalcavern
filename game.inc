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

;; Sprites
EXTERNDEF MOUSE:EECS205BITMAP

EXTERNDEF PKMN1:EECS205BITMAP

EXTERNDEF PKMN2_UP:EECS205BITMAP
EXTERNDEF PKMN2_DOWN:EECS205BITMAP
EXTERNDEF PKMN2_LEFT:EECS205BITMAP
EXTERNDEF PKMN2_RIGHT:EECS205BITMAP

EXTERNDEF PKMN3:EECS205BITMAP

EXTERNDEF ATTK1:EECS205BITMAP

EXTERNDEF BOX1:EECS205BITMAP
EXTERNDEF BOX2:EECS205BITMAP
EXTERNDEF BOX3:EECS205BITMAP

;; Type definitions
FXPT TYPEDEF SDWORD

;; Grid size (number of squares, +1 for the exclusive random upper bound)
GRIDX = 25 + 1
GRIDY = 18 + 1

;; Definition for MONSTER (Pokemon wandering on map)
;; bitmap       DWORD pointer to the current bitmap
;; bitmap_(dir) DWORD pointer to an EECS205BITMAP for each direction (up, down, left, right)
;; active       DWORD, but 0 or 1 for whether should be rendered
;; disappear    DWORD for frames until it disappears (-1 = never)
;; (posX, posY) FXPT position coordinates
;; direction    DWORD, but 0 (up), 1 (down), 2 (left), 3 (right)
;; (velX, velY) FXPT velocity
;; TODO health, etc.
_SPRITE STRUCT
    bitmap          DWORD   ?
    bitmap_up       DWORD   ?
    bitmap_down     DWORD   ?
    bitmap_left     DWORD   ?
    bitmap_right    DWORD   ?
    direction       DWORD   ?

    active          DWORD    1
    disappear       DWORD   -1
    
    posX            FXPT    ?
    posY            FXPT    ?
    rotation        FXPT    0
    velX            FXPT    ?
    velY            FXPT    ?
_SPRITE ENDS

SPRITE TYPEDEF _SPRITE

;; User defined functions
GameInit PROTO
GamePlay PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP