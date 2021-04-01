# Eric's TDC development

Starting 4/1/21 with the branch ```eric_multi_tdc``` this directory
contains the working code for the EMPHATIC TDC.

Each TDC "channel" processes hits from one SiPM input.  Leading edge
and trailing edge time are recorded using a 4-phase clock (nominally
4ns master clock, 1ns phases).  The core multi-phase sampler is
derived from the J.Y.Wu book.

Each channel has multi-hit capability, up to about 4 hits
(configurable in firmware).  Data for each hit is stored in a data
structure called a "buffer".

On receipt of a pulse leading edge, a buffer is allocated, and a
"window counter" starts counting down from 100ns (trigger window
width).  If a trigger (appropriately delayed) is received during this
window, a bit ```valid``` is set in the buffer to indcate that data
should be saved.

On receipt of a pulse trailing edge, the window counter value is
latched to record the trailing edge time.

An additional ```timeout``` counter runs for ~100ns after the window
counter reaches zero, to allow for capture of trailing edges.
Finally, when the ```timeout``` count reaches zero, if ```valid=1```
the data is written to a readout FIFO.  In any case the buffer is
freed and reset to zeroes when the ```timeout``` count reaches zero.


