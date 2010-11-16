/*
 * DualBrushBotAttacker
 * Sends and receives Sony IR codes simultaneously; when a code is
 * received, we spin the bot one way; otherwise we spin the other way.
 * Version 1.0, November 2010
 * Copyright 2010 Pete Skeggs, as part of the PARTS Robot Swarm Group Project
 *
 * based on the original:
 * IRremote: IRsendDemo - demonstrates sending IR codes with IRsend
 * An IR LED must be connected to Arduino PWM pin 3.
 * Version 0.1 July, 2009
 * Copyright 2009 Ken Shirriff
 * http://arcfn.com
 */

#include "brushbot.h"
#include <IRremote.h>

IRsend irsend;
IRrecv irrecv(IR_RX);

decode_results results;


void setup()
{
  //randomSeed(analogRead(6));
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(MOTA, OUTPUT);
  pinMode(MOTB, OUTPUT);
  digitalWrite(MOTA, 0);
  digitalWrite(MOTB, 0);
  
  digitalWrite(RED_LED, HIGH);
  digitalWrite(GREEN_LED, HIGH);
  delay(1000);
  digitalWrite(GREEN_LED, LOW);
  irsend.enableIROut(38);
  irrecv.enableIRIn(); // Start the receiver
  digitalWrite(RED_LED, LOW);
}

void loop() {
  irsend.sendSony(0xa90, 12); // Sony TV power code
  delay(100);
  if (irrecv.decode(&results)) { // received a code
    digitalWrite(RED_LED, HIGH);
    if ((results.value == 0xa90) && (results.bits == 12)) { // received our code
      digitalWrite(GREEN_LED, HIGH);
      digitalWrite(MOTA, 0);
      digitalWrite(MOTB, 1);
    }
    else { // received another code
      digitalWrite(GREEN_LED, LOW);
      digitalWrite(MOTA, 0);
      digitalWrite(MOTB, 0);
    }
    irrecv.resume(); // receive next value
  }
  else {
    digitalWrite(MOTA, 1);
    digitalWrite(MOTB, 0);
  }
  delay(random(200, 500));
  digitalWrite(RED_LED, LOW);
}

