/*
 * IRremote
 * Version 0.1 July, 2009
 * Copyright 2009 Ken Shirriff
 * For details, see http://arcfn.com/2009/08/multi-protocol-infrared-remote-library.htm http://arcfn.com
 *
 * Interrupt code based on NECIRrcv by Joe Knapp
 * http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1210243556
 * Also influenced by http://zovirl.com/2008/11/12/building-a-universal-remote-with-an-arduino/
 */

#ifndef IRremote_h
#define IRremote_h

#define SONY_ENABLE 1
#define NEC_ENABLE 1
//#define RAW_ENABLE 1
//#define RC5_ENABLE 1
//#define RC6_ENABLE 1

// The following are compile-time library options.
// If you change them, recompile the library.
// If DEBUG is defined, a lot of debugging output will be printed during decoding.
// TEST must be defined for the IRtest unittests to work.  It will make some
// methods virtual, which will be slightly slower, which is why it is optional.
// #define DEBUG
// #define TEST

// Results returned from the decoder
class decode_results {
public:
  int decode_type; // NEC, SONY, RC5, UNKNOWN
  unsigned long value; // Decoded value
  int bits; // Number of bits in decoded value
  volatile unsigned int *rawbuf; // Raw intervals in .5 us ticks
  int rawlen; // Number of records in rawbuf.
};

// Values for decode_type
#define NEC 1
#define SONY 2
#define RC5 3
#define RC6 4
#define UNKNOWN -1

// Decoded value for NEC when a repeat code is received
#define REPEAT 0xffffffff

// main class for receiving IR
class IRrecv
{
public:
  IRrecv(int recvpin);
  void blink13(int blinkflag);
  int decode(decode_results *results);
  void enableIRIn();
  void resume();
private:
  // These are called by decode
#if defined(RC5_ENABLE) || defined(RC6_ENABLE)
  int getRClevel(decode_results *results, int *offset, int *used, int t1);
#endif
#ifdef NEC_ENABLE
  long decodeNEC(decode_results *results);
#endif
#ifdef SONY_ENABLE
  long decodeSony(decode_results *results);
#endif
#ifdef RC5_ENABLE
  long decodeRC5(decode_results *results);
#endif
#ifdef RC6_ENABLE
  long decodeRC6(decode_results *results);
#endif
} 
;

// Only used for testing; can remove virtual for shorter code
#ifdef TEST
#define VIRTUAL virtual
#else
#define VIRTUAL
#endif

class IRsend
{
public:
  IRsend() {}
#ifdef NEC_ENABLE
  void sendNEC(unsigned long data, int nbits);
#endif
#ifdef SONY_ENABLE
  void sendSony(unsigned long data, int nbits);
#endif
#ifdef RAW_ENABLE
  void sendRaw(unsigned int buf[], int len, int hz);
#endif
#ifdef RC5_ENABLE
  void sendRC5(unsigned long data, int nbits);
#endif
#ifdef RC6_ENABLE
  void sendRC6(unsigned long data, int nbits);
#endif
  // private:
  void enableIROut(int khz);
  VIRTUAL void mark(int usec);
  VIRTUAL void space(int usec);
}
;

// Some useful constants

#if (MCU==attiny44)||(MCU==attiny84)
#define USECPERTICK 26  // microseconds per clock interrupt tick
#else
#define USECPERTICK 50  // microseconds per clock interrupt tick
#endif
#define RAWBUF 76 // Length of raw duration buffer

// Marks tend to be 100us too long, and spaces 100us too short
// when received due to sensor lag.
#define MARK_EXCESS 100

#endif
