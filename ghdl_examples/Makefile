
all: multi_tb.ghw tdc_chan_tb.ghw

clean:
	rm -f *~ *.cf *.vcd

# tdc_tb.ghw: tdc.vhd tdc_tb.vhd Makefile
# 	ghdl -a --ieee=synopsys tdc_pkg.vhd
# 	ghdl -a --ieee=synopsys tdc.vhd
# 	ghdl -a --ieee=synopsys tdc_tb.vhd
# 	ghdl -e --ieee=synopsys tdc_tb
# 	ghdl -r --ieee=synopsys tdc_tb --stop-time=1000ns --wave=tdc_tb.ghw

multi_tb.ghw: multi_sample.vhd multi_tb.vhd decode.vhd
	ghdl -a --ieee=synopsys decode.vhd
	ghdl -a --ieee=synopsys multi_sample.vhd
	ghdl -a --ieee=synopsys multi_tb.vhd
	ghdl -e --ieee=synopsys multi_tb
	ghdl -r --ieee=synopsys multi_tb --stop-time=1000ns --wave=multi_tb.ghw

tdc_chan_tb.ghw: multi_sample.vhd decode.vhd tdc_chan_tb.vhd tdc_chan.vhd
	ghdl -a --ieee=synopsys tdc_pkg.vhd
	ghdl -a --ieee=synopsys decode.vhd
	ghdl -a --ieee=synopsys multi_sample.vhd
	ghdl -a --ieee=synopsys tdc_chan.vhd
	ghdl -a --ieee=synopsys tdc_chan_tb.vhd
	ghdl -e --ieee=synopsys tdc_chan_tb
	ghdl -r --ieee=synopsys tdc_chan_tb --stop-time=1000ns --wave=tdc_chan_tb.ghw
