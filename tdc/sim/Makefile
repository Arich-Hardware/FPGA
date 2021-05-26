#
# process custom types and build and run a GHDL simulation
#

# run perl script with modules from the yml2tb submodule
PERLRUN = perl -I../../../yml2tb

# run GHDL
GHDLRUN = /usr/bin/ghdl
GHDLOPT = --ieee=synopsys
GHDLA = $(GHDLRUN) -a $(GHDLOPT)
GHDLE = $(GHDLRUN) -e $(GHDLOPT)
GHDLR = $(GHDLRUN) -r $(GHDLOPT)

VHDL =	../src/tdc_types.vhd my_textio.vhd tdc_types_textio.vhd ../src/decode.vhd \
	../src/multi_sample.vhd ../src/event_builder.vhd ../src/event_formatter.vhd \
	../src/tdc_hit.vhd ../src/tdc_hit_mux.vhd ../src/tdc_chan.vhd \
	../src/web_fifo.vhd ../src/tdc_with_fifo.vhd ../src/tdc_multi_chan.vhd \
	../src/trigger_tdc.vhd ../src/trigger_tdc_with_fifo.vhd event_formatter_tb.vhd \
	../sim/event_builder2_tb.vhd

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
tdc_types.db: ../src/tdc_types.yml
	$(PERLRUN) ../../../yml2tb/yamldump.pl ../src/tdc_types.yml tdc_types.db

# create custom textio functions from the types DB
tdc_types_textio.vhd: tdc_types.db
	$(PERLRUN) ../../../yml2tb/yaml2textio.pl tdc_types.db tdc_types_textio.vhd tdc_types

# create the VHDL types from the YAML file using yml2hdl
../src/tdc_types.vhd: ../src/tdc_types.yml
	python ../../../yml2hdl/yml2hdl.py ../src/tdc_types.yml

tdc_multi_chan_tb.ghw: analyze.ready
	$(GHDLE) tdc_multi_chan_tb
	$(GHDLR) tdc_multi_chan_tb --stop-time=1000us --wave=tdc_multi_chan_tb.ghw

tdc_hit_tb.ghw: analyze.ready
	$(GHDLE) tdc_hit_tb
	$(GHDLR) tdc_hit_tb --stop-time=750ns --wave=tdc_hit_tb.ghw

tdc_with_fifo_tb.ghw: analyze.ready
	$(GHDLE) tdc_with_fifo_tb
	$(GHDLR) tdc_with_fifo_tb --stop-time=750ns --wave=tdc_with_fifo_tb.ghw

multi_tb.ghw: analyze.ready
	$(GHDLE) multi_tb
	$(GHDLR) multi_tb --stop-time=1000ns --wave=multi_tb.ghw

tdc_chan_tb.ghw: analyze.ready
	$(GHDLE) tdc_chan_tb
	$(GHDLR) tdc_chan_tb --stop-time=750ns --wave=tdc_chan_tb.ghw

tdc_hit_mux_tb.ghw: analyze.ready
	$(GHDLE) tdc_hit_mux_tb
	$(GHDLR) tdc_hit_mux_tb --stop-time=750ns --wave=tdc_hit_mux_tb.ghw

trigger_tdc_tb.ghw: analyze.ready
	$(GHDLE) trigger_tdc_tb
	$(GHDLR) trigger_tdc_tb --stop-time=750ns --wave=trigger_tdc_tb.ghw

event_builder_tb.ghw: analyze.ready
	$(GHDLE) event_builder_tb
	$(GHDLR) event_builder_tb --stop-time=250us --wave=event_builder_tb.ghw

event_builder2_tb.ghw: analyze.ready
	$(GHDLR) event_builder2_tb --stop-time=250us --wave=event_builder2_tb.ghw

event_builder2_tb.fast: analyze.ready
	$(GHDLE) event_builder2_tb
	$(GHDLR) event_builder2_tb --stop-time=1000us

event_formatter_tb.ghw: analyze.ready
	$(GHDLE) event_formatter_tb
	$(GHDLR) event_formatter_tb --stop-time=100us --wave=event_formatter_tb.ghw

event_formatter_tb.fast: analyze.ready
	$(GHDLE) event_formatter_tb
	$(GHDLR) event_formatter_tb --stop-time=100us

fifo_tb.ghw: analyze.ready
	$(GHDLE) fifo_tb
	$(GHDLR) fifo_tb --stop-time=1000ns --wave=fifo_tb.ghw

