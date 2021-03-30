
all: multi_tb.ghw tdc_chan_tb.ghw buffer_fifo_tb.ghw tdc_fifo_tb.ghw

clean:
	rm -f *~ *.cf *.vcd

multi_tb.ghw: multi_sample.vhd multi_tb.vhd decode.vhd
	ghdl -a --ieee=synopsys decode.vhd
	ghdl -a --ieee=synopsys multi_sample.vhd
	ghdl -a --ieee=synopsys multi_tb.vhd
	ghdl -e --ieee=synopsys multi_tb
	ghdl -r --ieee=synopsys multi_tb --stop-time=1000ns --wave=multi_tb.ghw

tdc_chan_tb.ghw: multi_sample.vhd decode.vhd tdc_chan_tb.vhd tdc_chan.vhd tdc_pkg.vhd
	ghdl -a --ieee=synopsys tdc_pkg.vhd
	ghdl -a --ieee=synopsys decode.vhd
	ghdl -a --ieee=synopsys multi_sample.vhd
	ghdl -a --ieee=synopsys tdc_chan.vhd
	ghdl -a --ieee=synopsys tdc_chan_tb.vhd
	ghdl -e --ieee=synopsys tdc_chan_tb
	ghdl -r --ieee=synopsys tdc_chan_tb --stop-time=1000ns --wave=tdc_chan_tb.ghw

buffer_fifo_tb.ghw: tdc_pkg.vhd buffer_fifo.vhd buffer_fifo_tb.vhd
	ghdl -a --ieee=synopsys tdc_pkg.vhd
	ghdl -a --ieee=synopsys web_fifo.vhd
	ghdl -a --ieee=synopsys buffer_fifo.vhd
	ghdl -a --ieee=synopsys buffer_fifo_tb.vhd
	ghdl -e --ieee=synopsys buffer_fifo_tb
	ghdl -r --ieee=synopsys buffer_fifo_tb --stop-time=100ns --wave=buffer_fifo_tb.ghw

tdc_fifo_tb.ghw: tdc_pkg.vhd buffer_fifo.vhd buffer_fifo_tb.vhd multi_sample.vhd \
decode.vhd tdc_chan_tb.vhd tdc_chan.vhd tdc_fifo_tb.vhd
	ghdl -a --ieee=synopsys tdc_pkg.vhd
	ghdl -a --ieee=synopsys web_fifo.vhd
	ghdl -a --ieee=synopsys buffer_fifo.vhd
	ghdl -a --ieee=synopsys buffer_fifo_tb.vhd
	ghdl -a --ieee=synopsys decode.vhd
	ghdl -a --ieee=synopsys multi_sample.vhd
	ghdl -a --ieee=synopsys tdc_chan.vhd
	ghdl -a --ieee=synopsys tdc_fifo.vhd
	ghdl -a --ieee=synopsys tdc_fifo_tb.vhd
	ghdl -e --ieee=synopsys tdc_fifo_tb
	ghdl -r --ieee=synopsys tdc_fifo_tb --stop-time=100ns --wave=tdc_fifo_tb.ghw

