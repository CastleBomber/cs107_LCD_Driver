;******************************************************************************
; CS 107: Computer Architecture and Organization
;
; Project: LCDDriver
; Filename: main.s
; Author: Leonard Euler
;
; Editor: Richie Romero Castillo
; Semester: Spring 2019
;
; Description: 
; program uses a device driver to send two strings to LCD display.
;
;******************************************************************************		

; 5th item to work on

BACKLIGHT_ON	EQU	0x01
BACKLIGHT_OFF	EQU	0x00
	
				AREA    SBCCCODE, CODE
					
				IMPORT	__initial_sp
				IMPORT	LCD_INIT
				IMPORT  LCD_BACKLIGHT
				IMPORT	WRITE_CSTRING

start			PROC
				EXPORT  start					[WEAK]
					
				; Configure the stack
				LDR		sp, =__initial_sp
				LDR		r5, =__initial_sp			; give me juicy info

				; Configure the LCD Hardware
				BL		LCD_INIT
				
				; Turn on the LCD Backlight
				MOV		r0, #BACKLIGHT_ON			; 16-bit
				PUSH	{r0}						; preserve r0 for..?
				BL		LCD_BACKLIGHT
				POP		{r0}						; what gets popped into r0?
				
				; Write first string on first line.
				MOV		r4, #0
				LDR		r5, =cstring0
				BL		WRITE_CSTRING
				
				; Write second string on second line.
				MOV		r4, #1
				LDR		r5, =cstring1
				BL		WRITE_CSTRING

				; Loop forever
				B       .
				ENDP

; Leave this first string
cstring0		DCB		"CS107 LCD Driver", 0
; Change this to as much of your name as will fit.
; Be sure to leave the first three characters "by ".
cstring1		DCB		"by Richie CBombs", 0
				END
