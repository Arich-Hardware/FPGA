
all: test.vcd

clean:
	rm -f *~ *.cf *.vcd

test.vcd: tdc.vhd tdc_tb.vhd Makefile
	ghdl -a --ieee=synopsys tdc.vhd
	ghdl -a --ieee=synopsys tdc_tb.vhd
	ghdl -e --ieee=synopsys tdc_tb
	ghdl -r --ieee=synopsys tdc_tb --stop-time=1000ns --vcd=test.vcd


