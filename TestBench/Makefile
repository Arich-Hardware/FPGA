# python3.8
# run a GHDL simulation
#
# run perl script with modules from the yml2tb submodule
PERLRUN = perl -I../yml2tb

all: tdc_chan_tb.ghw 
clean:
	rm -f *~ *.cf *.vcd *.ghw

../TDC_prototype/tdc/src/tdc_types.vhd: ../TDC_prototype/tdc/src/tdc_types.yml
	python3 ../yml2hdl/yml2hdl.py ../TDC_prototype/tdc/src/tdc_types.yml

tdc_chan_tb.ghw: ../TDC_prototype/tdc/src/multi_sample.vhd ../TDC_prototype/tdc/src/decode.vhd tdc_chan_tb.vhd ../TDC_prototype/tdc/src/tdc_chan.vhd \
	../TDC_prototype/tdc/src/tdc_types.vhd ../TDC_prototype/tdc/src/tdc_hit_mux.vhd \
	../TDC_prototype/tdc/sim/tdc_types_textio.vhd ../TDC_prototype/tdc/sim/my_textio.vhd
	ghdl -a --ieee=synopsys ../TDC_prototype/tdc/src/tdc_types.vhd
	ghdl -a --ieee=synopsys ../TDC_prototype/tdc/sim/my_textio.vhd
	ghdl -a --ieee=synopsys ../TDC_prototype/tdc/sim/tdc_types_textio.vhd
	ghdl -a --ieee=synopsys ../TDC_prototype/tdc/src/tdc_hit.vhd
	ghdl -a --ieee=synopsys ../TDC_prototype/tdc/src/tdc_hit_mux.vhd
	ghdl -a --ieee=synopsys ../TDC_prototype/tdc/src/decode.vhd
	ghdl -a --ieee=synopsys ../TDC_prototype/tdc/src/multi_sample.vhd
	ghdl -a --ieee=synopsys ../TDC_prototype/tdc/src/tdc_chan.vhd
	ghdl -a --ieee=synopsys tdc_chan_tb.vhd
	ghdl -e --ieee=synopsys tdc_chan_tb
	ghdl -r --ieee=synopsys tdc_chan_tb --stop-time=1ms --wave=tdc_chan_tb.ghw

