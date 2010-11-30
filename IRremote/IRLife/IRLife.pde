/*
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
typedef union _ir_code_union_
{
  uint16_t data;
  struct _ir_code_
  {
    uint16_t color : 2;
    uint16_t num_neighbors : 5;
    uint16_t rand_id : 5;
  } fields;
} IRCODE;

enum colors 
{
  IR_BLACK, IR_RED, IR_GREEN, IR_BOTH
};

IRCODE ourcode;

unsigned long send_time;
unsigned long toggle_time;
uint8_t cur_color;
uint8_t neighbors[32];

void set_color(int color)
{
  switch (color)
  {
    case IR_BLACK:
      digitalWrite(RED_LED, LOW);
      digitalWrite(GREEN_LED, LOW);
      break;
    case IR_RED:
      digitalWrite(RED_LED, HIGH);
      digitalWrite(GREEN_LED, LOW);
      break;
    case IR_GREEN:
      digitalWrite(RED_LED, LOW);
      digitalWrite(GREEN_LED, HIGH);
      break;
    case IR_BOTH:
      digitalWrite(RED_LED, HIGH);
      digitalWrite(GREEN_LED, HIGH);
      break;
  }
  cur_color = color;
}

void setup()
{
  randomSeed(analogRead(6));
  ourcode.fields.rand_id = random(1, 32);
  ourcode.fields.color = random(1, 4);
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(MOTA, OUTPUT);
  pinMode(MOTB, OUTPUT);
  digitalWrite(MOTA, 1);
  digitalWrite(MOTB, 1);
  
  digitalWrite(RED_LED, HIGH);
  digitalWrite(GREEN_LED, HIGH);
  delay(1000);
  digitalWrite(GREEN_LED, LOW);
  irsend.enableIROut(38);
  irrecv.enableIRIn(); // Start the receiver
  digitalWrite(RED_LED, LOW);
  set_color(ourcode.fields.color);
  send_time = millis();
}

void loop() {
  int i;
  IRCODE othercode;
  
  if (millis() > send_time)
  {
    irsend.sendSony(ourcode.data, 12); // robot's id, a count of known neighbors, and the current color
    send_time = millis() + random(200, 500);
    //delay(100);
  }
  if (irrecv.decode(&results)) 
  { // received a code
    if (results.bits == 12) 
    {
      othercode.data = results.value;
      if (othercode.data != ourcode.data) // not our code
      {
        if (othercode.fields.color == ourcode.fields.color) // the colors are the same, so change it
        {
          ourcode.fields.color++;
          ourcode.fields.color &= 0x03;
          if (!ourcode.fields.color)
            ourcode.fields.color++;
        }
        else if (othercode.fields.rand_id > ourcode.fields.rand_id)  // take dominant unit's color
        {
          ourcode.fields.color = othercode.fields.color;
        }
        if (!neighbors[othercode.fields.rand_id])
        {
          neighbors[othercode.fields.rand_id] = millis()/1000; // time we saw this one last
          ourcode.fields.num_neighbors++;
          ourcode.fields.num_neighbors &= 0x1f;
        }
      }
    }
    irrecv.resume(); // receive next value
  }
  if (millis() > toggle_time)
  {
    toggle_time = millis() + 1000 / (ourcode.fields.num_neighbors + 1);
    if (cur_color != IR_BLACK)
      set_color(IR_BLACK);
    else
      set_color(ourcode.fields.color);
  }
  for (i = 0; i < 32; i++)
  {
    if (neighbors[i] && ((millis()/1000 - neighbors[i]) > 5)) // we have not seen this one for at least 5 seconds
    {
      neighbors[i] = 0;  // forget them
      if (ourcode.fields.num_neighbors)
        ourcode.fields.num_neighbors--;
      else  // we have no neighbors, so pick a new color
        ourcode.fields.color = random(1, 4); 
    }
  }
}

