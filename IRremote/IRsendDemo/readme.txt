Hi guys,

This is my first cut at porting the IRremote library to the tinyx4.

It can send and receive codes simultaneously.  Unfortunately, the receive ISR state machine is currently executing on every timer tick, so it eats up a lot of bandwidth.  I had to manually tweek the timing of IR carrier active / inactive intervals to compensate.

This can be fixed by splitting the receive ISR into two parts -- a part that cares about edges of the receive signal, which would be invoked by an interrupt-on-change, and another part that cares about timeouts.

-Pete
