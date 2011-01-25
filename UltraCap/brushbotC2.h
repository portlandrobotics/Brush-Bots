/*
Copyright (C) 2009 Tim Brandon
 Distributed under the GNU GENERAL PUBLIC LICENSE (GPL) Version 2 (June 1991).
 See the "COPYING" file distributed with this software for more information.
*/


// Pins and parameters for for Big BrushBot board C2 2010.05.16

// Assumed CPU frequency, this is a standard name see <util/delay.h>
#define F_CPU 8000000UL

/* Map Tiny44 physical pins
                                 Vcc |1   14| Gnd
             (PCINT8/XTAL1/CLKI) PB0 |2   13| PA0 (ADC0/ARef/PCINT0)
                  (PCINT9/XTAL2) PB1 |3   12| PA1 (ADC1)/AIn0/PCINT1)
               (PCINT11/nRst/dW) PB3 |4   11| PA2 (ADC2/AIn1/PCINT2)
       (PCINT10/INT0/OC0A/CKOut) PB2 |5   10| PA3 (ADC3/T0/PCINT3)
          (PCINT7/ICP/OC0B/ADC7) PA7 |6    9| PA4 (ADC4/USCK/SCL/T1/PCINT4)
  (PCINT6/OC1A/SDA/MOSI/DI/ADC6) PA6 |7    8| PA5 (ADC5/DO/MISO/OC1B/PCINT5)

Big brushbot board pin assignments:
                                 Vcc |1   14| Gnd
                        LED_RED  PB0 |2   13| PA0  (nc)
                      LED_GREEN  PB1 |3   12| PA1  Vcc(measure)
                         !Reset  PB3 |4   11| PA2  (nc)
                           MotA  PB2 |5   10| PA3  IR_RX
                           MotB  PA7 |6    9| PA4  SCK
                     LED_FWD_IR  PA6 |7    8| PA5  LED_RV_IR

Brushbot vC2 physical layout::

                   Off  On
         Gnd     +---(SW)-------------------+
         Vcc     x                          |
                 x                          x
                 |                          x IR detector
         IR LED  x                          x
                 x                          |
                 |                          x
                 |                          x  IR LED
                 |                          |
                 +--xxx-----xxxxxx------xxx-+
               Gnd-/ | \Vcc/ |||||      || \-Gnd
                     |      / | \\\     | \------MotA
                    MotB   | Gnd |\\   Vcc
                          Rst   SCK\\------MISO
                                    \
                                    MOSI
Arduino fuses:
  low=E2 high=D2 extended=FE (8MHz, internal)
*/

#define VCC_MEASURE PA1
#define IR_RX       PA3
#define LED_GREEN   PB1
#define LED_RED     PB0
#define LED_FWD_IR  PA6
#define LED_RV_IR   PA5
#define MOTA        PB2
#define MOTB        PA7

#define MOTA_PORT   PORTB // Motor A Port
#define MOTB_PORT   PORTA // Motor B Port

// Indicator Lamps, Red and Green LEDs
#define LAMP_PORT  PORTB
#define LAMP_PIN    PINB
#define LAMP_DIR    DDRB
#define LAMP_MASK  _BV( LED_GREEN) | _BV( LED_RED)

// IR receiver
#define IR_RX_PORT PORTA
#define IR_RX_PORT_IN PINA
  // Interrupt vector stuff (/usr/lib/avr/include/avr/iotnx4.h)
  // IR_RX Pin-change interrupt stuff
  #define IR_RX_ISR PCINT0_vect // Aim for pin change 3 (PCI3)
  #define IR_RX_GIMSK _BV( PCIE0)
  #define IR_RX_PCMSK PCMSK0

