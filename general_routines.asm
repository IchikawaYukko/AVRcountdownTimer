.include "registers.inc"

WAIT:
		DEC ARG1
		BRNE WAIT	;JP NZ,WAIT
		RET

WAIT16:
		;16bits WAIT
		;ZH:ZL = wait length.
		SBIW ZH:ZL,1
		BRNE WAIT16	;if(Z != 0) goto WAIT16
		RET
