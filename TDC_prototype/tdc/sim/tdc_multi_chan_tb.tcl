#
# default top-level display for tdc_multi_chan_tb
#
gtkwave::addSignalsFromList [list {top.tdc_multi_chan_tb.s_pulse}]
gtkwave::addSignalsFromList [list {top.tdc_multi_chan_tb.trigger}]
gtkwave::addSignalsFromList [list {top.tdc_multi_chan_tb.rd_ena}]
gtkwave::addSignalsFromList [list {top.tdc_multi_chan_tb.empty}]
gtkwave::addSignalsFromList [list {top.tdc_multi_chan_tb.full}]
gtkwave::addSignalsFromList [list {top.tdc_multi_chan_tb.tdc_multi_chan_1.fill_count}]

gtkwave::/Time/Zoom/Zoom_Full

