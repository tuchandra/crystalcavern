; #########################################################################
;
;   grid.inc - Grid functions for EECS205 Assignment 4/5
;
;
; #########################################################################

_LEVEL STRUCT
    ;; bitmap: DWORD pointer to map bitmap
    ;;         this also contains width and height

    bitmap      DWORD   ?

    ;; (sizeX, sizeY): DWORD dimensions of size of bitmap, in grid squares
    ;;                 should equal bitmap.dwWidth / 24 and btimap.dwHeight / 24
    ;;                 but this is easier

    sizeX       DWORD   ?
    sizeY       DWORD   ?

    ;; info: DWORD pointer to a byte array that contains all info about map
    ;; Each byte represents one square, indexed the same way the screen is
    ;; Bits are indexed 76543210
    ;; bit 0: walkable?
    ;;         - set if ground (player can walk on that square)
    ;;         - clear otherwise (player cannot walk there)
    ;; bit 1: occupied?
    ;;         - is there something here already?
    ;;         - set if not empty
    ;;         - clear if space is empty (nothing on it) or not ground
    ;;         -> to walk somewhere, need bit 0 set, bit 1 clear
    ;; ...
    
    info        DWORD   ?

    ;; (offsetX, offsetY) are grid coordinates of top-left visible square
    offsetX     DWORD   ?
    offsetY     DWORD   ?

    ;; other things?

_LEVEL ENDS

LEVEL TYPEDEF _LEVEL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GridToDWORD PROTO coord:DWORD
GridToFixed PROTO coord:DWORD
LevelInfoSetBit PROTO x:DWORD, y:DWORD, level:LEVEL, bit:DWORD
LevelInfoClearBit PROTO x:DWORD, y:DWORD, level:LEVEL, bit:DWORD
LevelInfoTestBit PROTO x:DWORD, y:DWORD, level:LEVEL, bit:DWORD
RenderLevel PROTO level:LEVEL