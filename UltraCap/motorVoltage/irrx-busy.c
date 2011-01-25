// irrx-busy.c Non-blocking, busy-waiting IR Remote receiver

#include "../brushbotC2.h"
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

extern volatile uint16_t IR_In; // Incoming data bytes are placed here

// FIXME Wow, make this better
ISR( IR_RX_ISR) { // ISR called on each transition of the IR sensor
  // Interrupt flag is automatically cleared on entry
  static uint16_t ir_data; // not sure static is correct here

  if( bit_is_clear( IR_RX_PORT_IN, IR_RX)) { // Only act on falling edges

    if( ir_data == 0) { // Look for start pulse
      // start pulses are at least 2 ms long
      MOTA_PORT |= _BV( MOTA); // debug
      for( int i = 0; i < 20; i++) { // Check 20 times
	_delay_us( 100);           // Busy wait :(
        if( bit_is_set( IR_RX_PORT_IN, IR_RX)) goto RstIR_ISR;
      }
      ir_data = 1<<12; // guard bit, 12 bit IR words
      MOTA_PORT &= ~(_BV( MOTA)); // debug
      goto EndIR_ISR;
    }
    ir_data >>= 1; // data comes LSBit first

//    LAMP_PORT |= _BV( LED_GREEN); // Debug

    MOTA_PORT |= _BV( MOTA); // debug
    _delay_us( 900);         // wait 1.5 bit times and test level
    MOTA_PORT &= ~(_BV( MOTA)); // debug
    if( bit_is_clear( IR_RX_PORT_IN, IR_RX)) ir_data |= 1<<12; // negative logic
    if( ir_data & 1) { // Hit guard bit so transmission complete
//        LAMP_PORT |= _BV( LED_RED); // Debug
        IR_In = ir_data >> 1; // least 6 bits are the command
//      _delay_ms( 250); // delay to stop repeat 10ms / loop ~250ms about right
RstIR_ISR:
      ir_data = 0;                      // clean up
    }
  }
EndIR_ISR:;
}
