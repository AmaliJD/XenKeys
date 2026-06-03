package main

import "mathx"


// ----------------------------------------------------------------------------------- waveform type
Wav_Raw :: struct
{
    waveform: Waveform,
}


// ----------------------------------------------------------------------------------- consts
SINE_SCALE          :: f32(1)
TRIANGLE_SCALE      :: f32(.9)
SQUARE_SCALE        :: f32(0.35)
SAW_SCALE           :: f32(0.4)
SINE_PULSE_SCALE    :: f32(0.5)
NOISE_SCALE         :: f32(0.4)

PULSE_LOW_LIMIT     :: f32(.005)
PULSE_HIGH_LIMIT    :: f32(.995)


// ----------------------------------------------------------------------------------- proc selector
Waveform_Raw_Warp_Proc :: struct
{
    wave_proc:      proc(f32, f32) -> f32,
    start_scale:    f32,
    end_scale:      f32,
}

Waveform_Raw_Warp_Matrix := [Waveform][Waveform]Waveform_Raw_Warp_Proc {
    .Sine = {
        .Sine =     { sine_to_pulse,        SINE_SCALE,     SINE_PULSE_SCALE },
        .Triangle = { sine_to_triangle,     SINE_SCALE,     TRIANGLE_SCALE },
        .Square =   { sine_to_square,       SINE_SCALE,     SQUARE_SCALE },
        .Saw =      { sine_to_saw,          SINE_SCALE,     SAW_SCALE },
        .White =    { sine_to_white,        SINE_SCALE,     NOISE_SCALE },
    },
    .Triangle = {
        .Sine =     { triangle_to_sine,     TRIANGLE_SCALE, SINE_SCALE },
        .Triangle = { triangle_to_pulse,    TRIANGLE_SCALE, TRIANGLE_SCALE },
        .Square =   { triangle_to_square,   TRIANGLE_SCALE, SQUARE_SCALE },
        .Saw =      { triangle_to_saw,      TRIANGLE_SCALE, SAW_SCALE },
        .White =    { triangle_to_white,    TRIANGLE_SCALE, NOISE_SCALE },
    },
    .Square = {
        .Sine =     { square_to_sine,       SQUARE_SCALE,   SINE_SCALE },
        .Triangle = { square_to_triangle,   SQUARE_SCALE,   TRIANGLE_SCALE },
        .Square =   { square_to_pulse,      SQUARE_SCALE,   SQUARE_SCALE },
        .Saw =      { square_to_saw,        SQUARE_SCALE,   SAW_SCALE },
        .White =    { square_to_white,      SQUARE_SCALE,   NOISE_SCALE },
    },
    .Saw = {
        .Sine =     { saw_to_sine,          SAW_SCALE,      SINE_SCALE },
        .Triangle = { saw_to_triangle,      SAW_SCALE,      TRIANGLE_SCALE },
        .Square =   { saw_to_square,        SAW_SCALE,      SQUARE_SCALE },
        .Saw =      { saw_to_pulse,         SAW_SCALE,      SAW_SCALE },
        .White =    { saw_to_white,         SAW_SCALE,      NOISE_SCALE },
    },
    .White = {
        .Sine =     { white_to_sine,        NOISE_SCALE,    SINE_SCALE },
        .Triangle = { white_to_triangle,    NOISE_SCALE,    TRIANGLE_SCALE },
        .Square =   { white_to_square,      NOISE_SCALE,    SQUARE_SCALE },
        .Saw =      { white_to_saw,         NOISE_SCALE,    SAW_SCALE },
        .White =    { white_to_pulse,       NOISE_SCALE,    NOISE_SCALE },
    },
}


// ----------------------------------------------------------------------------------- get value
get_wav_raw :: get_wav_raw_matrix

@private
get_wav_raw_matrix :: proc(wav_1, wav_2: Waveform, phase, warp: f32, unscaled: bool) -> f32
{
    _proc := Waveform_Raw_Warp_Matrix[wav_1][wav_2]
    value := _proc.wave_proc(phase, warp)

    scale: f32 = 1
    if !unscaled
    {
        scale = mathx.lerp(_proc.start_scale, _proc.end_scale, warp)
    }

    return value * scale
}

@private
get_wav_raw_switch :: proc(wav_1, wav_2: Waveform, phase, warp: f32, unscaled: bool) -> f32
{
    value: f32
    scale: f32 = 1

    switch wav_1
    {
        case .Sine:
            switch wav_2
            {
                case .Sine:
                    value = sine_to_pulse(phase, warp)
                    if !unscaled { scale = mathx.lerp(SINE_SCALE, SINE_PULSE_SCALE, warp) }
                case .Triangle:
                    value = sine_to_triangle(phase, warp)
                    if !unscaled { scale = mathx.lerp(SINE_SCALE, TRIANGLE_SCALE, warp) }
                case .Square:
                    value = sine_to_square(phase, warp)
                    if !unscaled { scale = mathx.lerp(SINE_SCALE, SQUARE_SCALE, warp) }
                case .Saw:
                    value = sine_to_saw(phase, warp)
                    if !unscaled { scale = mathx.lerp(SINE_SCALE, SAW_SCALE, warp) }
                case .White:
                    value = sine_to_white(phase, warp)
                    if !unscaled { scale = mathx.lerp(SINE_SCALE, NOISE_SCALE, warp) }
            }
        case .Triangle:
            switch wav_2
            {
                case .Sine:
                    value = triangle_to_sine(phase, warp)
                    if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SINE_SCALE, warp) }
                case .Triangle:
                    value = triangle_to_pulse(phase, warp)
                    if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, TRIANGLE_SCALE, warp) }
                case .Square:
                    value = triangle_to_square(phase, warp)
                    if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SQUARE_SCALE, warp) }
                case .Saw:
                    value = triangle_to_saw(phase, warp)
                    if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SAW_SCALE, warp) }
                case .White:
                    value = triangle_to_white(phase, warp)
                    if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, NOISE_SCALE, warp) }
            }
        case .Square:
            switch wav_2
            {
                case .Sine:
                    value = square_to_sine(phase, warp)
                    if !unscaled { scale = mathx.lerp(SQUARE_SCALE, SINE_PULSE_SCALE, warp) }
                case .Triangle:
                    value = square_to_triangle(phase, warp)
                    if !unscaled { scale = mathx.lerp(SQUARE_SCALE, TRIANGLE_SCALE, warp) }
                case .Square:
                    value = square_to_pulse(phase, warp)
                    if !unscaled { scale = mathx.lerp(SQUARE_SCALE, SQUARE_SCALE, warp) }
                case .Saw:
                    value = square_to_saw(phase, warp)
                    if !unscaled { scale = mathx.lerp(SQUARE_SCALE, SAW_SCALE, warp) }
                case .White:
                    value = square_to_white(phase, warp)
                    if !unscaled { scale = mathx.lerp(SQUARE_SCALE, NOISE_SCALE, warp) }
            }
        case .Saw:
            switch wav_2
            {
                case .Sine:
                    value = saw_to_sine(phase, warp)
                    if !unscaled { scale = mathx.lerp(SAW_SCALE, SINE_PULSE_SCALE, warp) }
                case .Triangle:
                    value = saw_to_triangle(phase, warp)
                    if !unscaled { scale = mathx.lerp(SAW_SCALE, TRIANGLE_SCALE, warp) }
                case .Square:
                    value = saw_to_square(phase, warp)
                    if !unscaled { scale = mathx.lerp(SAW_SCALE, SQUARE_SCALE, warp) }
                case .Saw:
                    value = saw_to_pulse(phase, warp)
                    if !unscaled { scale = mathx.lerp(SAW_SCALE, SAW_SCALE, warp) }
                case .White:
                    value = saw_to_white(phase, warp)
                    if !unscaled { scale = mathx.lerp(SAW_SCALE, NOISE_SCALE, warp) }
            }
        case .White:
            switch wav_2
            {
                case .Sine:
                    value = white_to_sine(phase, warp)
                    if !unscaled { scale = mathx.lerp(NOISE_SCALE, SINE_PULSE_SCALE, warp) }
                case .Triangle:
                    value = white_to_triangle(phase, warp)
                    if !unscaled { scale = mathx.lerp(NOISE_SCALE, TRIANGLE_SCALE, warp) }
                case .Square:
                    value = white_to_square(phase, warp)
                    if !unscaled { scale = mathx.lerp(NOISE_SCALE, SQUARE_SCALE, warp) }
                case .Saw:
                    value = white_to_saw(phase, warp)
                    if !unscaled { scale = mathx.lerp(NOISE_SCALE, SAW_SCALE, warp) }
                case .White:
                    value = white_to_pulse(phase, warp)
                    if !unscaled { scale = mathx.lerp(NOISE_SCALE, NOISE_SCALE, warp) }
            }
    }

    return value * scale
}