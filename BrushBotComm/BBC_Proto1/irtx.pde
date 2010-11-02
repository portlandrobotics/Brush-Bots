// IR Remote transmitter code
// http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1176098434/6#6
// 10-01-08: David Cuartielles
// 29-03-10: Modified for BrushBotComm; Cleaned up code; Monty G.

#include "pins_arduino.h"	//temp

//uint8_t tx_pin = 5;	 //Transmitter
//char tx_pin = RED_LED;	 //Transmitter
char tx_pin = FRONT_IR_TX;	 //Transmitter
//char tx_pin = REAR_IR_TX;	 //Transmitter
//char tx_pin = MOTA;	 //Transmitter
//char tx_rdy_pin = FRONT_IR_TX;	 //"Ready to transmit" flag, not needed but nice
char tx_rdy_pin = RED_LED;	 //"Ready to transmit" flag, not needed but nice
int tx_start_bit = 2400;		 //Start bit threshold (Microseconds)
int tx_bin_1 = 1200;		 //Binary 1 threshold (Microseconds)
int tx_bin_0 = 600;		 //Binary 0 threshold (Microseconds)
unsigned int dataOut = 0;
//int guardTime = 300;
int guardTime = 600;


void setupIrTx() {
  volatile uint8_t *reg;

  pinMode(tx_rdy_pin, OUTPUT);		//This shows when we're ready to recieve
  pinMode(tx_pin, OUTPUT);
//  DDRA |= _BV(5);
//  reg = portModeRegister(2);
//  reg = &DDRA;
//  *reg |= digitalPinToBitMask(5);
  digitalWrite(tx_rdy_pin, LOW);	//not ready yet
  digitalWrite(tx_pin, LOW);		//not ready yet
  //Serial.begin(9600);  Need to implement serial comm first
}

/*  Need to implement serial comm first
void serialSendIRKey() {
//  if (Serial.available()) {	//SoftSerial doesn't have a "available" -- what does it return upon a read if there is no data?
    char val = Serial.read();
    dataOut = val;
    char key = 0;
    for (char j = 0; j<10; j++) {
	key = sendIRKey(dataOut);	//Send the key
    }
    Serial.print("Key Sent: ");
    Serial.println(key);
//  }
}
*/

//NEW improved version of sendIRKey -- call with just byte cmd to send
unsigned int sendIRCmd(unsigned char dataOut) {
  char data[12];
  char i;
  digitalWrite(tx_rdy_pin, HIGH);	//Ok, i'm ready to send
  for (i=0; i<7; i++) {
    data[11-i] = dataOut>>i & B1;		//encode data as '1' or '0'
  }
  data[4] = 1;
  data[3] = 0;
  data[2] = 0;
  data[1] = 0;
  data[0] = 0;
  // send startbit
  oscillationWrite(tx_pin, tx_start_bit);
  // send separation bit
  digitalWrite(tx_pin, HIGH);
  delayMicroseconds(guardTime);
  // send the whole string of data
  for (i=11; i>=0; i--) {
    if (data[i] == 0) oscillationWrite(tx_pin, tx_bin_0);
    else oscillationWrite(tx_pin, tx_bin_1);
    // send separation bit
    digitalWrite(tx_pin, HIGH);
    delayMicroseconds(guardTime);
  }
  delay(20);
  return dataOut;			//Return key number
}

unsigned int sendIRKey(unsigned int dataOut) {
  char data[12];
  char i;
  digitalWrite(tx_rdy_pin, HIGH);	//Ok, i'm ready to send
  for (i=0; i<12; i++) {
    data[i] = dataOut>>i & B1;		//encode data as '1' or '0'
    }
  // send startbit
  oscillationWrite(tx_pin, tx_start_bit);
  // send separation bit
  digitalWrite(tx_pin, HIGH);
  delayMicroseconds(guardTime);
  // send the whole string of data
  for (i=11; i>=0; i--) {
    if (data[i] == 0) oscillationWrite(tx_pin, tx_bin_0);
    else oscillationWrite(tx_pin, tx_bin_1);
    // send separation bit
    digitalWrite(tx_pin, HIGH);
    delayMicroseconds(guardTime);
  }
  delay(20);
  return dataOut;			//Return key number
}

// this will write an oscillation at 38KHz for a certain time in useconds
void oscillationWrite(char pin, int time) {
  int i;
  for(i = 0; i <= time/26; i++) {
    digitalWrite(pin, HIGH);
    delayMicroseconds(5);
    digitalWrite(pin, LOW);
    delayMicroseconds(5);
  }
}
