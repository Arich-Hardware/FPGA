#
# process custom types and build and run a GHDL simulation
#

# run perl script with modules from the yml2tb submodule
PERLRUN = perl -I../yml2tb
TDC_ROOT = ../TDC_prototype/tdc

# run GHDL
GHDLRUN = ghdl
GHDLOPT = --ieee=synopsys
GHDLA = $(GHDLRUN) -a $(GHDLOPT)
GHDLE = $(GHDLRUN) -e $(GHDLOPT)
GHDLR = $(GHDLRUN) -r $(GHDLOPT)

VHDL =	$(TDC_ROOT)/src/tdc_types.vhd $(TDC_ROOT)/sim/my_textio.vhd tdc_types_textio.vhd $(TDC_ROOT)/src/decode.vhd \
	$(TDC_ROOT)/src/multi_sample.vhd $(TDC_ROOT)/src/event_builder.vhd $(TDC_ROOT)/src/event_formatter.vhd \
	$(TDC_ROOT)/src/tdc_hit.vhd $(TDC_ROOT)/src/tdc_hit_mux.vhd $(TDC_ROOT)/src/tdc_chan.vhd \
	$(TDC_ROOT)/src/web_fifo.vhd $(TDC_ROOT)/src/tdc_with_fifo.vhd $(TDC_ROOT)/src/tdc_multi_chan.vhd \
	$(TDC_ROOT)/src/trigger_tdc.vhd $(TDC_ROOT)/src/trigger_tdc_with_fifo.vhd $(TDC_ROOT)/sim/event_formatter_tb.vhd \
	event_builder2_tb.vhd

define analyze_VHDL
  $(GHDLA) $(1);
endef

all: analyze.ready

analyze.ready: $(VHDL)
	rm -f work-obj93.cf
	$(foreach vf,$(VHDL), $(call analyze_VHDL, $(vf)))
	touch analyze.ready

clean:
	rm -f *~ *.cf *.vcd *.ghw *.db *.ready

# create the custom types DB from the YAML file
$(TDC_ROOT)/src/tdc_types.db: $(TDC_ROOT)/src/tdc_types.yml
	$(PERLRUN) ../yml2tb/yamldump.pl $(TDC_ROOT)/src/tdc_types.yml tdc_types.db

# create custom textio functions from the types DB
tdc_types_textio.vhd: $(TDC_ROOT)/src/tdc_types.db
	$(PERLRUN) ../yml2tb/yaml2textio.pl tdc_types.db tdc_types_textio.vhd tdc_types

# create the VHDL types from the YAML file using yml2hdl
tdc_types.vhd: $(TDC_ROOT)/src/tdc_types.yml
	python3 ../yml2hdl/yml2hdl.py $(TDC_ROOT)/src/tdc_types.yml

event_builder2_tb.ghw: analyze.ready
	$(GHDLR) event_builder2_tb --stop-time=250us --wave=event_builder2_tb.ghw

event_builder2_tb.fast: analyze.ready
	$(GHDLE) event_builder2_tb
	$(GHDLR) event_builder2_tb --stop-time=10ms
