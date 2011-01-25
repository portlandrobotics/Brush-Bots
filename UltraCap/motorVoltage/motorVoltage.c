/*
Copyright (C) 2009 Tim Brandon
 Distributed under the GNU GENERAL PUBLIC LICENSE (GPL) Version 2 (June 1991).
 See the "COPYING" file distributed with this software for more information.
*/

// IR Receiver test for BrushBot vC2 board 2010.05.16

#include "../brushbotC2.h"  // Only tested for the brushbot vC2
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define FASTER 244 // (R) on my Sony remote
#define SLOWER 245 // (L) on my Sony remote
#define ON_OFF 150 // (RESET) on my Sony remote

#define BRKVAL 16 // Debugging

// Globals
volatile uint16_t IR_In = 0xffff; // Data passed in from the IR_RX interrupt

//uint8_t Vm = 64 * 1 / 1.1; // Scaled motor voltage (initially ~1V)
uint8_t Vm = 40; // Debug
// Target motor voltage = Vm * Vref / 64, Vref ~1.1 V

void delay_ms( unsigned int ms) // FIXME, do i need this?
/* delay for a minimum of <ms> */
{ // FIXME RC oscillator not being calibrated? (need a makefile target?)
  while( ms) {
    _delay_ms( 0.96); // FIXME constant not checked
    ms--;
  }
}

enum colorNum {dark, red, green, yellow};
// 1 = red, 2 = green, 3 = yellow
void flashone( enum colorNum color) // flash once
{
  LAMP_PORT &= ~(_BV( LED_RED) | _BV( LED_GREEN));
  if( color & green) LAMP_PORT |= _BV( LED_GREEN);
  if( color & red) LAMP_PORT |= _BV( LED_RED);
  delay_ms( 500);
  LAMP_PORT &= ~(_BV( LED_RED) | _BV( LED_GREEN));
}

void flashfast( enum colorNum color) // flash once
{
  LAMP_PORT &= ~(_BV( LED_RED) | _BV( LED_GREEN));
  if( color & green) LAMP_PORT |= _BV( LED_GREEN);
  if( color & red) LAMP_PORT |= _BV( LED_RED);
  delay_ms( 50);
  LAMP_PORT &= ~(_BV( LED_RED) | _BV( LED_GREEN));
}

void flashOctalDigit( uint8_t byte)
{
  for( int8_t i = 7 & byte; i > 0; i--) {
    flashone( green);
    delay_ms( 500);
  }
}

void flashOctalNumber( uint16_t num) // In octal
{
  uint8_t v = 0;

  if( num != 0) {
    for( int8_t i = 12; i >= 0; i -=3) {
      v |= (uint8_t) 7 & (num >> i);
      if( v) {
        flashOctalDigit( (uint8_t)num >> i);
        delay_ms( 200);
        flashone( red);
      }
    }
  } else flashone( red);
}
 
void main( void) // this prototype requires -Wno-main to avoid gcc whineage
{
  uint8_t  dataflg;
  uint16_t   c = 0;

  cli(); // Make sure interrupts are disabled

  // Set all pins to output except for the IR detector and Vcc Measure
  PORTA = 0; PORTB = 0; // zero initial state all round (Mot off, LEDs off)
  DDRA = 0xff & ~(_BV( IR_RX) | _BV( VCC_MEASURE));
  DDRB = 0xff; // This programs to outputs pins we don't have on tiny44

  // Set up ADC to measure internal Vref (1.1V) using Vcc as the ADC reference.
  ADMUX = 0x21;
  // Just put the ADC in free running mode. Lame, but easy.
  ADCSRB = 0; // This is the reset state, probably don't need to do this
  // Enable ADC for free running w/clock = F_CPU/128 (62.5 kHz @ 8 MHz)
  ADCSRA = _BV( ADEN) | _BV( ADSC) |_BV( ADATE) | 3;

  // Set up hardware PWM on Timer0 (8 bit) controlling OC0A (MotA)
  // Set OC1A at BOTTOM, clear on match, period 0xFF
  TCCR0A = _BV( WGM00) | _BV( WGM01); // Set fast PWM mode
  // _BV( COM0A1) // clear OC0A on match (Start out w/motor off (debug?)
  TCCR0B = // _BV( WGM02) | // WGM02=0, Set period 0xFF
      _BV( CS00); // No prescaler, period 31.25 kHz

//  OCR0A = 0xFF; // Set initial duty 50%

  // Set up Pin Change interrupt for IR_RX
  IR_RX_PCMSK = _BV( IR_RX); // Mask pin changes only on IR receiver
  GIMSK = IR_RX_GIMSK; // Specifically enable IR_RX Pin change interrupts

  dataflg = 0; // Mark no data
  for( ;;) {
    volatile uint32_t PWM; // If this is not volatile, gcc won't check it later
    // on. I think this is because the avr headers don't declare ADCW (upon
    // which PWM depends) volatile. Anyway, something is screwy.

    // Measure voltage
    // Calculate new PWM value
    // Set PWM
    // Check for IR code
    // If not recognized, decode it
    // Else respond to it

    // Internal reference is 1.1 V, this setup uses Vcc as the ADC reference
    // and measures the internal ref. Vcc = Vref/(1024/ADC)
    // So Duty cycle (D) = VMot * ADC / (1024 * Vref)
    // Vcc should range from 5.4 V to 2.5 V.
    // Max motor voltage should be about ~3 V
    // PWM is 8 bits, 0 - 255.
    // The maximum motor voltage ratio is about = 3V/1.1V = 2.72
    // Store the target motor voltage (Vm) as a scaled ratio 64*VMot/Vref.
    // The new target PWM value is (Vm*ADC/256)
    PWM = (Vm * ADCW) >> 8;
    if( PWM > 255)
      OCR0A = 255; // Saturate FIXME --does not work!!!!!! (Maybe it does?)
    else
      OCR0A = (uint8_t)PWM;

    cli(); // Disable global interrupts
    if( IR_In != 0xffff) {
      c = IR_In;
      dataflg = 1;
      IR_In = 0xffff; // Sony IR only 12 bits, 0xffff => no data
    }
    sei(); // Enable global interrupts

    if( dataflg) {
      dataflg = 0;

      if( c == FASTER) {
	if( Vm != 255) Vm += 1;
        flashfast( green);
      } else if( c == SLOWER) {
        if( Vm != 0) Vm -= 1;
        flashfast( red);
      } else if( c == ON_OFF) {
        TCCR0A ^= _BV( COM0A1);
        flashfast( yellow);
      } else {
        flashfast( yellow);
        flashfast( yellow);
        //flashOctalNumber( c);
      }
    }
  }
}

