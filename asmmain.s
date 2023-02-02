	PRESERVE8
	AREA	MyCode, CODE, READONLY
	EXPORT	asmmain

	import LPTMR_DRV_SetTimerPeriodUs
	import LPTMR_DRV_Start
	import ledToggle
	import floatToBCD


my_NVIC_value EQU 0x00000020 ;69
my_NVIC_addr EQU 0xE000E100 ;0xE000E100

my_SIM_SCGC5 EQU 0x40048038
my_GPIOC_clken EQU 0x00000800
	
my_PORTC_PCR0 EQU 0x4004B000 ;which is base address here for PCR0 to PCR10
my_PORTC_PCR_value EQU 0x0000014	
	
my_GPIOC_PDDR EQU 0x400FF094
my_GPIOC_PDDR_value EQU 0x000007FF ; set PTC10 to PTC0 as outputs
	
my_SIM_SCGC6 EQU 0x4004803C
//my_SCGC6_value EQU 0x00800000

my_PIT_LDVAL1 EQU 0x40037110
my_LDVAL1_value EQU 0xC350; ------------FIND VALUE TO CONTROL LENGTH OF TIMER
my_PIT_TCTRL1 EQU 0x40037118
my_PIT_TFLG1 EQU 0x4003711C ;value to reset flag
my_PIT_MCR EQU 0x40037000 ;--------------address---IDK if its right number

;new stuff
mySIM_SCGC6value EQU 0x8C00000
myNVIC_ISER1 EQU 0xE000E104 
myNVIC_ISER1value EQU 0x02000000; 0x02000000
myNVIC_ISER2 EQU 0xE000E108
myNVIC_ISER2value EQU 0x00000100
mySIM_SCGC2 EQU 0x4004802C
mySIM_SCGC2value EQU 0x00001000
mySIM_SOPT7 EQU 0x40048018
mySIM_SOPT7value EQU 0x00000000
myPORTA_PCR7 EQU 0x4004901C
myPORTA_PCR7value EQU 0x00000000
myPDB0_MOD EQU 0x40036004
myPDB0_MODmin EQU 0x1000
myPDB0_IDLY EQU 0x4003600C
myPDB0_IDLYvalue EQU 0x0
myPDB0_CH0C1 EQU 0x40036010
myPDB0_CH0C1value EQU 0x00000101
myPDB0_CH0S EQU 0x40036014
myPDB0_CH0Svalue EQU 0x0
myPDB0_PO0DLY EQU 0x40036194
myPDB0_PO0DLYvalue EQU 0x01001000
myPDB0_POEN EQU 0x40036190
myPDB0_POENvalue EQU 0x01
myPDB0_SC EQU 0x40036000
myPDB0_Scvalue EQU 0x00000F83 //;0xFA3
myPDB0_SWTRG EQU 0x00010000
myPDB0_PDBIF EQU 0xFFFFFFBF
myADC0_CFG1 EQU	0x4003B008
myADC0_CFG1value EQU 0x0000007D
myADC0_CFG2 EQU	0x4003B00C
myADC0_CFG2value EQU 0x0
myADC0_SC2 EQU 0x4003B020
myADC0_SC2value EQU	0x00000040
myADC0_SC3 EQU 0x4003B024
myADC0_SC3value EQU	0x0000000C
myADC0_SC1A EQU	0x4003B000
myADC0_SC1Avalue EQU 0x0000004A
myADC0_RA EQU 0x4003B010
myDAC0_DAT0L EQU 0x400CC000
myDAC0_SR EQU 0x400CC020
	
	
	;EXAMPLE: CONVERT ADC VALUE FOR DISPLAY
vrange EQU 330
bindiv EQU 0xFFFF
ten EQU 10

FLOATNUM EQU 0x401ccccd

asmmain
;------Set PIT timer------------
	LDR r2,=my_SIM_SCGC6		; 0x4004803C
	LDR r1,=mySIM_SCGC6value		; 0x00800000
	LDR r0,[r2]
	ORR r0,r0,r1
	STR r0,[r2]  			;enable clock to PIT1
	LDR r2,=my_PIT_MCR
	MOV r0,#0
	STR r0,[r2]  			;enable the PIT module
	LDR r2,=my_PIT_LDVAL1		; 0x40037110
	LDR r1,=my_LDVAL1_value
	STR r1,[r2]  			;load the count value to generate interrupt periodically
	LDR r2,=my_PIT_TCTRL1		; 0x40037118
	MOV r0,#0x3
	STR r0,[r2]  		 	;set TIE and TEN bits

ADCInitialize
//Configure ADC port clock:
	LDR  r2,=my_SIM_SCGC6 ; 0x4004803C
	LDR  r3,=mySIM_SCGC6value; 0x08400000, here we enable clock for PDB and ADC0
	LDR  r4,[r2]
	ORR  r4,r4,r3
	STR  r4,[r2] 
//Configure DAC port clock:
	LDR r2,=mySIM_SCGC2; 0x4004802C
	LDR r3,=mySIM_SCGC2value; 0x00001000; enable clock for DAC0
	LDR r4,[r2]
	ORR r4,r4,r3
	STR r4,[r2]
//Activate PDB0 
	LDR  r2,=mySIM_SOPT7; 0x40048018
	LDR  r3,=mySIM_SOPT7value; 0x00000000, PDB selected for triggering ADC0
	STR  r3,[r2]
//Set PA7 as input for ADC10
	LDR r2,=myPORTA_PCR7; 0x4004901C
	LDR r3,=myPORTA_PCR7value; 0x00000000, set as analog input
	STR r3,[r2]
	NOP
	NOP
	
PDBConfig
	LDR r2,=myPDB0_MOD; 0x40036004
	LDR r3,=myPDB0_MODmin; 0x1000
	STR r3,[r2]
	LDR r2,=myPDB0_IDLY; 0x4003600C
	LDR r3,=myPDB0_IDLYvalue; 0x0
	STR r3,[r2]
	LDR r2,=myPDB0_CH0C1; 0x40036010
	LDR r3,=myPDB0_CH0C1value; 0x00000101, CH0 pretrigger output is selected and enabled
	STR r3,[r2]
	LDR r2,=myPDB0_POEN; 0x40036190
	LDR r3,=myPDB0_POENvalue; 0x01, PDB pulse out enabled
	STR r3,[r2]
	LDR r2,=myPDB0_PO0DLY; 0x40036194
	LDR r3,=myPDB0_PO0DLYvalue; 0x01001000, sets pulse output to 1 after 0x100 pulses and to 0 after 0x1000 pulses
	STR r3,[r2]
	LDR r2,=myPDB0_SC; 0x40036000
	LDR r3,=myPDB0_Scvalue; 0x00000F83, set prescaler to 0 and MULT to 1
	STR r3,[r2]

ADCConfig
	LDR r2,=myADC0_CFG1; 0x4003B008
	LDR r3,=myADC0_CFG1value; 0x0000007D, divide ratio 8, long sample time, single ended 16bit, bus_clock/2
	STR r3,[r2]
	LDR r2,=myADC0_CFG2; 0x4003B00C
	LDR r3,=myADC0_CFG2value; 0x0, ADxxa channels are selected, default longest sample time
	STR r3,[r2]
	LDR r2,=myADC0_SC2; 0x4003B020
	LDR r3,=myADC0_SC2value; 0x00000040, set the hardware trigger PDB
	STR r3,[r2]
	LDR r2,=myADC0_SC3; 0x4003B024
	LDR r3,=myADC0_SC3value; 0x0000000C, Hardware average function enabled with continuous conversion
	STR r3,[r2]
	LDR r2,=myADC0_SC1A  ; 0x4003B000, need to initiate the ADC module before the PDB module, writing ADC0_SC1A will start the module
	LDR r3,=myADC0_SC1Avalue; 0x0000004A, Interrupt enabled, ADC10 selected as single ended, input from primary connector B40 pin
	STR r3,[r2]
	LDR r2,=myPDB0_SC; 0x40036000
	LDR r3,=myPDB0_SWTRG; 0x00010000, write bit 16 to start counting
	LDR r4,[r2]
	ORR r3,r3,r4
	STR r3,[r2]  ;trigger the PDB0 channel
	
DACConfig ;(OUTPUT SIGNAL AT PRIMARY A32 PIN)
	LDR r2,=myDAC0_DAT0L; 0x400CC000
	MOV r3,#0x0
	STRB r3,[r2],#1
	STRB r3,[r2]  ; clear the DAT0 data values
	LDR r2,=myDAC0_SR; 0x400CC020
	STRB r3,[r2],#1 ;clear flags in SR
	STRB r3,[r2],#1  ;clear C0
	STRB r3,[r2],#1 ;clear C1
	MOV r3,#0x0F
	STRB r3,[r2],#-2 ;initialize C2
	LSL r3,r3,#4  ;set C0 values 
	STRB r3,[r2]  ;start the DAC0, software trigger, use DACREF_2
	
ISR_Enable
	LDR r2,=my_NVIC_value 		; 0x00000020 sets IRQ 69
	LDR r1,=my_NVIC_addr		; 0xE000E100
	STR r2,[r1,#0x8]
NVICConfig
	;activate ADC0_IRQ57
	LDR r2,=myNVIC_ISER1; 0xE000E104
	LDR r3,=myNVIC_ISER1value; 0x02000000, sets bit 25 in NVIC_ISER1for ADC0 interrupt IRQ#57
	LDR r4,[r2]
	ORR r4,r4,r3
	STR r3,[r2]
	; activate PDB0_IRQ72
	LDR r2,=myNVIC_ISER2; 0xE000E108
	LDR r3,=myNVIC_ISER2value; 0x00000100, set bit 8 in NVIC_ISER2 for PDB0 interrupt IRQ#72
	LDR r4,[r2]
	ORR r3,r3,r4
	STR r3,[r2]
	
while
	LDR r3,=currentCounter
	LDR r4,=irqcounter
	LDR r1, [r3]
	LDR r2, [r4]
	CMP r1,r2
	BEQ while
	STR r2, [r3]
	;BL floatBCD
	CMP r1, #0
	BEQ while
	CPSID i
	CMP r1, #1
	BNE next1
	LDR r3, =num1
	LDR r0, [r3]
next1
	CMP r1, #2
	BNE next2
	LDR r3, =num2
	LDR r0, [r3]
next2
	CMP r1, #3
	BNE next3
	LDR r3, =num3
	LDR r0, [r3]
next3
	BL ledToggle
	CPSIE i
	B while


PDB0_IRQHandler EQU asm_PDB0_irq+1
	EXPORT PDB0_IRQHandler

asm_PDB0_irq
	PUSH {lr}  ;store LR, to know how to return from irq
	PUSH {r2-r5}
	LDR r2,=myPDB0_SC; 0x40036000
	LDR r3,=myPDB0_PDBIF; 0xFFFFFFBF to clear PDBIF
	LDR r4,[r2]
	AND r4,r4,r3
	STR r4,[r2]
	LDR r2,=myPDB0_CH0S; 0x40036014 // Channel n Status Register
	LDR r3,=myPDB0_CH0Svalue; 0x0
	STR r3,[r2]
	POP {r2-r5}
	POP {pc}  ;return from interrup

ADC0_IRQHandler EQU asm_ADC0_irq+1; the vector table must contain odd addresses for the Cortex processor
	EXPORT ADC0_IRQHandler
		
asm_ADC0_irq
;COCO is set in ADC0_SC1A when the conversion is done
;this also triggers the interrupt
;see pp 826 in K60 Sub Family Reference Manual
	CPSID i
	PUSH {lr}  ;store LR, to know how to return from irq
	PUSH {r2-r5}
;next read the result register
	LDR r2,=myADC0_RA; 0x4003B010
	LDR r0,[r2]
;next transfer this value to DAC0
	MOV r3,r0,LSR #4
	LDR r2,=myDAC0_DAT0L; 0x400CC000
	STRB r3,[r2],#1 ; should store the 8 lsb bits to DAC0
	LSR r3,r3,#8
	STRB r3,[r2]
	LDR r2,=adc0counter
	LDR r3,[r2]
	ADD r3,r3,#1
	CMP r3,#0x01000 ;I am waiting for 2^12 ADC 

conversions
	BEQ next0
	STR r3,[r2],#4
	LDR r4,[r2]
	ADD r4,r4,r0 ;make the sum for average
	STR r4,[r2]
	BL outofdac0

next0
	MOV r3,#0x1
	STR r3,[r2],#4
	LDR r4,[r2]
	LSR r4,r4,#12  ;here I am dividing by 2^12
	STR r4,[r2]
	MOV r0,r4
	BL adc0tovolts

outofdac0
	CPSIE i
	POP {r2-r5}
	POP {pc}

//convert adc value for display
adc0tovolts
	//LDR r0, =FLOATNUM
	LDR r1, =num1
	LDR r2, =num2
	LDR r3, =num3
	BL floatToBCD 
	B outofdac0

PIT1_IRQHandler EQU asm_pit_irq+1
	EXPORT PIT1_IRQHandler  ;the vector table must contain odd addresses for the Cortex processor

asm_pit_irq
	PUSH {lr}  ;store LR
	PUSH {r2-r5}
	LDR r2,=my_PIT_TFLG1 ; clear the IRQ flag TIF 
	MOV r3,#0x01
	STR r3,[r2]
	LDR r2, =irqcounter; increment the irq counter
	LDRB r3,[r2]
	CMP r3,#3
	BGE start_over
	ADD r3,#1
	BL update_int_cnt
start_over
	MOV r3,#0x01  ;start from digit position 1
update_int_cnt
	STRB r3,[r2]
	POP {r2-r5}
	POP {pc}
	
	ALIGN
	AREA stack1, DATA, READWRITE
irqcounter DCD 0		; increment the irq count
currentCounter DCD 0
num1 DCD 0
num2 DCD 0
num3 DCD 0
adc0counter DCD 0
volts_value DCD 0,0
	END
