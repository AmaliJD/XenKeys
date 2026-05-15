package waveforms

import "core:math"
import "../mathx"
import "raw"


get_wave_value :: proc(phase: f32, wav_1: Waveform, wav_2: Waveform, warp: f32 = 0, unscaled: bool = false) -> f32 {
    value: f32
    // waveform_pair := int(waveform) * 10 + int(waveform2)

    phase_quantize : f32 = 32
    _phase := phase//f32(math.round(phase * phase_quantize)) / phase_quantize

    scale : f32 = 1
    switch waveform_pair(wav_1, wav_2)
    {
        case waveform_pair(.Sine, .Sine):
            value = raw.sine_to_pulse(_phase, warp)
            if !unscaled { scale = mathx.lerp(1, SINE_PULSE_SCALE, warp) }

        case waveform_pair(.Sine, .Triangle):
            value = raw.sine_to_triangle(_phase, warp)
            if !unscaled { scale = mathx.lerp(1, TRIANGLE_SCALE, warp) }

        case waveform_pair(.Sine, .Saw):
            value = raw.sine_to_saw(_phase, warp)
            if !unscaled { scale = mathx.lerp(1, SAW_SCALE, warp) }

        case waveform_pair(.Sine, .Square):
            value = raw.sine_to_square(_phase, warp)
            if !unscaled { scale = mathx.lerp(1, SQUARE_SCALE, warp) }

        case waveform_pair(.Triangle, .Sine):
            value = raw.triangle_to_sine(_phase, warp)
            if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, 1, warp) }

        case waveform_pair(.Triangle, .Triangle):
            value = raw.triangle_to_pulse(_phase, warp)
            if !unscaled { scale = TRIANGLE_SCALE }

        case waveform_pair(.Square, .Square):
            value = raw.square_shift_duty_cycle(_phase, warp)
            if !unscaled { scale = SQUARE_SCALE }

        case waveform_pair(.Saw, .Saw):
            value = raw.saw_to_pulse(_phase, warp)
            if !unscaled { scale = SAW_SCALE }

        case waveform_pair(.Square, .Sine):
            value = raw.square_to_sine(_phase, warp)
            if !unscaled { scale = mathx.lerp(SQUARE_SCALE, 1, warp) }

        case waveform_pair(.Saw, .Sine):
            value = raw.saw_to_sine(_phase, warp)
            if !unscaled { scale = mathx.lerp(SAW_SCALE, 1, warp) }

        case waveform_pair(.Triangle, .Square):
            value = raw.triangle_to_square(_phase, warp)
            if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SQUARE_SCALE, warp) }

        case waveform_pair(.Square, .Triangle):
            value = raw.square_to_triangle(_phase, warp)
            if !unscaled { scale = mathx.lerp(SQUARE_SCALE, TRIANGLE_SCALE, warp) }

        case waveform_pair(.Triangle, .Saw):
            value = raw.triangle_to_saw(_phase, warp)
            if !unscaled { scale = mathx.lerp(TRIANGLE_SCALE, SAW_SCALE, warp) }

        case waveform_pair(.Saw, .Triangle):
            value = raw.saw_to_triangle(_phase, warp)
            if !unscaled { scale = mathx.lerp(SAW_SCALE, TRIANGLE_SCALE, warp) }

        case waveform_pair(.Saw, .Square):
            value = raw.saw_to_square(_phase, warp)
            if !unscaled { scale = mathx.lerp(SAW_SCALE, SQUARE_SCALE, warp) }

        case waveform_pair(.Square, .Saw):
            value = raw.square_to_saw(_phase, warp)
            if !unscaled { scale = mathx.lerp(SQUARE_SCALE, SAW_SCALE, warp) }
        // case 40, 41, 42, 43, 44, 45:
        //     value = explicit_harmonics(harmonics[:], volume_limiter, _phase)
        // case:
        //     value = test(_phase)
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
        buffer[i] = get_wave_value(phase, wav_1, wav_2, warp, true)
        phase += step
    }
}

waveform_pair :: proc(wav_1, wav_2: Waveform) -> int
{
    return (int(wav_1) << 8) | int(wav_2)
}