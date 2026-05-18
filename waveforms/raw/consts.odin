package raw

@private PULSE_LOW_LIMIT :: f32(.005)
@private PULSE_HIGH_LIMIT :: f32(.995)

Waveform_Pair_Proc :: struct {
    wave_proc:      proc(f32, f32) -> f32,
    start_scale:    f32,
    end_scale:      f32,
}

Morphing_Waveform :: enum {
    Sine,
    Triangle,
    Square,
    Saw,
}