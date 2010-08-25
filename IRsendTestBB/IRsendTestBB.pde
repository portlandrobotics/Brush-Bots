/*
 * IRremote: IRsendDemo - demonstrates sending IR codes with IRsend
 * An IR LED must be connected to Arduino PWM pin 3.
 * Version 0.1 July, 2009
 * Copyright 2009 Ken Shirriff
 * http://arcfn.com
 */

#include "IRremoteBB.h"

IRsend irsend;

void setup()
{
//  Serial.begin(9600);
  pinMode(0,OUTPUT);
  pinMode(1,OUTPUT);
}

void loop() {
//  if (Serial.read() != -1) {
   digitalWrite(1,HIGH);
    for (int i = 0; i < 3; i++) {
      delay(20);
      digitalWrite(0,HIGH);
      irsend.sendSony(0xD10, 12); // Sony TV power code
      delay(100);
      digitalWrite(0,LOW);
    }
    digitalWrite(1,LOW);
    delay(100);
//  }
}

