# TDC prototype

This directory is intended to be the top level of a HoG project for
the EMPHATIC TDC prototype FPGA design.  Currently the tree ```tdc``` contains
the initial version of one multi-hit TDC with a ```Makefile``` in ```tdc/sim```
for ```ghdl``` simulation.

Output format (bits 20..0 used):

```
  bits 20..15 - leading edge time
  bits 14..13 - leading edge phase
  bits 12..7  - trailing edge time
  bits 6..5   - trailing edge phase
  bits 4..2   - trigger number
  bit 1       - glitch
  bit 0       - error
```
