#
# default top-level display for event_builder_tb
#
gtkwave::addSignalsFromList [list {top.event_builder2_tb.trigger}]
gtkwave::addSignalsFromList [list {top.event_builder2_tb.rst}]
gtkwave::addSignalsFromList [list {top.event_builder2_tb.s_pulse}]
gtkwave::addSignalsFromList [list {top.event_builder2_tb.trig_valid}]
gtkwave::addSignalsFromList [list {top.event_builder2_tb.rd_ena}]
gtkwave::addSignalsFromList [list {top.event_builder2_tb.empty}]
gtkwave::addSignalsFromList [list {top.event_builder2_tb.trig_empty}]
gtkwave::addSignalsFromList [list {top.event_builder2_tb.trig_rd_ena}]
    
gtkwave::/Time/Zoom/Zoom_Full

