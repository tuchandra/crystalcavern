; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;   Tushar Chandra (tac311)
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc
    ;; Left vertical line of N
    invoke DrawStar, 100, 100
    invoke DrawStar, 100, 120
    invoke DrawStar, 100, 140
    invoke DrawStar, 100, 160
    invoke DrawStar, 100, 180
    invoke DrawStar, 100, 200    
    invoke DrawStar, 100, 220
    invoke DrawStar, 100, 240
    invoke DrawStar, 100, 260
    invoke DrawStar, 100, 280
    invoke DrawStar, 100, 300   

    ;; Crossbar of N
    invoke DrawStar, 110, 120
    invoke DrawStar, 120, 140
    invoke DrawStar, 130, 160
    invoke DrawStar, 140, 180
    invoke DrawStar, 150, 200    
    invoke DrawStar, 160, 220
    invoke DrawStar, 170, 240
    invoke DrawStar, 180, 260
    invoke DrawStar, 190, 280
    invoke DrawStar, 200, 300

    ;; Right vertical line of N
    invoke DrawStar, 200, 100
    invoke DrawStar, 200, 120
    invoke DrawStar, 200, 140
    invoke DrawStar, 200, 160
    invoke DrawStar, 200, 180
    invoke DrawStar, 200, 200    
    invoke DrawStar, 200, 220
    invoke DrawStar, 200, 240
    invoke DrawStar, 200, 260
    invoke DrawStar, 200, 280
	
    ret  			; Careful! Don't remove this line
DrawStarField endp



END
