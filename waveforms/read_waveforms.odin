package waveforms

import "core:math"
import "../mathx"
import "raw"


Raw_Waveform_Pair_Proc_Matrix := [raw.Morphing_Waveform][raw.Morphing_Waveform]raw.Waveform_Pair_Proc {
    .Sine = {
        .Sine =     { raw.sine_to_pulse,        SINE_SCALE,     SINE_PULSE_SCALE },
        .Triangle = { raw.sine_to_triangle,     SINE_SCALE,     TRIANGLE_SCALE },
        .Square =   { raw.sine_to_square,       SINE_SCALE,     SQUARE_SCALE },
        .Saw =      { raw.sine_to_saw,          SINE_SCALE,     SAW_SCALE },
    },
    .Triangle = {
        .Sine =     { raw.triangle_to_sine,     TRIANGLE_SCALE, SINE_SCALE },
        .Triangle = { raw.triangle_to_pulse,    TRIANGLE_SCALE, TRIANGLE_SCALE },
        .Square =   { raw.triangle_to_square,   TRIANGLE_SCALE, SQUARE_SCALE },
        .Saw =      { raw.triangle_to_saw,      TRIANGLE_SCALE, SAW_SCALE },
    },
    .Square = {
        .Sine =     { raw.square_to_sine,       SQUARE_SCALE,   SINE_SCALE },
        .Triangle = { raw.square_to_triangle,   SQUARE_SCALE,   TRIANGLE_SCALE },
        .Square =   { raw.square_to_pulse,      SQUARE_SCALE,   SQUARE_SCALE },
        .Saw =      { raw.square_to_saw,        SQUARE_SCALE,   SAW_SCALE },
    },
    .Saw = {
        .Sine =     { raw.saw_to_sine,          SAW_SCALE,      SINE_SCALE },
        .Triangle = { raw.saw_to_triangle,      SAW_SCALE,      TRIANGLE_SCALE },
        .Square =   { raw.saw_to_square,        SAW_SCALE,      SQUARE_SCALE },
        .Saw =      { raw.saw_to_pulse,         SAW_SCALE,      SAW_SCALE },
    },
}


get_wave_value :: proc(phase: f32, wav_1: Waveform, wav_2: Waveform, warp: f32 = 0, unscaled: bool = false) -> f32 {
    value: f32
    // waveform_pair := int(waveform) * 10 + int(waveform2)

    phase_quantize : f32 = 32
    _phase := phase//f32(math.round(phase * phase_quantize)) / phase_quantize

    scale : f32 = 1

    if wav_limit := int(Waveform.Saw); int(wav_1) <= wav_limit && int(wav_2) <= wav_limit
    {
        _proc := Raw_Waveform_Pair_Proc_Matrix[raw.Morphing_Waveform(int(wav_1))][raw.Morphing_Waveform(int(wav_2))]
        value = _proc.wave_proc(_phase, warp)
        if !unscaled { scale = mathx.lerp(_proc.start_scale, _proc.end_scale, warp) }
    }

    value_quantize : f32 = 32
    _value := value//f32(math.round(value * value_quantize)) / value_quantize

    return _value * scale
}

get_wave_values :: proc(buffer: []f32, start_phase, end_phase: f32, wav_1: Waveform, wav_2: Waveform, warp: f32) {
    count := len(buffer)
    step := (end_phase - start_phase) / f32(count - 1)

    phase := start_phase
    for i in 0..<count {
        buffer[i] = f32(get_wave_value(phase, wav_1, wav_2, warp, true))
        phase += step
    }
}

waveform_pair :: proc(wav_1, wav_2: Waveform) -> int
{
    return (int(wav_1) << 8) | int(wav_2)
}