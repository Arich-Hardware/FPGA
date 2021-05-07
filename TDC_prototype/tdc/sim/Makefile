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

# latest: fifo_tb.ghw
latest: event_builder2_tb.ghw

all: multi_tb.ghw tdc_chan_tb.ghw tdc_hit_tb.ghw tdc_hit_mux_tb.ghw tdc_with_fifo_tb.ghw \
	tdc_multi_chan_tb.ghw

clean:
	rm -f *~ *.cf *.vcd *.ghw *.db

# create the custom types DB from the YAML file
tdc_types.db: ../src/tdc_types.yml
	$(PERLRUN) ../../../yml2tb/yamldump.pl ../src/tdc_types.yml tdc_types.db

# create custom textio functions from the types DB
tdc_types_textio.vhd: tdc_types.db
	$(PERLRUN) ../../../yml2tb/yaml2textio.pl tdc_types.db tdc_types_textio.vhd tdc_types

# create the VHDL types from the YAML file using yml2hdl
../src/tdc_types.vhd: ../src/tdc_types.yml
	python ../../../yml2hdl/yml2hdl.py ../src/tdc_types.yml

tdc_multi_chan_tb.ghw: ../src/multi_sample.vhd ../src/decode.vhd tdc_with_fifo_tb.vhd ../src/tdc_chan.vhd \
	../src/tdc_types.vhd ../src/web_fifo.vhd ../src/tdc_with_fifo.vhd ../src/tdc_hit_mux.vhd \
	../src/tdc_multi_chan.vhd
	rm -f work-obj93.cf
	$(GHDLA) ../src/tdc_types.vhd
	$(GHDLA) my_textio.vhd
	$(GHDLA) tdc_types_textio.vhd
	$(GHDLA) ../src/tdc_hit.vhd
	$(GHDLA) ../src/tdc_hit_mux.vhd
	$(GHDLA) ../src/multi_sample.vhd
	$(GHDLA) ../src/decode.vhd
	$(GHDLA) ../src/tdc_chan.vhd
	$(GHDLA) ../src/web_fifo.vhd
	$(GHDLA) ../src/tdc_with_fifo.vhd
	$(GHDLA) ../src/tdc_multi_chan.vhd
	$(GHDLA) tdc_multi_chan_tb.vhd
	$(GHDLE) tdc_multi_chan_tb
	$(GHDLR) tdc_multi_chan_tb --stop-time=1000us --wave=tdc_multi_chan_tb.ghw

tdc_hit_tb.ghw: tdc_hit_tb.vhd ../src/tdc_hit.vhd ../src/tdc_types.vhd
	rm -f work-obj93.cf
	$(GHDLA) ../src/tdc_types.vhd
	$(GHDLA) ../src/tdc_hit.vhd
	$(GHDLA) tdc_hit_tb.vhd
	$(GHDLE) tdc_hit_tb
	$(GHDLR) tdc_hit_tb --stop-time=750ns --wave=tdc_hit_tb.ghw

tdc_with_fifo_tb.ghw: ../src/multi_sample.vhd ../src/decode.vhd tdc_with_fifo_tb.vhd ../src/tdc_chan.vhd \
	../src/tdc_types.vhd ../src/web_fifo.vhd ../src/tdc_with_fifo.vhd ../src/tdc_hit_mux.vhd
	rm -f work-obj93.cf
	$(GHDLA) ../src/tdc_types.vhd
	$(GHDLA) ../src/tdc_hit.vhd
	$(GHDLA) ../src/tdc_hit_mux.vhd
	$(GHDLA) ../src/multi_sample.vhd
	$(GHDLA) ../src/decode.vhd
	$(GHDLA) ../src/tdc_chan.vhd
	$(GHDLA) ../src/web_fifo.vhd
	$(GHDLA) ../src/tdc_with_fifo.vhd
	$(GHDLA) tdc_with_fifo_tb.vhd
	$(GHDLE) tdc_with_fifo_tb
	$(GHDLR) tdc_with_fifo_tb --stop-time=750ns --wave=tdc_with_fifo_tb.ghw

multi_tb.ghw: ../src/multi_sample.vhd ../src/multi_tb.vhd ../src/decode.vhd ../src/tdc_types.vhd
	rm -f work-obj93.cf
	$(GHDLA) ../src/tdc_types.vhd
	$(GHDLA) ../src/decode.vhd
	$(GHDLA) ../src/multi_sample.vhd
	$(GHDLA) ../src/multi_tb.vhd
	$(GHDLE) multi_tb
	$(GHDLR) multi_tb --stop-time=1000ns --wave=multi_tb.ghw

tdc_chan_tb.ghw: ../src/multi_sample.vhd ../src/decode.vhd tdc_chan_tb.vhd ../src/tdc_chan.vhd \
	../src/tdc_types.vhd ../src/tdc_hit_mux.vhd tdc_types_textio.vhd my_textio.vhd
	rm -f work-obj93.cf
	$(GHDLA) ../src/tdc_types.vhd
	$(GHDLA) my_textio.vhd
	$(GHDLA) tdc_types_textio.vhd
	$(GHDLA) ../src/tdc_hit.vhd
	$(GHDLA) ../src/tdc_hit_mux.vhd
	$(GHDLA) ../src/decode.vhd
	$(GHDLA) ../src/multi_sample.vhd
	$(GHDLA) ../src/tdc_chan.vhd
	$(GHDLA) tdc_chan_tb.vhd
	$(GHDLE) tdc_chan_tb
	$(GHDLR) tdc_chan_tb --stop-time=750ns --wave=tdc_chan_tb.ghw

tdc_hit_mux_tb.ghw: ../src/tdc_types.vhd ../src/tdc_hit_mux.vhd tdc_hit_mux_tb.vhd
	rm -f work-obj93.cf
	$(GHDLA) ../src/tdc_types.vhd
	$(GHDLA) ../src/tdc_hit_mux.vhd
	$(GHDLA) tdc_hit_mux_tb.vhd
	$(GHDLE) tdc_hit_mux_tb
	$(GHDLR) tdc_hit_mux_tb --stop-time=750ns --wave=tdc_hit_mux_tb.ghw

trigger_tdc_tb.ghw: ../src/trigger_tdc.vhd ../src/decode.vhd ../src/multi_sample.vhd \
	../src/tdc_types.vhd tdc_types_textio.vhd my_textio.vhd trigger_tdc_tb.vhd
	rm -f work-obj93.cf
	$(GHDLA) ../src/tdc_types.vhd
	$(GHDLA) my_textio.vhd
	$(GHDLA) tdc_types_textio.vhd
	$(GHDLA) ../src/decode.vhd
	$(GHDLA) ../src/multi_sample.vhd
	$(GHDLA) ../src/trigger_tdc.vhd
	$(GHDLA) trigger_tdc_tb.vhd
	$(GHDLE) trigger_tdc_tb
	$(GHDLR) trigger_tdc_tb --stop-time=750ns --wave=trigger_tdc_tb.ghw

event_builder_tb.ghw: ../src/event_builder.vhd ../src/decode.vhd ../src/multi_sample.vhd \
	../src/tdc_types.vhd tdc_types_textio.vhd my_textio.vhd event_builder_tb.vhd \
	../src/trigger_tdc.vhd ../src/tdc_chan.vhd ../src/tdc_multi_chan.vhd \
	../src/tdc_hit_mux.vhd ../src/tdc_hit.vhd ../src/tdc_with_fifo.vhd \
	../src/web_fifo.vhd ../src/trigger_tdc_with_fifo.vhd
	rm -f work-obj93.cf
	$(GHDLA) ../src/tdc_types.vhd
	$(GHDLA) my_textio.vhd
	$(GHDLA) tdc_types_textio.vhd
	$(GHDLA) ../src/decode.vhd
	$(GHDLA) ../src/multi_sample.vhd
#	$(GHDLA) ../src/event_builder.vhd
	$(GHDLA) ../src/tdc_hit.vhd
	$(GHDLA) ../src/tdc_hit_mux.vhd
	$(GHDLA) ../src/tdc_chan.vhd
	$(GHDLA) ../src/web_fifo.vhd
	$(GHDLA) ../src/tdc_with_fifo.vhd
	$(GHDLA) ../src/tdc_multi_chan.vhd
	$(GHDLA) ../src/trigger_tdc.vhd
	$(GHDLA) ../src/trigger_tdc_with_fifo.vhd
	$(GHDLA) event_builder_tb.vhd
	$(GHDLE) event_builder_tb
	$(GHDLR) event_builder_tb --stop-time=250us --wave=event_builder_tb.ghw

event_builder2_tb.ghw: ../src/event_builder.vhd ../src/decode.vhd ../src/multi_sample.vhd \
	../src/tdc_types.vhd tdc_types_textio.vhd my_textio.vhd event_builder2_tb.vhd \
	../src/trigger_tdc.vhd ../src/tdc_chan.vhd ../src/tdc_multi_chan.vhd \
	../src/tdc_hit_mux.vhd ../src/tdc_hit.vhd ../src/tdc_with_fifo.vhd \
	../src/web_fifo.vhd ../src/trigger_tdc_with_fifo.vhd
	rm -f work-obj93.cf
	$(GHDLA) ../src/tdc_types.vhd
	$(GHDLA) my_textio.vhd
	$(GHDLA) tdc_types_textio.vhd
	$(GHDLA) ../src/decode.vhd
	$(GHDLA) ../src/multi_sample.vhd
	$(GHDLA) ../src/event_builder.vhd
	$(GHDLA) ../src/tdc_hit.vhd
	$(GHDLA) ../src/tdc_hit_mux.vhd
	$(GHDLA) ../src/tdc_chan.vhd
	$(GHDLA) ../src/web_fifo.vhd
	$(GHDLA) ../src/tdc_with_fifo.vhd
	$(GHDLA) ../src/tdc_multi_chan.vhd
	$(GHDLA) ../src/trigger_tdc.vhd
	$(GHDLA) ../src/trigger_tdc_with_fifo.vhd
	$(GHDLA) event_builder2_tb.vhd
	$(GHDLE) event_builder2_tb
	$(GHDLR) event_builder2_tb --stop-time=100us --wave=event_builder2_tb.ghw

fifo_tb.ghw: ../src/web_fifo.vhd fifo_tb.vhd
	$(GHDLA) ../src/web_fifo.vhd
	$(GHDLA) fifo_tb.vhd
	$(GHDLE) fifo_tb
	$(GHDLR) fifo_tb --stop-time=1000ns --wave=fifo_tb.ghw
