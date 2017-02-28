; #########################################################################
;
;   trig.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################

FXPT TYPEDEF SDWORD

EXTERNDEF SINTAB:WORD

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943                ;;  PI / 2
PI =  205887                    ;;  PI 
TWO_PI  = 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353         ;;  Use reciprocal to find the table entry for a given angle
                                ;;  256 / PI
                                ;;  (It is easier to use than divison would be)



FixedSin PROTO STDCALL angle:FXPT
FixedCos PROTO STDCALL angle:FXPT