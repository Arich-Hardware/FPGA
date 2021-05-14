# python3.8
# run a GHDL simulation
#
# run perl script with modules from the yml2tb submodule
PERLRUN = perl -I../yml2tb

all: event_builder2_tb.ghw 
TDC_ROOT = ../TDC_prototype/tdc

clean:
	rm -f *~ *.cf *.vcd *.ghw

$(TDC_ROOT)/src/tdc_types.vhd: $(TDC_ROOT)/src/tdc_types.yml
	python3 ../yml2hdl/yml2hdl.py $(TDC_ROOT)/src/tdc_types.yml

# create the custom types DB from the YAML file
tdc_types.db: $(TDC_ROOT)/src/tdc_types.yml
	$(PERLRUN) ../yml2tb/yamldump.pl $(TDC_ROOT)/src/tdc_types.yml tdc_types.db

# create custom textio functions from the types DB
tdc_types_textio.vhd: tdc_types.db
	$(PERLRUN) ../yml2tb/yaml2textio.pl tdc_types.db tdc_types_textio.vhd tdc_types

tdc_chan_tb.ghw: $(TDC_ROOT)/src/multi_sample.vhd \
	$(TDC_ROOT)/src/decode.vhd tdc_chan_tb.vhd $(TDC_ROOT)/src/tdc_chan.vhd \
	$(TDC_ROOT)/src/tdc_types.vhd $(TDC_ROOT)/src/tdc_hit_mux.vhd \
	tdc_types_textio.vhd $(TDC_ROOT)/sim/my_textio.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/tdc_types.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/sim/my_textio.vhd
	ghdl -a --ieee=synopsys tdc_types_textio.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/tdc_hit.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/tdc_hit_mux.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/decode.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/multi_sample.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/tdc_chan.vhd
	ghdl -a --ieee=synopsys tdc_chan_tb.vhd
	ghdl -e --ieee=synopsys tdc_chan_tb
	ghdl -r --ieee=synopsys tdc_chan_tb --stop-time=10ms --wave=tdc_chan_tb.ghw

event_builder2_tb.ghw: $(TDC_ROOT)/src/event_builder.vhd $(TDC_ROOT)/src/decode.vhd $(TDC_ROOT)/src/multi_sample.vhd \
	$(TDC_ROOT)/src/tdc_types.vhd tdc_types_textio.vhd $(TDC_ROOT)/sim/my_textio.vhd event_builder2_tb.vhd \
	$(TDC_ROOT)/src/trigger_tdc.vhd $(TDC_ROOT)/src/tdc_chan.vhd $(TDC_ROOT)/src/tdc_multi_chan.vhd \
	$(TDC_ROOT)/src/tdc_hit_mux.vhd $(TDC_ROOT)/src/tdc_hit.vhd $(TDC_ROOT)/src/tdc_with_fifo.vhd \
	$(TDC_ROOT)/src/web_fifo.vhd $(TDC_ROOT)/src/trigger_tdc_with_fifo.vhd
	rm -f work-obj93.cf
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/tdc_types.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/sim/my_textio.vhd
	ghdl -a --ieee=synopsys tdc_types_textio.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/decode.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/multi_sample.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/event_builder.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/tdc_hit.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/tdc_hit_mux.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/tdc_chan.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/web_fifo.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/tdc_with_fifo.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/tdc_multi_chan.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/trigger_tdc.vhd
	ghdl -a --ieee=synopsys $(TDC_ROOT)/src/trigger_tdc_with_fifo.vhd
	ghdl -a --ieee=synopsys event_builder2_tb.vhd
	ghdl -e --ieee=synopsys event_builder2_tb
	ghdl -r --ieee=synopsys event_builder2_tb --stop-time=10ms
	#ghdl -r --ieee=synopsys event_builder2_tb --stop-time=100us --wave=event_builder2_tb.ghw


