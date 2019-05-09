;******************************************************************************
; CS 107: Computer Architecture and Organization
;
; Project: L03_LCD
; Filename: delay.s
; Author: Leonard Euler
;
; Editor: Richie Romero Castillo
; Semester: Spring 2019
;
; Description: Various delay routines.
;
;******************************************************************************		
	
				AREA    DELAYCODE, CODE

;******************************************************************************		
; Delays for one millisecond.
;
; void DELAY_1_MS()
;
; This is a simple loop which will delay for approximately one millisecond.
; A loop count of 3000 will work.
;******************************************************************************		
DELAY_1_MS		PROC
				EXPORT  DELAY_1_MS					[WEAK]
				; 1st routine to work on
				
				PUSH	{r0-r5, LR}
				MOV		r0, #3000

LoopDelay		CBZ		r0, EXIT
				MOV		r1, r1			; arbitrary
				SUB		r0, r0, #1
				B		LoopDelay

EXIT			POP		{r0-r5, PC}
				
				ENDP

;******************************************************************************		
; Delays for about two milliseconds.
;
; void DELAY_2_MS()
;
; This 2 ms delay is longer than the longest command will take to the LCD
; Keypad display.
;******************************************************************************		
DELAY_2_MS		PROC
				EXPORT  DELAY_2_MS					[WEAK]
				
				; 2nd routine to work on
				
				PUSH	{r0-r5, LR}
				MOV		r0, #6000
				
LoopDelay2		CBZ		r0, EXIT2
				MOV		r1, r1
				SUB		r0, r0, #1
				B		LoopDelay2
				
EXIT2			POP		{r0-r5, PC}
				
				ENDP

;******************************************************************************		
; Delays for about 5 ms.
;
; void DELAY_5_MS()
;
;******************************************************************************	
DELAY_5_MS		PROC
				EXPORT	DELAY_5_MS					[WEAK]
					
				PUSH	{r0-r5, LR}
				MOV		r0, #15000
				
LoopDelay5		CBZ		r0, EXIT5
				MOV		r1, r1
				SUB		r0, r0, #1
				B		LoopDelay5
				
EXIT5			POP		{r0-r5, PC}
				
				ENDP
					
;******************************************************************************		
; Delays for about 15 ms.
;
; void DELAY_15_MS()
;
;******************************************************************************	
DELAY_15_MS		PROC
				EXPORT	DELAY_15_MS					[WEAK]
					
				PUSH	{r0-r5, LR}
				MOV		r0, #45000
				
LoopDelay15		CBZ		r0, EXIT15
				MOV		r1, r1
				SUB		r0, r0, #1
				B		LoopDelay15
				
EXIT15			POP		{r0-r5, PC}
				
				ENDP
					
;******************************************************************************		
; Delays for about 20 ms.
;
; void DELAY_20_MS()
; 
; avoiding delay_40_ms since MOV's 0xFFFF is too little of time
;
;******************************************************************************	
DELAY_20_MS		PROC
				EXPORT	DELAY_20_MS					[WEAK]
				
				PUSH	{r0-r5, LR}
				
				MOV 	r0, #60000
				
LoopDelay20		CBZ		r0, EXIT20
				MOV		r1, r1
				SUB 	r0, r0, #1
				B		LoopDelay20


EXIT20			POP		{r0-r5, PC}
				
				ENDP
				
				END
