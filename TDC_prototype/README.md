# TDC prototype

This is currently a branch (basys3-build) with a synthesizable TDC.  Inputs and outputs are rather bogus and just wired to switches and PMODs on a basys3 board.  However, a 96-channel TDC synthesizes and meets timing.  Notes:

* All logic past the FIFOs is at 100MHz.  NOT VERIFIED in simulation
* Warnings not checked
* 96 of 100 BRAMs used (but 7A50T has 50 more)
* Pin assignments are competely arbitrary

To build, be sure that ```NUM_TDC_CHANNELS``` is set to 96 (for now, or to match top design and constraints).
Then run 'make" in ```TDC_prototype/sim``` to create the required VHDL.  Then you can run ```Hog/LaunchWorkflow.sh tdc``` to build.
