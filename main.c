 ///////////////////////////////////////////////////////////////////////////////
//  Includes
///////////////////////////////////////////////////////////////////////////////

#include <stdio.h>

#include "board.h"
#include "gpio_pins.h"
#include "fsl_debug_console.h"
#include <math.h>
#include <cstddef>

// SDK Included Files
#include "fsl_lptmr_driver.h"
#include "board.h"
#include "fsl_debug_console.h"


///////////////////////////////////////////////////////////////////////////////
// Variables
///////////////////////////////////////////////////////////////////////////////

extern void asmmain(void);
extern void asm_pit_irq(void);

bool ledOnFlag = 0; 

#define LPTMR_INSTANCE     0U

#include <MK60D10.H>

#define LED_NUM     3                   /* Number of user LEDs                */
const uint32_t led_mask[] = {1UL << 0, 1UL << 1, 1UL << 2, 1UL << 3, 1UL << 4, 1UL << 5, 1UL << 6, 1UL << 7, 1UL << 8, 1UL << 9, 1UL << 10};

////////////////////////////////////////////////////////////////////////////////
// Code
////////////////////////////////////////////////////////////////////////////////
__INLINE static void LED_Config(void) {

  SIM->SCGC5    |= (1UL <<  11);        /* Enable Clock to Port c */
  PORTC->PCR[0] = (1UL <<  8);        /* Pin is GPIO */
	PORTC->PCR[1] = (1UL <<  8);        /* Pin is GPIO */
	PORTC->PCR[2] = (1UL <<  8);        /* Pin is GPIO */
	PORTC->PCR[3] = (1UL <<  8);        /* Pin is GPIO */
	PORTC->PCR[4] = (1UL <<  8);        /* Pin is GPIO */
	PORTC->PCR[5] = (1UL <<  8);        /* Pin is GPIO */
	PORTC->PCR[6] = (1UL <<  8);        /* Pin is GPIO */
	PORTC->PCR[7] = (1UL <<  8);        /* Pin is GPIO */
	PORTC->PCR[8] = (1UL <<  8);        /* Pin is GPIO */
	PORTC->PCR[9] = (1UL <<  8);        /* Pin is GPIO */
	PORTC->PCR[10] = (1UL <<  8);        /* Pin is GPIO */

	
  PTC->PDDR = (led_mask[0] | 
               led_mask[1] |
               led_mask[2] |
							 led_mask[3] |
	             led_mask[4] | 
               led_mask[5] |
	             led_mask[6] | 
               led_mask[7] |
							 led_mask[8] | 
               led_mask[9] |
               led_mask[10] );          /* enable Output */
}

__INLINE static void LED_On (uint32_t num, int digit) {

	int d1, d2;
	
	if(digit == 1) {
			d1 = 9;
		  d2 = 10;
	} else if (digit == 2) {
		  d2 = 8;
		  d1 = 10;
	} else {
	    d1 = 8;
		  d2 = 9;
	}
	if (num == 0){								// 0
		PTC->PDOR = (led_mask[6] | 
					 led_mask[7] |
					 led_mask[d1] |
					 led_mask[d2]);
	} 
	else if(num == 1){						//1
		PTC->PDOR = (
							 led_mask[0] |
               led_mask[5] |
							 led_mask[3] |
							 led_mask[4] |
							 led_mask[6] |
							 led_mask[7] |
							 led_mask[d1] |
		           led_mask[d2]);		
	} else if(num == 2){					
		PTC->PDOR = (led_mask[2] | 
               led_mask[5] |
							 led_mask[7] |
							 led_mask[d1] |
		           led_mask[d2]);
		
	} else if(num == 3){
		PTC->PDOR = (led_mask[4] | 
               led_mask[5] |
							 led_mask[7] |
							 led_mask[d1] |
		           led_mask[d2]);
		
	} else if(num == 4){
		PTC->PDOR = (led_mask[0] | 
							 led_mask[3] |
							 led_mask[4] |
							 led_mask[7] |
							 led_mask[d1] |
		           led_mask[d2]);
	} else if(num == 5){
		PTC->PDOR = (led_mask[1] |
               led_mask[4] |
							 led_mask[7] |
							 led_mask[d1] |
		           led_mask[d2] );
		
	} else if(num == 6){
		PTC->PDOR = (led_mask[1] |
							 led_mask[7] |
							 led_mask[d1] |
		           led_mask[d2]);
		
	} else if(num == 7){
		PTC->PDOR = (led_mask[3] | 
               led_mask[4] |
							 led_mask[6] |
							 led_mask[7] |
							 led_mask[d1] |
		           led_mask[d2]);
		
	} else if(num == 8){
		PTC->PDOR = (
							 led_mask[7] |
							 led_mask[d1] |
		           led_mask[d2]);
		
	} else if(num == 9){
		PTC->PDOR = (led_mask[4] |
							 led_mask[7] |
							 led_mask[d1] |
		           led_mask[d2]);
		
	}
	
	if(digit == 1){
		PTC->PCOR = (led_mask[7]);
	}
	
	
}

void ledToggle(int num, int digit){
		__disable_irq();
		LED_On (num, digit);
		__enable_irq();
		return;
}	

void floatToBCD (int num, int *num1, int *num2, int *num3){
	float result = (num*3.3)/((1<<16)-1);
	*num1 = (int)result;
	result = (result-*num1)*10;
	*num2 = (int)result;
	result = (result-*num2)*10;
	*num3 = (int)result;
	return;
}

int main (void) {
  hardware_init();
  LED_Config();
  asmmain();
  
}



/*******************************************************************************
 * EOF
 ******************************************************************************/

