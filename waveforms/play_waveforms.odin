package waveforms

import "core:math"
import "../mathx"


Waveform_Warp_Matrix := [Waveform][Waveform]Waveform_Pair_Proc {
    .Sine = {
        .Sine =     { sine_to_pulse,        SINE_SCALE,     SINE_PULSE_SCALE },
        .Triangle = { sine_to_triangle,     SINE_SCALE,     TRIANGLE_SCALE },
        .Square =   { sine_to_square,       SINE_SCALE,     SQUARE_SCALE },
        .Saw =      { sine_to_saw,          SINE_SCALE,     SAW_SCALE },
        .White =    { sine_to_white,        SINE_SCALE,     1 },
    },
    .Triangle = {
        .Sine =     { triangle_to_sine,     TRIANGLE_SCALE, SINE_SCALE },
        .Triangle = { triangle_to_pulse,    TRIANGLE_SCALE, TRIANGLE_SCALE },
        .Square =   { triangle_to_square,   TRIANGLE_SCALE, SQUARE_SCALE },
        .Saw =      { triangle_to_saw,      TRIANGLE_SCALE, SAW_SCALE },
        .White =    { triangle_to_white,    TRIANGLE_SCALE, 1 },
    },
    .Square = {
        .Sine =     { square_to_sine,       SQUARE_SCALE,   SINE_SCALE },
        .Triangle = { square_to_triangle,   SQUARE_SCALE,   TRIANGLE_SCALE },
        .Square =   { square_to_pulse,      SQUARE_SCALE,   SQUARE_SCALE },
        .Saw =      { square_to_saw,        SQUARE_SCALE,   SAW_SCALE },
        .White =    { square_to_white,      SQUARE_SCALE,   1 },
    },
    .Saw = {
        .Sine =     { saw_to_sine,          SAW_SCALE,      SINE_SCALE },
        .Triangle = { saw_to_triangle,      SAW_SCALE,      TRIANGLE_SCALE },
        .Square =   { saw_to_square,        SAW_SCALE,      SQUARE_SCALE },
        .Saw =      { saw_to_pulse,         SAW_SCALE,      SAW_SCALE },
        .White =    { saw_to_white,         SAW_SCALE,      1 },
    },
    .White = {
        .Sine =     { white_to_sine,        1,              SINE_SCALE },
        .Triangle = { white_to_triangle,    1,              TRIANGLE_SCALE },
        .Square =   { white_to_square,      1,              SQUARE_SCALE },
        .Saw =      { white_to_saw,         1,              SAW_SCALE },
        .White =    { white_to_pulse,       1,              1 },
    },
}


get_wave_value :: proc(phase: f32, wav_1, wav_2: Waveform, warp: f32 = 0, unscaled: bool = false) -> f32
{
    value: f32

    phase_quantize : f32 = 32
    _phase := phase//f32(math.round(phase * phase_quantize)) / phase_quantize

    scale : f32 = 1

    switch wav_1
    {
        case .Sine:
            switch wav_2
            {
                case .Sine:
                    value = sine_to_pulse(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SINE_SCALE, SINE_PULSE_SCALE, warp) }
                case .Triangle:
                    value = sine_to_triangle(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SINE_SCALE, TRIANGLE_SCALE, warp) }
                case .Square:
                    value = sine_to_square(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SINE_SCALE, SQUARE_SCALE, warp) }
                case .Saw:
                    value = sine_to_saw(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SINE_SCALE, SAW_SCALE, warp) }
                case .White:
                    value = sine_to_white(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SINE_SCALE, NOISE_SCALE, warp) }
            }
        case .Triangle:
            switch wav_2
            {
                case .Sine:
                    value = triangle_to_sine(_phase, warp)
                    if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SINE_SCALE, warp) }
                case .Triangle:
                    value = triangle_to_pulse(_phase, warp)
                    if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, TRIANGLE_SCALE, warp) }
                case .Square:
                    value = triangle_to_square(_phase, warp)
                    if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SQUARE_SCALE, warp) }
                case .Saw:
                    value = triangle_to_saw(_phase, warp)
                    if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SAW_SCALE, warp) }
                case .White:
                    value = triangle_to_white(_phase, warp)
                    if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, NOISE_SCALE, warp) }
            }
        case .Square:
            switch wav_2
            {
                case .Sine:
                    value = square_to_sine(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SQUARE_SCALE, SINE_PULSE_SCALE, warp) }
                case .Triangle:
                    value = square_to_triangle(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SQUARE_SCALE, TRIANGLE_SCALE, warp) }
                case .Square:
                    value = square_to_pulse(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SQUARE_SCALE, SQUARE_SCALE, warp) }
                case .Saw:
                    value = square_to_saw(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SQUARE_SCALE, SAW_SCALE, warp) }
                case .White:
                    value = square_to_white(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SQUARE_SCALE, NOISE_SCALE, warp) }
            }
        case .Saw:
            switch wav_2
            {
                case .Sine:
                    value = saw_to_sine(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SAW_SCALE, SINE_PULSE_SCALE, warp) }
                case .Triangle:
                    value = saw_to_triangle(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SAW_SCALE, TRIANGLE_SCALE, warp) }
                case .Square:
                    value = saw_to_square(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SAW_SCALE, SQUARE_SCALE, warp) }
                case .Saw:
                    value = saw_to_pulse(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SAW_SCALE, SAW_SCALE, warp) }
                case .White:
                    value = saw_to_white(_phase, warp)
                    if !unscaled { scale = mathx.lerp(SAW_SCALE, NOISE_SCALE, warp) }
            }
        case .White:
            switch wav_2
            {
                case .Sine:
                    value = white_to_sine(_phase, warp)
                    if !unscaled { scale = mathx.lerp(NOISE_SCALE, SINE_PULSE_SCALE, warp) }
                case .Triangle:
                    value = white_to_triangle(_phase, warp)
                    if !unscaled { scale = mathx.lerp(NOISE_SCALE, TRIANGLE_SCALE, warp) }
                case .Square:
                    value = white_to_square(_phase, warp)
                    if !unscaled { scale = mathx.lerp(NOISE_SCALE, SQUARE_SCALE, warp) }
                case .Saw:
                    value = white_to_saw(_phase, warp)
                    if !unscaled { scale = mathx.lerp(NOISE_SCALE, SAW_SCALE, warp) }
                case .White:
                    value = white_to_pulse(_phase, warp)
                    if !unscaled { scale = mathx.lerp(NOISE_SCALE, NOISE_SCALE, warp) }
            }
    }

    // if wav_limit := int(Waveform.White); int(wav_1) <= wav_limit && int(wav_2) <= wav_limit
    // {
    //     _proc := Waveform_Warp_Matrix[wav_1][wav_2]
    //     value = _proc.wave_proc(_phase, warp)
    //     if !unscaled { scale = mathx.lerp(_proc.start_scale, _proc.end_scale, warp) }
    // }

    value_quantize : f32 = 32
    _value := value//f32(math.round(value * value_quantize)) / value_quantize

    return _value * scale
}

get_wave_values :: proc(buffer: []f32, phase_start, phase_end: f32, wav_1, wav_2: Waveform, warp: f32)
{
    count := len(buffer)
    step := (phase_end - phase_start) / f32(count - 1)

    phase := mathx.wrap_01(phase_start)
    for i in 0..<count
    {
        buffer[i] = f32(get_wave_value(phase, wav_1, wav_2, warp, true))
        phase += step
        
        if phase >= 1
        {
            phase -= 1
        }
        else if phase < 0
        {
            phase += 1
        }
    }
}

waveform_pair :: proc(wav_1, wav_2: Waveform) -> int
{
    return (int(wav_1) << 8) | int(wav_2)
}