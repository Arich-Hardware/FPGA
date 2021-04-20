#
# default top-level display for tdc_chan_tb
#
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.clk0}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.pulse}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.trigger}]

gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.rise}];
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.fall}];

gtkwave::addSignalsFromList [list {top.tdc_chan_tb.output.hit.le_phase}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.output.hit.le_time}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.output.hit.te_phase}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.output.hit.te_time}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.output.buffer_number}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.buffer_valid}]

gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.tdc_hit_mux_1.current_buffer}]

gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[0].tdc_hit_1.busy}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[1].tdc_hit_1.busy}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[2].tdc_hit_1.busy}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[3].tdc_hit_1.busy}]

gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[0].tdc_hit_1.active}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[1].tdc_hit_1.active}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[2].tdc_hit_1.active}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[3].tdc_hit_1.active}]

gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[0].tdc_hit_1.valid}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[1].tdc_hit_1.valid}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[2].tdc_hit_1.valid}]
gtkwave::addSignalsFromList [list {top.tdc_chan_tb.tdc_chan_1.g_hits[3].tdc_hit_1.valid}]

gtkwave::/Time/Zoom/Zoom_Full

