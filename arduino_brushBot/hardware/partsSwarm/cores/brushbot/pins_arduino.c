/*
  pins_arduino.c - pin definitions for the Arduino board
  Part of Arduino / Wiring Lite

  Copyright (c) 2005 David A. Mellis

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

  $Id: pins_arduino.c 565 2009-03-25 10:50:00Z dmellis $

  Modified 28-08-2009 for attiny84 R.Wiersma

  Modified 24_03_2010 for brushBotComm board M. Goodson
*/

#include <avr/io.h>
#include "wiring_private.h"
#include "pins_arduino.h"

// Brushbot board (based on attiny84 pin mapping)
// D0 : PB0 (out): Red Led (D3)
// D1 : PB1 (out): Green Led (D4)
// D2 : PB2 (out): MotA
// D3 : PA7 (out): MotB
// D4 : PA6 (out): Rev IR (D2) / ISP MOSI
// D5 : PA5 (out): Fwd IR (D1) / ISP MISO
// D6 : PA4 (bi ): ISP SCK
// D7 : PA3 (in ): IR Rec (U2)
// D8 : PA2 (bi ): NC
// D9 : PA1 (in ): Batt sense
//      PB3 (in ): Reset
//      PA0 (bi ): NC (AREF)

// ATMEL ATTINY84 / ARDUINO
//
//                  +-\/-+
//            VCC  1|    |14  GND
//      (D 0) PB0  2|    |13  PA0       AREF
//      (D 1) PB1  3|    |12  PA1 (D 9) 
//  RST       PB3  4|    |11  PA2 (D 8) 
//  PWM (D 2) PB2  5|    |10  PA3 (D 7) 
//  PWM (D 3) PA7  6|    |9   PA4 (D 6) 
//  PWM (D 4) PA6  7|    |8   PA5 (D 5) PWM
//                  +----+

#define PA 2
#define PB 3

#define REPEAT8(x) x, x, x, x, x, x, x, x
#define BV0TO7 _BV(0), _BV(1), _BV(2), _BV(3), _BV(4), _BV(5), _BV(6), _BV(7)
#define BV7TO0 _BV(7), _BV(6), _BV(5), _BV(4), _BV(3), _BV(2), _BV(1), _BV(0)


// these arrays map port names (e.g. port B) to the
// appropriate addresses for various functions (e.g. reading
// and writing)
const uint8_t PROGMEM port_to_mode_PGM[] = {
	NOT_A_PORT,
	NOT_A_PORT,
	&DDRA,
	&DDRB,
};

const uint8_t PROGMEM port_to_output_PGM[] = {
	NOT_A_PORT,
	NOT_A_PORT,
	&PORTA,
	&PORTB,
};

const uint8_t PROGMEM port_to_input_PGM[] = {
	NOT_A_PORT,
	NOT_A_PORT,
	&PINA,
	&PINB,
};

const uint8_t PROGMEM digital_pin_to_port_PGM[] = {
	PB, /* 0 */
	PB,
	PB,
	PA,
	PA,
	PA,
	PA,
	PA,
	PA, /* 8 */
	PA,
};

const uint8_t PROGMEM digital_pin_to_bit_mask_PGM[] = {
	_BV(0), /* 0, port B */
	_BV(1),
	_BV(2),
	_BV(7), /* 3 port B */
	_BV(6),
	_BV(5),
	_BV(4),
	_BV(3),
	_BV(2), 
	_BV(1),

};

const uint8_t PROGMEM digital_pin_to_timer_PGM[] = {
	NOT_ON_TIMER,
	NOT_ON_TIMER,
	TIMER0A, /* OC0A */
	TIMER0B, /* OC0B */
	TIMER1A, /* OC1A */
	TIMER1B, /* OC1B */
	NOT_ON_TIMER,
	NOT_ON_TIMER,
	NOT_ON_TIMER, 
	NOT_ON_TIMER,
	NOT_ON_TIMER,
};
