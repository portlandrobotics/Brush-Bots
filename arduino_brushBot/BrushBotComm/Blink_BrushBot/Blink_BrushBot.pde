/*
  Blink
 
 Turns on an LED on for one second, then off for one second, repeatedly.
 
 The circuit:
 * LED connected from digital pin 13 to ground.
 
 * Note: On most Arduino boards, there is already an LED on the board
 connected to pin 13, so you don't need any extra components for this example.
 
 
 Created 1 June 2005
 By David Cuartielles
 
 http://arduino.cc/en/Tutorial/Blink
 
 based on an orginal by H. Barragan for the Wiring i/o board
 
 */

int greenLedPin =  1;    // Green LED connected to digital pin 1
int redLedPin =  0;    // Red LED connected to digital pin 0

// The setup() method runs once, when the sketch starts

void setup()   {                
  // initialize the digital pin as an output:
  pinMode(greenLedPin, OUTPUT);     
  pinMode(redLedPin, OUTPUT);     
}

// the loop() method runs over and over again,
// as long as the Arduino has power

void loop()                     
{
  digitalWrite(greenLedPin, HIGH);   // set the LED on
  digitalWrite(redLedPin, LOW);   // set the LED on
  delay(500);                  // wait for a second
  digitalWrite(greenLedPin, LOW);   // set the LED on
  digitalWrite(redLedPin, HIGH);   // set the LED on
  delay(500);                  // wait for a second
}
