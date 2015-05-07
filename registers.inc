;Include guard
.ifndef REGISTERS
.def REGISTERS=R0

;Registers
.def	SREG_SAVER = R1
.def	TP_KEY		= R2
.def	TM_KEY		= R3
.def	START_KEY	= R4
.def	GX	= R16	;General Purpose X
.def	GY  = R17	;General Purpose Y
.def	ARG1	= R18	;Argument 1
.def	ARG2	= R19	;Argument 2
.def	RETURN	= R20	;Return value
.def	MSEC	= R21	;500ms
.def	SEC_L	= R22	;Second L
.def	SEC_H	= R23	;Second H
.def	MIN_L	= R24	;Minute L
.def	MIN_H	= R25	;Minute H

.endif
