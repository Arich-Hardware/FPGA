
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.my_textio.all;
use work.tdc_types.all;

package tdc_types_textio is
-- RECORD type tdc_buffer
  procedure READ( L:inout LINE; VALUE: out tdc_buffer);
  procedure WRITE( L:inout LINE; VALUE: in tdc_buffer);
-- ARRAY type tdc_buffer_group
  procedure READ( L:inout LINE; VALUE: out tdc_buffer_group);
  procedure WRITE( L:inout LINE; VALUE: in tdc_buffer_group);
-- RECORD type tdc_output
  procedure READ( L:inout LINE; VALUE: out tdc_output);
  procedure WRITE( L:inout LINE; VALUE: in tdc_output);
-- RECORD type tdc_hit_data
  procedure READ( L:inout LINE; VALUE: out tdc_hit_data);
  procedure WRITE( L:inout LINE; VALUE: in tdc_hit_data);
-- RECORD type trigger_tdc_hit
  procedure READ( L:inout LINE; VALUE: out trigger_tdc_hit);
  procedure WRITE( L:inout LINE; VALUE: in trigger_tdc_hit);
-- ARRAY type tdc_output_array
  procedure READ( L:inout LINE; VALUE: out tdc_output_array);
  procedure WRITE( L:inout LINE; VALUE: in tdc_output_array);

end tdc_types_textio;

package body tdc_types_textio is

  procedure READ( L:inout LINE; VALUE: out tdc_buffer) is
    variable v_data : tdc_buffer;
  begin
    READ(L, v_data.hit);
    READ(L, v_data.readme);
  VALUE := v_data;
  end READ;

  procedure WRITE( L:inout LINE; VALUE: in tdc_buffer) is
    variable v_SPC : character := ' ';
  begin
    WRITE(L, VALUE.hit);
    WRITE(L, v_SPC);
    WRITE(L, VALUE.readme);
    WRITE(L, v_SPC);
  end WRITE;

  procedure READ( L:inout LINE; VALUE: out tdc_buffer_group) is
    variable v_data : tdc_buffer_group;
  begin
    for i in 0 to NUM_TDC_BUFFERS-1 loop
      READ( L, VALUE(i));
    end loop;
  VALUE := v_data;
  end READ;

  procedure WRITE( L:inout LINE; VALUE: in tdc_buffer_group) is
    variable v_SPC : character := ' ';
  begin
    for i in 0 to NUM_TDC_BUFFERS-1 loop
      WRITE( L, VALUE(i));
      WRITE(L,' ');
    end loop;
  end WRITE;

  procedure READ( L:inout LINE; VALUE: out tdc_output) is
    variable v_data : tdc_output;
  begin
    READ(L, v_data.hit);
    READ(L, v_data.trigger_number);
    READ(L, v_data.buffer_number);
    READ(L, v_data.glitch);
    READ(L, v_data.error);
  VALUE := v_data;
  end READ;

  procedure WRITE( L:inout LINE; VALUE: in tdc_output) is
    variable v_SPC : character := ' ';
  begin
    WRITE(L, VALUE.hit);
    WRITE(L, v_SPC);
    WRITE(L, VALUE.trigger_number);
    WRITE(L, v_SPC);
    WRITE(L, VALUE.buffer_number);
    WRITE(L, v_SPC);
    WRITE(L, VALUE.glitch);
    WRITE(L, v_SPC);
    WRITE(L, VALUE.error);
    WRITE(L, v_SPC);
  end WRITE;

  procedure READ( L:inout LINE; VALUE: out tdc_hit_data) is
    variable v_data : tdc_hit_data;
  begin
    READ(L, v_data.le_time);
    DREAD(L, v_data.le_phase);
    READ(L, v_data.te_time);
    DREAD(L, v_data.te_phase);
  VALUE := v_data;
  end READ;

  procedure WRITE( L:inout LINE; VALUE: in tdc_hit_data) is
    variable v_SPC : character := ' ';
  begin
    WRITE(L, VALUE.le_time);
    WRITE(L, v_SPC);
    DWRITE(L, VALUE.le_phase);
    WRITE(L, v_SPC);
    WRITE(L, VALUE.te_time);
    WRITE(L, v_SPC);
    DWRITE(L, VALUE.te_phase);
    WRITE(L, v_SPC);
  end WRITE;

  procedure READ( L:inout LINE; VALUE: out trigger_tdc_hit) is
    variable v_data : trigger_tdc_hit;
  begin
    READ(L, v_data.trig_time);
    DREAD(L, v_data.trig_phase);
    READ(L, v_data.trig_event);
  VALUE := v_data;
  end READ;

  procedure WRITE( L:inout LINE; VALUE: in trigger_tdc_hit) is
    variable v_SPC : character := ' ';
  begin
    WRITE(L, VALUE.trig_time);
    WRITE(L, v_SPC);
    DWRITE(L, VALUE.trig_phase);
    WRITE(L, v_SPC);
    WRITE(L, VALUE.trig_event);
    WRITE(L, v_SPC);
  end WRITE;

  procedure READ( L:inout LINE; VALUE: out tdc_output_array) is
    variable v_data : tdc_output_array;
  begin
    for i in 0 to NUM_TDC_CHANNELS-1 loop
      READ( L, VALUE(i));
    end loop;
  VALUE := v_data;
  end READ;

  procedure WRITE( L:inout LINE; VALUE: in tdc_output_array) is
    variable v_SPC : character := ' ';
  begin
    for i in 0 to NUM_TDC_CHANNELS-1 loop
      WRITE( L, VALUE(i));
      WRITE(L,' ');
    end loop;
  end WRITE;

end tdc_types_textio;
