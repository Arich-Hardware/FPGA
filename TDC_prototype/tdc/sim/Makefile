#
# run a GHDL simulation
#

all: multi_tb.ghw tdc_chan_tb.ghw tdc_with_fifo_tb.ghw

clean:
	rm -f *~ *.cf *.vcd

../src/tdc_types.vhd: ../src/tdc_types.yml
	python ../../../yml2hdl/yml2hdl.py ../src/tdc_types.yml

tdc_with_fifo_tb.ghw: ../src/multi_sample.vhd ../src/decode.vhd tdc_with_fifo_tb.vhd ../src/tdc_chan.vhd \
	../src/tdc_types.vhd ../src/web_fifo.vhd ../src/tdc_with_fifo.vhd
	ghdl -a --ieee=synopsys ../src/tdc_types.vhd
	ghdl -a --ieee=synopsys ../src/multi_sample.vhd
	ghdl -a --ieee=synopsys ../src/decode.vhd
	ghdl -a --ieee=synopsys ../src/tdc_chan.vhd
	ghdl -a --ieee=synopsys ../src/web_fifo.vhd
	ghdl -a --ieee=synopsys ../src/tdc_with_fifo.vhd
	ghdl -a --ieee=synopsys tdc_with_fifo_tb.vhd
	ghdl -e --ieee=synopsys tdc_with_fifo_tb
	ghdl -r --ieee=synopsys tdc_with_fifo_tb --stop-time=750ns --wave=tdc_with_fifo_tb.ghw

multi_tb.ghw: ../src/multi_sample.vhd ../src/multi_tb.vhd ../src/decode.vhd
	ghdl -a --ieee=synopsys ../src/decode.vhd
	ghdl -a --ieee=synopsys ../src/multi_sample.vhd
	ghdl -a --ieee=synopsys ../src/multi_tb.vhd
	ghdl -e --ieee=synopsys multi_tb
	ghdl -r --ieee=synopsys multi_tb --stop-time=1000ns --wave=multi_tb.ghw

tdc_chan_tb.ghw: ../src/multi_sample.vhd ../src/decode.vhd tdc_chan_tb.vhd ../src/tdc_chan.vhd ../src/tdc_types.vhd
	ghdl -a --ieee=synopsys ../src/tdc_types.vhd
	ghdl -a --ieee=synopsys ../src/decode.vhd
	ghdl -a --ieee=synopsys ../src/multi_sample.vhd
	ghdl -a --ieee=synopsys ../src/tdc_chan.vhd
	ghdl -a --ieee=synopsys tdc_chan_tb.vhd
	ghdl -e --ieee=synopsys tdc_chan_tb
	ghdl -r --ieee=synopsys tdc_chan_tb --stop-time=750ns --wave=tdc_chan_tb.ghw

