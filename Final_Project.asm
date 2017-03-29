;**** Timer **** 
TSCR1 EQU $46
TSCR2 EQU $4D
TIOS  EQU $40
TCTL1 EQU $48
TCTL2 EQU $49
TFLG1 EQU $4E
TIE   EQU $4C
TSCNT EQU $44
TC4	  EQU $58
TC1	  EQU $52
;***************

;*** PORTS **** 
DDRA  EQU $02
PORTA EQU $00
PORTB EQU $01
DDRB  EQU $03
PORTM EQU $0250
DDRM  EQU $0252
;**************

;*** ADC Unit *** 
ATDCTL2	EQU $122
ATDCTL4 EQU $124
ATDCTL5	EQU $125
ADTSTAT0 EQU $126
ATD1DR1H EQU $132
ADT1DR1L EQU $133
;****************

; Include .hc12 directive, in case you need MUL
.hc12

	ORG		$1000
DutyCycle		ds 2
Auto			ds 1

	ORG		$400
	LDS #$4000
	LDAA #%11000000
	STAA ATDCTL2
	JSR Delay1MS
	LDAA #%11100101
	STAA ATDCTL4
	LDAA #%11111111
	STAA DDRA
	LDAA #%10000000
	STAA DDRB
	LDAA #%10000000
	STAA PORTB
	LDAA #$90	
	STAA TSCR1
	LDAA #$03  	
	STAA TSCR2
	LDAA #$02	
	STAA TIOS
	LDAA #$00
	STAA TCTL1
	CLRA
	STAA PORTA
	LDAA #$1
	STAA Auto


TOP:	LDAB PORTA
	CMPB #$00
	BEQ checkInput
	BRA Debounce

Input:	LDAA PORTA
	CBA
	BNE TOP
	CMPA #$11
	BEQ mode1
	CMPA #$12
	BEQ mode2
	CMPA #$14
	BEQ mode3
	CMPA #$21
	BEQ mode4
	CMPA #$22
	BEQ mode5
	CMPA #$24
	BEQ autoOn
	
checkInput:	LDAA Auto
		CMPA #$1
		BEQ mode6
		

Motor:	LDD TSCNT
	ADDD DutyCycle
	STD TC1
	LDAA #$08
	STAA TCTL2
	BRCLR TFLG1,$02,*
	LDD TSCNT
	SUBD DutyCycle
	ADDD #!1024
	STD TC1
	LDAA #$0C
	STAA TCTL2
	BRCLR TFLG1,$02,*
	BRA TOP
	
Delay1MS:	LDAA #$90	
		STAA TSCR1
		LDAA #$03  	
		STAA TSCR2
		LDAA #$10	
		STAA TIOS
		LDAA #$1
		STAA TCTL1
		LDD TSCNT
		ADDD #!1000
		STD TC4
		BRCLR TFLG1,$10,*
		RTS 

Debounce:	LDAA #$90	
		STAA TSCR1
		LDAA #$03  	
		STAA TSCR2
		LDAA #$10	
		STAA TIOS
		LDAA #$1
		STAA TCTL1
		LDD TSCNT
		ADDD #!50000
		STD TC4
		BRCLR TFLG1,$10,*
		BRA Input
		 
Mode1:		CLRA
		STAA Auto
		LDD #!0
		STD DutyCycle
		BRA Motor

Mode2:		CLRA
		STAA Auto
		LDD #!256
		STD DutyCycle
		BRA Motor

Mode3:		CLRA
		STAA Auto
		LDD #!512
		STD DutyCycle
		BRA Motor

Mode4:		CLRA
		STAA Auto
		LDD #!768
		STD DutyCycle
		BRA Motor

Mode5:		CLRA
		STAA Auto
		LDD #!1024
		STD DutyCycle
		BRA Motor

mode6:		LDAA #%10000000
		STAA ATDCTL5
		BRCLR ADTSTAT0,$80,*
		LDAA ADT1DR1L
		LDAB #$4
		MUL
		STD DutyCycle;
		BRA Motor


autoOn:		LDAA #$1
		STAA Auto
		BRA checkInput