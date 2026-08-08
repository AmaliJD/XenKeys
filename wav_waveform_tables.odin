package main

import "core:math"
import "mathx"

TABLE_LENGTH :: 16384
sine_table : [TABLE_LENGTH]f32;

init_waveform_tables :: proc()
{
	for i in 0..<TABLE_LENGTH
    {
        phase := f32(i) / f32(TABLE_LENGTH)
        phase = math.wrap(phase, 1)
        sin_value := math.sin_f32(phase * math.TAU)
        sine_table[i] = sin_value
    }
}

get_sine_table :: proc(phase: f32, pulse_mod: f32 = 0) -> f32
{
    index := int(phase * TABLE_LENGTH) & (TABLE_LENGTH - 1)

    // return sine_table[index]
    if pulse_mod == 0
    {
        return sine_table[index]
    }
    else
    {
        val := sine_table[index]
        sign := math.sign(val)
        abs := math.abs(val)
        pow := mathx.remap(pulse_mod, 0, 1, 1, 25)
        return math.pow(abs, pow) * sign
    }
}