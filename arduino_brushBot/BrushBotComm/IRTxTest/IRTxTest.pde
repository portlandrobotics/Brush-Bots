// BrushBotComm board
// Simple IR Remote control receiver test 
// Copyright PARTS 2010

#include "irtx.h"

#define DEBUG true
//#define USE_RX_ISR
#define SERIAL_RX 5
#define SERIAL_TX 4

void setup() {
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(IR_RX, INPUT);
  pinMode(FRONT_IR_TX, OUTPUT);
  pinMode(REAR_IR_TX, OUTPUT);
  pinMode(MOTA, OUTPUT);
  pinMode(MOTB, OUTPUT);
  setupIrTx();
}

void loop() {
  char key;
  char i;

 digitalWrite(GREEN_LED, HIGH);
 key = ENTER;
// sendIRKey(key);  //sendIRKey not adding extra protocol bits as required...
 for(i=0;i<10; i++) {
   sendIRKey(0xD10);  //Enter (11) w/ extra protocol bits & LSB
 }
 delay(500);
 digitalWrite(GREEN_LED, LOW);
 delay(500);
}
