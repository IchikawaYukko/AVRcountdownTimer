;BCD to 7segment convert routine.

.include "registers.inc"

;7segment data
.equ SEG0=0b00000010
.equ SEG1=0b10011110
.equ SEG2=0b00100100
.equ SEG3=0b00001100
.equ SEG4=0b10011000
.equ SEG5=0b01001000
;.equ SEG6=0b01000000
.equ SEG6=0b11000000	;Yet Another 6
;.equ SEG7=0b00011010
.equ SEG7=0b00011110	;Yet Another 7
.equ SEG8=0b00000000
;.equ SEG9=0b00001000
.equ SEG9=0b00011000	;Yet Another 9
.equ SEGBL=0b11111110	;Blank

BCDTOSEG:
		;RETURN = BCDTOSEG(Arg1)
		;ARG1 = BCD
		;RETURN = 7segment data
		CPI ARG1,0x00
		BREQ SEGD0
		CPI ARG1,0x01
		BREQ SEGD1
		CPI ARG1,0x02
		BREQ SEGD2
		CPI ARG1,0x03
		BREQ SEGD3
		CPI ARG1,0x04
		BREQ SEGD4
		CPI ARG1,0x05
		BREQ SEGD5
		CPI ARG1,0x06
		BREQ SEGD6
		CPI ARG1,0x07
		BREQ SEGD7
		CPI ARG1,0x07
		BREQ SEGD7
		CPI ARG1,0x08
		BREQ SEGD8
		CPI ARG1,0x09
		BREQ SEGD9

		;if not match above, set blank.
		LDI RETURN,SEGBL
		RET
SEGD0:
		LDI RETURN,SEG0
		RET
SEGD1:
		LDI RETURN,SEG1
		RET
SEGD2:
		LDI RETURN,SEG2
		RET
SEGD3:
		LDI RETURN,SEG3
		RET
SEGD4:
		LDI RETURN,SEG4
		RET
SEGD5:
		LDI RETURN,SEG5
		RET
SEGD6:
		LDI RETURN,SEG6
		RET
SEGD7:
		LDI RETURN,SEG7
		RET
SEGD8:
		LDI RETURN,SEG8
		RET
SEGD9:
		LDI RETURN,SEG9
		RET
