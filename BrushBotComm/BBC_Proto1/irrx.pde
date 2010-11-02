// Non-blocking IR Remote receiver code
// http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1176098434/20#20
// 21-04-09: Original author unknown; modified by BroHogan
// 25-03-10: Modified to use pin change interrupt; Monty G.

#include "WConstants.h"	//required for boolean

// vars for IR_ISR() (must be global)
volatile boolean IR_Avail;             // flag set if IR has been  read
volatile unsigned int IR_Return;       // returns IR code received
volatile unsigned long ir_mask;        // Loads variable ir_string
volatile unsigned int ir_bit_seq;      // Records bit sequence in ir string
volatile unsigned int ir_string;       // Stores ir string

// Functions begin here . . . . . . .
void setupIrRx() {
  //attachInterrupt(1,IR_ISR,FALLING);  // Add to setup()
  attachPCInterrupt(3, IR_ISR);
}

void disableIrRx() {
  detachPCInterrupt(3);
}

void IR_ISR(){ // This ISR is called for EACH pulse of the IR sensor
  if(!digitalRead(ir_pin)) { //Only act on falling edges
    if(ir_bit_seq == 0){                 // it is the long start pulse
      for(int i = 0; i<20; i++){         // see if it lasts at least 2 ms
	delayMicroseconds(100); // 100
	if(digitalRead(ir_pin)) return;  // it's doesn't so get out (low active)
      }  
      ir_bit_seq = 1;                    // mark that the start pulse was received
      ir_mask = 1;                       // set up a mask for the next bits
      return;
    }

    delayMicroseconds(900);              // wait 900 us and test
    if(!digitalRead(ir_pin)) ir_string = ir_string | ir_mask;  // Stores 1 in bit
    ir_mask = ir_mask << 1;              // shifts ir_mask by one to the left
    ir_bit_seq++;                        // ir_bit_seq is incrimented by one
    if(ir_bit_seq == 12){                // after remote sends 12 bits it's done
      ir_mask = 63;                     // only want the last 6 bits - the command
      ir_string = ir_string & ir_mask;  // only keep last 6 bits
      IR_Return = ir_string;             // final result
      IR_Avail = true;                   // indicate new command received
      //digitalWrite(led_pin,HIGH);
      ir_bit_seq = 0;                    // clean up
      ir_string = 0;
      ir_mask = 0;
      for(int i = 0; i<25; i++){         // delay to stop repeat 10ms / loop ~250ms about right
	delayMicroseconds(10000);        // 16383 is maximum value so need to repeat
      }
    }
  }
} 


