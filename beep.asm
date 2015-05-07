;Beeper

.include "registers.inc"

BEEP:
		;ARG1 = beep frequency
		;XH,XL = beep length
		;Port init
		SBI DDRD,DDD2	;PORTD2 set output (BUZZER)
BEEP_LOOP:
		CBI PORTD,PORTD2	;out L

		;WAIT
		PUSH ARG1
		RCALL WAIT
		POP ARG1

		SBI PORTD,PORTD2	;out H

		;WAIT
		PUSH ARG1
		RCALL WAIT
		POP ARG1

		SBIW XH:XL,1
		BRNE BEEP_LOOP	;if(X != 0) goto BEEP_LOOP

		CBI DDRD,DDD2	;PORTD2 set input (START BUTTON)
		RET
