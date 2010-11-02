/*
 * IRremote: IRsendDemo - demonstrates sending IR codes with IRsend
 * An IR LED must be connected to Arduino PWM pin 3.
 * Version 0.1 July, 2009
 * Copyright 2009 Ken Shirriff
 * http://arcfn.com
 */
 /* This is a test version of the code, modified for the Tiny44 for the PARTS
  * BrushBot project.  In this version, the receive code is enabled
  * but currently not working since the timers are not correctly coded
  * yet.
  * Scott Dixon
  */

#include "IRremoteBB.h"


//#define SEND_TEST
int dummy;

#ifdef SEND_TEST
IRsend irsend;
#else
int  RECV_PIN = IR_RX;
IRrecv irrecv(RECV_PIN);
decode_results results;
#endif

void setup()
{
//  Serial.begin(9600);
  pinMode(0,OUTPUT);
  pinMode(1,OUTPUT);
    pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(IR_RX, INPUT);
//  pinMode(FRONT_IR_TX, OUTPUT);
//  pinMode(REAR_IR_TX, OUTPUT);
  pinMode(MOTA, OUTPUT);
  pinMode(MOTB, OUTPUT);

#ifndef SEND_TEST
//  irrecv.enableIRIn();
#endif
}

void loop() {
#ifdef SEND_TEST
   digitalWrite(GREEN_LED,HIGH);
    for (int i = 0; i < 3; i++) {
      delay(20);
      digitalWrite(RED_LED,HIGH);
      irsend.sendSony(0xD10, 12); // Sony TV enter code
//      irsend.sendSony(0xa90, 12); // Sony TV power code
      delay(100);
      digitalWrite(RED_LED,LOW);
    }
    digitalWrite(GREEN_LED,LOW);
    delay(1000);
#else
  if (irrecv.decode(&results)) {
    if (results.value == 0xD10) {
      digitalWrite(GREEN_LED, HIGH);
      delay(500);
      digitalWrite(GREEN_LED, LOW);
    } else {
      delay(500);
    }
    digitalWrite(RED_LED, LOW);
  } else {
  digitalWrite(RED_LED, HIGH);

      digitalWrite(GREEN_LED, HIGH);
    delay(500);
    digitalWrite(GREEN_LED, LOW);
  }
  delay(500);
#endif
}

