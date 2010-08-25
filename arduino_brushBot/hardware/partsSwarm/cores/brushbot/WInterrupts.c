/* -*- mode: jde; c-basic-offset: 2; indent-tabs-mode: nil -*- */

/*
  Part of the Wiring project - http://wiring.uniandes.edu.co

  Copyright (c) 2004-05 Hernando Barragan

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
  
  Modified 24 November 2006 by David A. Mellis
  
  modified for Atmel ATTiny84 mcu by RenÈ Bohne
*/

#include <inttypes.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <stdio.h>

#include "WConstants.h"
#include "wiring_private.h"

volatile static voidFuncPtr intFunc[EXTERNAL_NUM_INTERRUPTS];
// volatile static voidFuncPtr twiIntFunc;
volatile static voidFuncPtr intPCFunc[12];

#define EICRA MCUCR
#define EIMSK GIMSK

volatile uint8_t last_a = 0;
volatile uint8_t last_b = 0;


void attachInterrupt(uint8_t interruptNum, void (*userFunc)(void), int mode)
{
	if(interruptNum < EXTERNAL_NUM_INTERRUPTS)
	{
    intFunc[interruptNum] = userFunc;
    
    if (interruptNum == 0)
	{
      // Configure the interrupt mode (trigger on low input, any change, rising
      // edge, or falling edge).  The mode constants were chosen to correspond
      // to the configuration bits in the hardware register, so we simply shift
      // the mode into place.
      EICRA = (EICRA & ~((1 << ISC00) | (1 << ISC01))) | (mode << ISC00);
      
      // Enable the interrupt.
      EIMSK |= (1 << INT0);
    }
    
  }
}

void detachInterrupt(uint8_t interruptNum)
{
	if(interruptNum < EXTERNAL_NUM_INTERRUPTS) {
    if (interruptNum == 0)
	{
      // Disable the interrupt.
      EIMSK &= ~(1 << INT0);
      intFunc[interruptNum] = 0;
	}
  }
}


void attachPCInterrupt(uint8_t interruptNum, void (*userFunc)(void))
{
		intPCFunc[interruptNum] = userFunc;

		if (interruptNum < 8)
		{
			GIMSK |= (1 << PCIE0);
			PCMSK0 |= (1 << interruptNum);
		}
		else
		{
			GIMSK |= (1 << PCIE1);
			PCMSK1 |= (1 << (interruptNum-8));
		}
}

void detachPCInterrupt(uint8_t interruptNum)
{
	intPCFunc[interruptNum] = 0;

	if (interruptNum < 8)
	{
		PCMSK0 &= ~(1 << interruptNum);
	}
	else
	{
		PCMSK1 &= ~(1 << (interruptNum-8));
	}
}



/*
void attachInterruptTwi(void (*userFunc)(void) ) {
  twiIntFunc = userFunc;
}
*/

SIGNAL(INT0_vect)
{
  if(intFunc[EXTERNAL_INT_0])
  {
	  intFunc[EXTERNAL_INT_0]();
  }
}



SIGNAL(PCINT0_vect)
{
	uint8_t z;
	uint8_t a = PINA;
	for(z=0;z<8;z++)
	{
		if( (a & (1<<z)) != (last_a & (1<<z)))
		{
		   if(intPCFunc[z])
		   {
			 intPCFunc[z]();
		   }
		}
	}
	last_a = a;
}
		  
		  
SIGNAL(PCINT1_vect)
{
	uint8_t z;
	uint8_t b = PINB;
	for(z=0;z<4;z++)
	{
		if( (b & (1<<z)) != (last_b & (1<<z)))
		{
			if(intPCFunc[z+8])
			{
				intPCFunc[z+8]();
			}
		}
	}
	last_b = b;
}

/*
SIGNAL(SIG_2WIRE_SERIAL) {
  if(twiIntFunc)
    twiIntFunc();
}
*/

