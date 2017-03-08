; #########################################################################
;
;   game.inc - Includes for EECS205 Assignment 4/5
;
;
; #########################################################################

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mouse information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Assorted mouse keys
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Misc. functions and declarations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; User defined functions
GameInit PROTO
GamePlay PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP

;; Library functions
BlackStarField  PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD

;; Type definitions
FXPT TYPEDEF SDWORD

;; Grid size (number of squares, +1 for the exclusive random upper bound)
GRIDX = 25 + 1
GRIDY = 17 + 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bitmaps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EXTERNDEF MAP1:EECS205BITMAP
EXTERNDEF MAPINFO1:BYTE

;; Bulbasaur
EXTERNDEF PKMN1_UP:EECS205BITMAP
EXTERNDEF PKMN1_DOWN:EECS205BITMAP
EXTERNDEF PKMN1_LEFT:EECS205BITMAP
EXTERNDEF PKMN1_RIGHT:EECS205BITMAP

;; Charmander
EXTERNDEF PKMN2_UP:EECS205BITMAP
EXTERNDEF PKMN2_DOWN:EECS205BITMAP
EXTERNDEF PKMN2_LEFT:EECS205BITMAP
EXTERNDEF PKMN2_RIGHT:EECS205BITMAP

;; Squirtle
EXTERNDEF PKMN3_UP:EECS205BITMAP
EXTERNDEF PKMN3_DOWN:EECS205BITMAP
EXTERNDEF PKMN3_LEFT:EECS205BITMAP
EXTERNDEF PKMN3_RIGHT:EECS205BITMAP

EXTERNDEF ATTK1:EECS205BITMAP

EXTERNDEF BOX1:EECS205BITMAP
EXTERNDEF BOX2:EECS205BITMAP
EXTERNDEF BOX3:EECS205BITMAP
EXTERNDEF BOX4:EECS205BITMAP
EXTERNDEF BOX5:EECS205BITMAP
EXTERNDEF BOX6:EECS205BITMAP
EXTERNDEF BOX7:EECS205BITMAP
EXTERNDEF BOX8:EECS205BITMAP
EXTERNDEF BOX9:EECS205BITMAP
EXTERNDEF BOX10:EECS205BITMAP
EXTERNDEF BOX11:EECS205BITMAP
EXTERNDEF BOX12:EECS205BITMAP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprite definitions
;; TODO health, etc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_SPRITE STRUCT
    ;; bitmap: DWORD pointer to current bitmap
    ;; direction: DWORD, but restricted to 0 (up), 1 (down), 2 (left), 3 (right)
    bitmap          DWORD   ?
    direction       DWORD   ?

    ;; bitmap_dir: DWORD pointer to the bitmaps for sprites facing each direction
    bitmap_up       DWORD   ?
    bitmap_down     DWORD   ?
    bitmap_left     DWORD   ?
    bitmap_right    DWORD   ?

    ;; active: DWORD, but restricted to 0 (inactive) or 1 (active)
    ;;         controls whether or not sprite is handled in game logic
    ;; disappear: DWORD, number of frames until sprite disappears (-1 = never)
    active          DWORD    1
    disappear       DWORD   -1

    ;; move_cooldown: DWORD, number of frames until sprite can move again
    move_cooldown   DWORD    0

    ;; health: DWORD, amount of health remaining
    health          DWORD   10
    
    ;; (posX, posY): grid position coordinates
    ;;               stored relative to a current level
    posX            DWORD    ?
    posY            DWORD    ?

    ;; (velX, velY): velocity vector
    velX            DWORD    ?
    velY            DWORD    ?
_SPRITE ENDS

SPRITE TYPEDEF _SPRITE