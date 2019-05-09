;******************************************************************************
; CS 107: Computer Architecture and Organization
;
; Project: L03_LCD
; Filename: lcd.s
; Author: Leonard Euler
;
; Editor: Richie Romero Castillo
; Semester: Spring 2019
; token/ password: 2ab4e29a2247cbc29c9445a33fc7e501827bdc29 
;
; Description: 
; This is the driver routines for the LCD Keypad Shield. 
; The pinouts for board are as follows:
;
;  | LCD Hardware | Arduino Pin | LPC 4088 Port |
;  |:------------:|:-----------:|:-------------:|
;  |     D4       |     D4      |      P0.5     |
;  |     D5       |     D5      |      P5.0     |
;  |     D6       |     D6      |      P5.1     |
;  |     D7       |     D7      |      P0.4     |
;  |     RS       |     D8      |      P5.3     |
;  |     E        |     D9      |      P5.4     |
;  |  Backlight   |    D10      |      P0.6     |
;  |  Buttons     |    A0       |      P0.23    |
;
;******************************************************************************		
BACKLIGHT_ON	EQU	0x01
BACKLIGHT_OFF	EQU	0x00
SET_LOW			EQU	0x00
SET_HIGH		EQU	0x01

GPIO_BASE	EQU 0x20098000
SET0		EQU	0x018
CLR0		EQU	0x01C
CLR1		EQU	0x03C
SET5		EQU	0x0B8
CLR5		EQU	0x0BC
	
; my EQU's
DIR0		EQU 0x000 ; GPIO Port0 Direction control register
DIR5		EQU 0x0A0 ; GPIO Port5 
	
				AREA    LCDCODE, CODE
				IMPORT	DELAY_1_MS
				IMPORT	DELAY_2_MS
				IMPORT	DELAY_5_MS
				IMPORT	DELAY_15_MS
				IMPORT	DELAY_20_MS
					
;******************************************************************************		
; Initializes the LCD hardware. 
;
; void LCD_INIT()
;
; D4 - D7 are I/O, RS, E, RW, && backlight 
; are digital I/O outputs only.
;
; All I/O pins are outputs because 
; the LCD Keypad Shield has the R/W* pin grounded
; so you can only write to it. 
;
; Once the pins (&& ports) are setup 
; you need to program a sequence 
; based on the one shown in Figure 24 (pg46).
;
; Fun fact: MOVW must be FIRST, then MOVT SECOND
;******************************************************************************		
LCD_INIT		PROC
				EXPORT  LCD_INIT					[WEAK]
				
				PUSH	{r0-r5, LR}
				
				BL		DELAY_20_MS
				BL		DELAY_20_MS
				
				LDR		r0, =0x0				; FUNC: 000 - Digital I/O pin
												; MODE:  00 - No pullup/pulldown
												; IOCON reg -> GPIO reg, done @ bit-banded aliases
				
												; >> Configure IOCON << ;
				LDR		r1, =0x4002C014			; D4 ~ P0[5]: 0x4002 C014
				LDR		r2, =0x4002C280			; D5 ~ P5[0]: 0x4002 C280
				LDR		r3, =0x4002C284			; D6 ~ P5[1]: 0x4002 C284
				LDR		r4, =0x4002C010			; D7 ~ P0[4]: 0x4002 C010
				STR		r0, [r1]
				STR		r0, [r2]
				STR		r0, [r3]
				STR		r0, [r4]
				
				LDR		r1, =0x4002C28C			; RS ~ P5[3]: 0x4002 C28C
				LDR		r2, =0x4002C290			; E ~ P5[4]: 0x4002 C290 (Type I)
				LDR		r3, =0x4002C018			; Backlight ~ P0[6]: 0x4002 C018
				LDR		r4, =0x4002C05C			; Buttons ~ P0[23]: 0x4002 C05C
				STR		r0, [r1]
				STR		r0, [r2]
				STR		r0, [r3]
				STR		r0, [r4]

				LDR		r1, =GPIO_BASE			; >> Configure Port DIR << ;
				LDR		r0, =0x800070 
				STR		r0, [r1, #DIR0] 		; sets P0[4,5,6, 23] as OUTPUT
				LDR		r0, =0x1B
				STR		r0, [r1, #DIR5] 		; sets P5[0,1,3,4] as OUTPUT
				
				BL		DELAY_20_MS
				
				LDR		r4, =0x03				; >> Function Set (I/F 8 bits) << ;
				PUSH	{r4}
				BL 		WRITE_COMMAND
				POP		{r4}
				BL		DELAY_15_MS
				
				LDR		r4, =0x03
				PUSH	{r4}
				BL		WRITE_COMMAND
				POP		{r4}
				BL		DELAY_15_MS

				LDR		r4, =0x03
				PUSH	{r4}
				BL		WRITE_COMMAND
				POP		{r4}
				BL		DELAY_15_MS
				
				LDR		r4, =0x02
				PUSH	{r4}
				BL		WRITE_COMMAND
				POP		{r4}
				BL		DELAY_15_MS
				
				LDR		r4, =0x28
				PUSH	{r4}
				BL		WRITE_COMMAND
				POP		{r4}
				BL		DELAY_15_MS
				
				;LDR		r4, =0x08
				LDR		r4, =0x0F							; why???
				PUSH	{r4}
				BL		WRITE_COMMAND
				POP		{r4}
				BL		DELAY_15_MS
				
				LDR		r4, =0x01
				PUSH	{r4}
				BL		WRITE_COMMAND
				POP		{r4}
				BL		DELAY_15_MS
				
				LDR		r4, =0x06
				PUSH	{r4}
				BL		WRITE_COMMAND
				POP		{r4}
				BL		DELAY_15_MS
				
				
			
				POP		{r0-r5, PC}

				ENDP

;******************************************************************************		
; Writes a string to the 1st || 2nd line of LCD Keypad Shield.
;
; void WRITE_CSTRING(uchar_32 line, char *string)
;
; r4 contains 
; 			which line with 0 being the top line && 
;							1 the bottom. 
;
; r5 contains
; 			the address of the 1st character to be output. 
;
; When writing a character 
; be sure to wait 2 ms b/n characters.
;******************************************************************************		
WRITE_CSTRING	PROC
				EXPORT  WRITE_CSTRING					[WEAK]

				PUSH	{r0-r5, LR}
				
				LDR		r1, =0x0				; position throught lines
				CMP		r4, #0
				MOVEQ	r4, #0x80				; why???
				MOVNE	r4, #0xC0				; why???
				PUSH	{r4}
				BL		DELAY_2_MS
				BL		WRITE_COMMAND
				BL		DELAY_2_MS
				POP		{r4}

first_line
				LDRB	r4, [r5, r1]			; r4 holds char (byte)
				PUSH	{r4}
				BL		DELAY_2_MS
				BL		WRITE_DATA
				BL		DELAY_2_MS
				POP		{r4}
				CBZ		r4, OUT
				ADD		r1, r1, #1
				B		first_line
				
;second_line
				;LDRB	r4, [r5, r1]
				;BL		WRITE_COMMAND
				;B		DELAY_2_MS
				;CBZ		r4, OUT
				;ADD		r1, r1, #1
				;B		second_line
				
OUT				
				POP		{r0-r5, PC}
				
				ENDP


;******************************************************************************		
; Writes a command byte to the LCD Keypad Shield
;
; void WRITE_COMMAND(uint_32 value)
; 			~similar to write_data
;
; r4 contains
; 		the value to write. 
;
; This routine simply sets the RS signal &&
; calls WRITE_BYTE.
;
;******************************************************************************		
WRITE_COMMAND	PROC
				EXPORT  WRITE_COMMAND					[WEAK]

				; 4-bit commands
				PUSH	{r0-r5, LR}
				
				LDR		r4, [SP, #28]			; r4 holds nybbles to write
				
				LDR		r0, =SET_LOW
				PUSH	{r0}
				BL		SET_RS					; RS as LOW (write to command reg)
				POP		{r0}
				
				
				PUSH	{r4}
				BL		DELAY_2_MS
				BL		WRITE_BYTE
				BL		DELAY_2_MS
				POP		{r4}
		
				POP		{r0-r5, PC}
				
				ENDP

;******************************************************************************		
; Writes a data byte (ex: 0x00)
; to the LCD Keypad Shield
;
; void WRITE_DATA(uint_32 value)
; 			~similar to write_command
;
; r4 contains
;			the value to write. 
;
; This routine simply sets the RS signal &&
; calls WRITE_BYTE.
;******************************************************************************		
WRITE_DATA		PROC
				EXPORT  WRITE_DATA					[WEAK]
				
				PUSH	{r0-r5, LR}
				
				LDR		r4, [SP, #28]			; r4 holds nybbles to write
	
				LDR		r0, =SET_HIGH
				PUSH	{r0}
				BL		SET_RS					; RS as HIGH (write to data reg)
				POP		{r0}
				
				
				PUSH	{r4}
				BL		DELAY_2_MS
				BL		WRITE_BYTE
				BL		DELAY_2_MS
				POP		{r4}
		
				POP		{r0-r5, PC}

				ENDP

;******************************************************************************		
; Writes a byte to the LCD Keypad Shield
;
; void WRITE_BYTE(uint_32 value)
;
; r4 contains
; 			the value to write. 
;
; We should set the RS signal before 
; calling this routine (Done in WRITE_DATA). 
;
; Setting RS to LOW 
; gives us a command && 
; setting RS to HIGH
; gives us a data command. 
;
; Since our LCD Keypad Shield is using a 4-bit interface 
; we need to send out the MS nybble first 
; followed by the LS nybble.
;******************************************************************************		
WRITE_BYTE		PROC
				EXPORT  WRITE_BYTE					[WEAK]
				
				PUSH	{r0-r5, LR}
				
				LDR		r4, [SP, #28]			; r4 holds nybbles to write
				
				LSR		r1, r4, #4				; upper nybble
				PUSH	{r1}
				BL		WRITE_LS_NYBBLE
				POP		{r1}
				
				AND		r2, r4, #0x0F			; lower nybble
				PUSH	{r2}
				BL		WRITE_LS_NYBBLE
				POP		{r2}
				
				POP		{r0-r5, PC}
				
				ENDP

;******************************************************************************		
; Writes the LS nybble to the LCD Keypad Shield.
;
; void WRITE_LS_NYBBLE(uint_32 value)
;
; r4 contains
; 			the value to write. 
;
; It is assumed that the RS line has already
; been set to the proper value. 
;
; Be sure to set E to HIGH, 
; output the data, &&
; set E to LOW 
; to write the data to the LCD Keypad Shield.
;******************************************************************************		
WRITE_LS_NYBBLE	PROC
				EXPORT  WRITE_LS_NYBBLE					[WEAK]
				
				PUSH	{r0-r5, LR}
				
				LDR		r0, =SET_HIGH
				PUSH	{r0}
				BL		SET_E					; E as HIGH, ready to output data (D7-D4)
				POP		{r0}
				
				LDR		r4, [SP, #28]			; r4 holds UPPER || LOWER nybble to write
				LDR		r0, =GPIO_BASE
				
				AND		r1, r4, #0x6			; Port 5 spots: 1[11]1
				LDR		r2, =0x0				; used for SETx
				LDR		r3, =0x0				; used for CLRx
				LSR		r1, r1, #1
				LSRS	r1, r1, #1
				ADDCS	r2, r2, #0x1			; D5 ~ @P5[0]
				ADDCC	r3, r3, #0x1			; first pin spot 
				LSRS	r1, r1, #1
				ADDCS	r2, r2, #0x2			; D6 ~ @P5[1]
				ADDCC	r3, r3, #0x2			; second pin spot
				STR		r2, [r0, #SET5]
				STR		r3, [r0, #CLR5]
				
				
				AND		r1, r4, #0x9			; Port 0 spots: [0]00[0]
				LDR		r2, =0x0				; used for SETx
				LDR		r3, =0x0				; used for CLRx
				LSRS	r1, r1, #1
				ADDCS	r2, r2, #0x20			; D4 ~ @P0[5]
				ADDCC	r3, r3, #0x20			; sixth pin spot
				LSR		r1, r1, #2
				LSRS	r1, r1, #1
				ADDCS	r2, r2, #0x10			; D7 ~ @P0[4]
				ADDCC	r3, r3, #0x10			; fifth pin spot
				STR		r2, [r0, #SET0]
				STR		r3, [r0, #CLR0]
				
				LDR		r0, =SET_LOW
				PUSH	{r0}
				BL		SET_E					; E as LOW, sends data (D7-D4)
				POP		{r0}
				
				POP		{r0-r5, PC}

				ENDP

;******************************************************************************		
; Sets the RS data line to the value passed.
;
; void SET_RS(uint_32 status)
;
; r4 contains 
; 		the value to set RS. 
;
; RS is bit P5.3 which is already set to output.
;******************************************************************************		
SET_RS			PROC
				EXPORT  SET_RS					[WEAK]
				
				PUSH	{r0-r5, LR}
				
				LDR		r4, [SP, #28]				; r4 holds SET_HIGH || SET_LOW
				LDR		r0, =GPIO_BASE				; RS ~ P5[3]
				LDR		r1, =0x8					; fourth pin
				
				CMP		r4, #SET_HIGH
				STREQ	r1, [r0, #SET5]
				STRNE	r1, [r0, #CLR5]
				
				POP		{r0-r5, PC}

				ENDP

;******************************************************************************		
; Sets the E data line to the value passed.
;
; void SET_E(uint_32 status)
;
; r4 contains
; 		the value to set E. 
;
; E is bit P5.4 which is already set to output.
;******************************************************************************		
SET_E			PROC
				EXPORT  SET_E					[WEAK]
				
				PUSH	{r0-r5, LR}
				
				LDR 	r4, [SP, #28]			; r4 holds ON || OFF
				LDR		r0, =GPIO_BASE			; E ~ P5[4]: 0x4002 C290 (Type I)
				LDR		r1, =0x10				; sixth pin
				
				CMP		r4, #SET_HIGH
				STREQ 	r1, [r0, #SET5]
				STRNE	r1, [r0, #CLR5]
				
				POP		{r0-r5, PC}
				
				ENDP

;******************************************************************************		
; Turns on || off the LCD backlight. 
;
; The parameter status is passed on the stack.
;
; void LCD_BACKLIGHT(int status)
;
; status - 1 turn on backlight, 
;		 - 0 turn off backlight
;******************************************************************************		
LCD_BACKLIGHT	PROC
				EXPORT  LCD_BACKLIGHT					[WEAK]
				
				PUSH	{r0-r5, LR}
				
				LDR		r0, [SP, #28]			; r0 holds ON || OFF
				LDR 	r1, =GPIO_BASE			; Backlight ~ P0[6]: 0x4002 C018
				LDR		r2, =0x40
				
				CMP		r0, #SET_HIGH
				STREQ	r2, [r1, #SET0]
				STRNE	r2, [r1, #CLR0]
				
				POP		{r0-r5, PC}
				
				ENDP

				END
