/*
 * IRremote: IRsendDemo - demonstrates sending IR codes with IRsend
 * An IR LED must be connected to Arduino PWM pin 3.
 * Version 0.1 July, 2009
 * Copyright 2009 Ken Shirriff
 * http://arcfn.com
 */

#include <IRremote.h>

IRsend irsend;
IRrecv irrecv(IR_RX);

decode_results results;


void setup()
{
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
  if (irrecv.decode(&results)) {
    digitalWrite(RED_LED, HIGH);
    if ((results.value == 0xa90) && (results.bits == 12))
      digitalWrite(GREEN_LED, HIGH);
    else
      digitalWrite(GREEN_LED, LOW);
    irrecv.resume(); // receive next value
  }
  delay(1000);
  digitalWrite(RED_LED, LOW);
}

