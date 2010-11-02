// BrushBotComm board
// Simple IR Remote control receiver test 
// Copyright PARTS 2010

#include "irrx.h"
#include "irtx.h"

extern volatile boolean IR_Avail;             // flag set if IR has been  read
extern volatile unsigned int IR_Return;       // returns IR code received
char ledState = 0;
char GotIRVal = 0;

void setup() {
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(IR_RX, INPUT);
  pinMode(FRONT_IR_TX, OUTPUT);
  pinMode(REAR_IR_TX, OUTPUT);
  pinMode(MOTA, OUTPUT);
  pinMode(MOTB, OUTPUT);
  setupIrRx();
  setupIrTx();
}

void loop() {
  char key;
  char i;

  if(!GotIRVal) {
    if(IR_Avail) {
      digitalWrite(RED_LED, ledState);
      ledState ^= 1;
      if((IR_Return == POWER) || (IR_Return == ENTER)) {
	digitalWrite(GREEN_LED, HIGH);
	delay(1000);
	digitalWrite(GREEN_LED, LOW);
	GotIRVal = 1;
      }
      IR_Avail = false;
    }
  } else {
    //Disable RX Interrupt to keep from interrupting self when transmitting
    disableIrRx();
    digitalWrite(GREEN_LED, HIGH);
    //             LSB ...  MSB  | LSB ... MSB
    //             0 1 2 3  0 1 2  0 1 2 3 4
    // POWER
    // 21 = 0x15 = 1 0 1 0  1 0 0  1 0 0 0 0
    //            |      A|        9|      0|
    // ENTER
    // 11 = 0x0B = 1 1 0 1  0 0 0  1 0 0 0 0
    //            |      D|        1|      0|
   // key = ENTER;
    key = POWER;
   // sendIRKey(key);  //sendIRKey not adding extra protocol bits as required...
    for(i=0;i<10; i++) {
      sendIRCmd(IR_Return);
/*
      if(IR_Return == POWER) {
//	sendIRKey(0xA90);  //Power (21) w/ extra protocol bits & LSB
      } else {
//	sendIRKey(0xD10);  //Enter (11) w/ extra protocol bits & LSB
      }
*/
    }
    delay(100);
    digitalWrite(GREEN_LED, LOW);
    delay(100);
  }

}
