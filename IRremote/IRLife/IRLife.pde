/*
 * IRremote: IRsendDemo - demonstrates sending IR codes with IRsend
 * An IR LED must be connected to Arduino PWM pin 3.
 * Version 0.1 July, 2009
 * Copyright 2009 Ken Shirriff
 * http://arcfn.com
 */

#include "IRremote.h"

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
unsigned long change_time;
unsigned long receive_time;
unsigned long new_color_time;
uint8_t cur_color;
uint32_t neighbors;
bool dominant; 

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
  //randomSeed(analogRead(2) ^ analogRead(3));
  ourcode.fields.rand_id = 0; //random(1, 32);
  ourcode.fields.color = IR_BOTH; //random(1, 4);
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
  toggle_time = send_time = millis();
  dominant = true;
}

void pick_rand_color()
{
  uint8_t old_color = ourcode.fields.color;
  int i = 0;
  do
  {
    ourcode.fields.color = (micros() >> 3) & 0x03;
    delay(ourcode.fields.color); // insert some pseudorandom time delay so micros() doesn't keep returning same value when truncated to 2 bits
    i++;
    if (i > 4)  // this is taking too long to pick a non-black, different color; quit
    {
      ourcode.fields.color ^= 2;
      if (!ourcode.fields.color)
        ourcode.fields.color = IR_RED;
      break;
    }
  }
  while (!ourcode.fields.color || (ourcode.fields.color == old_color));
  new_color_time = millis() + 5000; // make the dominant unit pick a new color at least every 5 seconds
}

void loop() {
  unsigned int i;
  uint32_t mask;
  IRCODE othercode;
  if (millis() > send_time)
  {
    irsend.sendSony(ourcode.data, 12); // robot's id, a count of known neighbors, and the current color
    send_time = millis() + 500 + ourcode.fields.rand_id * 13; //random(200, 500);
    delay(100);
  }
  
  if (irrecv.decode(&results)) 
  { 
    // received a code
    if (results.bits == 12) 
    {
      othercode.data = results.value;
      while (!ourcode.fields.rand_id) // we don't have an id yet
      {
        ourcode.fields.rand_id = (micros() >> 3) & 0x1f; // time we receive first code is kind-of-random, so use it as our id (must be >= 1)
        if (ourcode.fields.rand_id == othercode.fields.rand_id)
          ourcode.fields.rand_id ^= 0x0b;
        pick_rand_color();
      }
      if (othercode.fields.rand_id && (othercode.data != ourcode.data)) // not our code, must be a neighbor
      {
        receive_time = millis();
        i = othercode.fields.rand_id & 0x1f;
        if (othercode.fields.color != ourcode.fields.color) // the colors are not the same
        {
          if (i > ourcode.fields.rand_id)  // take dominant unit's color (larger id is dominant)
          {
            ourcode.fields.color = othercode.fields.color;
            dominant = false;
          }
        }
        mask = (((uint32_t)1) << i);
        if (!(neighbors & mask)) // have not seen this neighbor before
        {
          neighbors |= mask;  // remember their id
          ourcode.fields.num_neighbors++;
          toggle_time = 0; // make it change right now
        }
        if (dominant)  // we're the dominant one (for now)
        {
          if (millis() > new_color_time) // it's been a while since we picked a new color, so do it
          {
            pick_rand_color();
          }
        }
      }
    }
    irrecv.resume(); // receive next value
  }

  // is it time to change the LEDs?
  if (millis() > toggle_time)
  {
    toggle_time = millis() + 500 / (2 * ourcode.fields.num_neighbors + 1);
    if (cur_color != IR_BLACK)
      set_color(IR_BLACK);
    else
      set_color(ourcode.fields.color);
  }
  
  // it's been 5 seconds since we saw a neighbor, so forget about all of them
  if (millis() > (receive_time + 2500))
  {
    receive_time = millis();
    if (ourcode.fields.num_neighbors)
      ourcode.fields.num_neighbors--;
    else  // we have no neighbors, so pick a new color
    {
      neighbors = 0;
      pick_rand_color();
      toggle_time = 0; // make it change now
    }
  }
}

