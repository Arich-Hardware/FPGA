#
# default top-level display for tdc_with_fifo_tb
#
gtkwave::addSignalsFromList [list {top.tdc_with_fifo_tb.pulse}]
gtkwave::addSignalsFromList [list {top.tdc_with_fifo_tb.trigger}]
gtkwave::addSignalsFromList [list {top.tdc_with_fifo_tb.rd_ena}]
gtkwave::addSignalsFromList [list {top.tdc_with_fifo_tb.empty}]
gtkwave::addSignalsFromList [list {top.tdc_with_fifo_tb.full}]
gtkwave::addSignalsFromList [list {top.tdc_with_fifo_tb.fifo_out_rec.hit.le_phase}]
gtkwave::addSignalsFromList [list {top.tdc_with_fifo_tb.fifo_out_rec.hit.le_time}]
gtkwave::addSignalsFromList [list {top.tdc_with_fifo_tb.fifo_out_rec.hit.te_phase}]
gtkwave::addSignalsFromList [list {top.tdc_with_fifo_tb.fifo_out_rec.hit.te_time}]
gtkwave::addSignalsFromList [list {top.tdc_with_fifo_tb.fifo_out_rec.buffer_number}]



gtkwave::/Time/Zoom/Zoom_Full

