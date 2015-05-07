
;.include "2313def.inc"
.include "tn2313def.inc"

;Target Device : AT90S2313 / tiny2313

;Fusebit Settings.
;CKDIV8 = off
;CKSEL = External Crystal 3-8MHz
;BODLEVEL = 1.8V
;
;other fuses are default.

.include "registers.inc"

.org 0x00
		;Interrupt Vectors (90S2313/tiny2313)
		RJMP RESET
		RJMP EXT_INT0
		RJMP EXT_INT1
		RJMP TIM_CAPT1
		RJMP TIM_COMP1
		RJMP TIM_OVF1
		RJMP TIM_OVF0
		RJMP UART_RXC
		RJMP UART_DRE
		RJMP UART_TXC
		RJMP ANA_COMP
		;Interrupt Vectors (tiny2313)
		RJMP PCINT
		RJMP OC1B
		RJMP OC0A
		RJMP OC0B
		RJMP USI_START
		RJMP USI_OVF
		RJMP ERDY
		RJMP WDT

;Register initialize
RESET:
	;----- peripheral initialize -----
		;Set stack pointer
		LDI GX,RAMEND
		OUT SPL,GX

		;PortB/D
		SER GX
		OUT DDRB,GX		;Set DDRB All output
		LDI GX,0b00110011
		OUT DDRD,GX		;Set PortD direction
		LDI GX,(1<<PORTD6)+(1<<PORTD3)+(1<<PORTD2)
		OUT PORTD,GX	;Set PORTD2,3,6 Pullup

		;Timer1
		LDI GX,0x01
		OUT OCR1AH,GX
		LDI GX,0x12
		OUT OCR1AL,GX	;Comp Reg Set 31250(0x7A12)
		;31250 = (4MHz / 64 / 2) = 500ms

		LDI GX,(1<<OCIE1A)	;Comp INT Enable
		OUT TIMSK,GX
	;----- peripheral initialize -----

		;Detect reset type
		IN GX,MCUSR
		SBRS GX,PORF
		RJMP STAGE0	;IF reset by power-on, then beep

		;PowerON beep
		LDI XH,1
		LDI XL,255
		LDI ARG1,192
		RCALL BEEP	;Pi
		LDI XH,1
		LDI XL,255
		LDI ARG1,255
		RCALL BEEP	;Po
STAGE0:	;Powerdown and resume from it
		;Clear PowerON-reset flag
		CLR GX
		OUT MCUSR,GX

		SEI		;INT ENABLE
		RCALL POWERDOWN

		;WAIT after resume
		LDI ZH,0xFF
		LDI ZL,0xFF
		RCALL WAIT16
		LDI ZH,0xFF
		LDI ZL,0xFF
		RCALL WAIT16

		;Set 10:00 (10minute)
		CLR SEC_L
		CLR SEC_H
		CLR MIN_L
		LDI MIN_H,0x01

STAGE1:		;Countdown time setting stage
		RCALL SEG
		RCALL KEYINPUT

		;IF Timer1 started goto Stage 2
		IN GX,TCCR1B
		CPI GX,(1<<WGM12)+(1<<CS11)+(1<<CS10)
		BREQ STAGE2
		RJMP STAGE1
STAGE2:				;Countdown Stage
		;Update 7Segments + LEDs
		RCALL SEG
		RCALL LED

		;IF Timer1 stopped goto Stage 3
		IN GX,TCCR1B
		CPI GX,0b00000000
		BREQ STAGE3
		RJMP STAGE2

STAGE3:				;Alert Stage (Countdown ended)
		;out 0 to 7segment
		SBI PORTD,PORTD0
		SBI PORTD,PORTD1
		SBI PORTD,PORTD4
		CBI PORTD,PORTD5
		LDI GX,SEG0
		OUT PORTB,GX

		;beep
		LDI XH,64
		LDI XL,255
		LDI ARG1,224
		RCALL BEEP
		
		RJMP RESET

.include "general_routines.asm"
.include "bcdto7seg.asm"
.include "key.asm"
.include "beep.asm"
.include "7segment.asm"

POWERDOWN:
		RCALL SEG_ALLOFF
		;INT0 enable
		LDI GX,(1<<INT0)
		OUT GIMSK,GX

		;Powerdown Enable
		LDI GX,(1<<SM0)+(0<<SM1)+(1<<SE)
		OUT MCUCR,GX
		SLEEP	;Powerdown
POWERDOWN_RESUME:
		;Powerdown disable
		LDI GX,(0<<SM0)+(0<<SM1)+(0<<SE)
		OUT MCUCR,GX
		;INT0 disable
		LDI GX,(0<<INT0)
		OUT GIMSK,GX

		RET

LED:
		CPI MSEC,0x01
		BREQ LEDA
		CPI MSEC,0x00
		BREQ LEDB

		RET
LEDA:
		CBI PORTD,PORTD6	;LED data change
		SBI PORTD,PORTD3
		RET
LEDB:
		SBI PORTD,PORTD6	;LED data change
		CBI PORTD,PORTD3
		RET

EXT_INT0:
		IN SREG_SAVER,SREG	;Save SREG
		ADIW XH:XL,1
		CPI XH,0xFF
		BRNE EXT_INT0_RET
		CPI XL,0xFF
		BRNE EXT_INT0_RET

		;LDI,MSEC,0
		LDI SEC_L,1
		LDI SEC_H,0
		LDI MIN_L,0
		LDI MIN_H,0
EXT_INT0_RET:
		OUT SREG,SREG_SAVER	;Restore SREG
		RETI

EXT_INT1:
		RETI
TIM_CAPT1:
TIM_COMP1:		;Interrupt per 500ms
		IN SREG_SAVER,SREG	;Save SREG

		;Decliments second/minute registers
		DEC MSEC
		CPI MSEC,0xFF
		BRNE TIM_CHK
		LDI MSEC,0x01
		DEC SEC_L
		CPI SEC_L,0xFF
		BRNE TIM_CHK
		LDI SEC_L,0x09
		DEC SEC_H
		CPI SEC_H,0xFF
		BRNE TIM_CHK
		LDI SEC_H,0x05
		DEC MIN_L
		CPI MIN_L,0xFF
		BRNE TIM_CHK
		LDI MIN_L,0x09
		DEC MIN_H

TIM_CHK:		;Check MIN_H/L SEC_H/L MSEC == 00000
		CPI SEC_L,0x00
		BRNE TIM_RET
		CPI SEC_H,0x00
		BRNE TIM_RET
		CPI MIN_L,0x00
		BRNE TIM_RET
		CPI MIN_H,0x00
		BRNE TIM_RET

		CLR GX
		OUT TCCR1B,GX	;Timer stop

		;INT0 disable
		LDI GX,(0<<INT0)
		OUT GIMSK,GX

TIM_RET:
		OUT SREG,SREG_SAVER	;Restore SREG
		RETI

TIM_OVF1:
TIM_OVF0:
UART_RXC:
UART_DRE:
UART_TXC:
ANA_COMP:
PCINT:
OC1B:
OC0A:
OC0B:
USI_START:
USI_OVF:
ERDY:
WDT:
		RETI
