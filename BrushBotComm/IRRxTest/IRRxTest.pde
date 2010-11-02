// BrushBotComm board
// Simple IR Remote control receiver test 
// Copyright PARTS 2010

#include "irrx.h"

extern volatile boolean IR_Avail;             // flag set if IR has been  read
extern volatile unsigned int IR_Return;       // returns IR code received

void setup() {
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(IR_RX, INPUT);
  pinMode(FRONT_IR_TX, OUTPUT);
  pinMode(REAR_IR_TX, OUTPUT);
  pinMode(MOTA, OUTPUT);
  pinMode(MOTB, OUTPUT);
  setupIrRx();
//  setupIrTx();
}

void loop() {
  if(IR_Avail) {
    digitalWrite(RED_LED, HIGH);
    if(IR_Return == POWER) {
      digitalWrite(GREEN_LED, HIGH);
      delay(1000);
      digitalWrite(GREEN_LED, LOW);
    } else if(IR_Return == ENTER) {
      digitalWrite(GREEN_LED, HIGH);
      delay(2000);
      digitalWrite(GREEN_LED, LOW);
    } else {
      delay (500);
    }
    digitalWrite(RED_LED, LOW);
    IR_Avail = false;
  } else {
    digitalWrite(GREEN_LED, HIGH);
    delay(500);
    digitalWrite(GREEN_LED, LOW);
  }    
  delay(500);
}
