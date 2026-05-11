package waveforms

import "core:math"

get_wave_value :: proc(phase: f32, waveform: Waveform, waveform2: Waveform, warp: f32 = 0, get_raw: bool = false) -> f32 {
    value: f32
    waveform_pair := int(waveform) * 10 + int(waveform2)

    phase_quantize : f32 = 32
    _phase := phase//f32(math.round(phase * phase_quantize)) / phase_quantize

    switch waveform_pair {
        case 00:
            // value = sine(_phase)
            value = sine_to_sine(_phase, warp) * (1 if get_raw else math.lerp(f32(1), NIPPLE_SCALE, warp))
        case 11:
            value = triangle(_phase) * (1 if get_raw else TRIANGLE_SCALE)
        case 22:
            value = square_to_square(_phase, warp) * (1 if get_raw else SQUARE_SCALE)
        case 33:
            value = saw(_phase) * (1 if get_raw else SAW_SCALE)
        case 01:
            value = sine_to_triangle(_phase, warp) * (1 if get_raw else math.lerp(f32(1), TRIANGLE_SCALE, warp))
        case 10:
            value = sine_to_triangle(_phase, 1 - warp) * (1 if get_raw else math.lerp(f32(1), TRIANGLE_SCALE, 1 - warp))
        case 02:
            value = sine_to_square(_phase, warp) * (1 if get_raw else math.lerp(f32(1), SQUARE_SCALE, warp))
        case 20:
            value = sine_to_square(_phase, 1 - warp) * (1 if get_raw else math.lerp(f32(1), SQUARE_SCALE, 1 - warp))
        case 03:
            value = sine_to_saw(_phase, warp) * (1 if get_raw else math.lerp(f32(1), SAW_SCALE, warp))
        case 30:
            value = sine_to_saw(_phase, 1 - warp) * (1 if get_raw else math.lerp(f32(1), SAW_SCALE, 1 - warp))
        case 12:
            value = triangle_to_square(_phase, warp) * (1 if get_raw else math.lerp(TRIANGLE_SCALE, SQUARE_SCALE, warp))
        case 21:
            value = triangle_to_square(_phase, 1 - warp) * (1 if get_raw else math.lerp(TRIANGLE_SCALE, SQUARE_SCALE, 1 - warp))
        case 13:
            value = triangle_to_saw(_phase, warp) * (1 if get_raw else math.lerp(TRIANGLE_SCALE, SAW_SCALE, warp))
        case 31:
            value = triangle_to_saw(_phase, 1 - warp) * (1 if get_raw else math.lerp(TRIANGLE_SCALE, SAW_SCALE, 1 - warp))
        case 32:
            value = saw_to_square(_phase, warp) * (1 if get_raw else math.lerp(SAW_SCALE, SQUARE_SCALE, warp))
        case 23:
            value = saw_to_square(_phase, 1 - warp) * (1 if get_raw else math.lerp(SAW_SCALE, SQUARE_SCALE, 1 - warp))
        case 40, 41, 42, 43, 44, 45:
            value = explicit_harmonics(harmonics[:], volume_limiter, _phase)
        case:
            value = test(_phase)
    }

    value_quantize : f32 = 32
    _value := value//f32(math.round(value * value_quantize)) / value_quantize

    return _value
}

get_wave_values :: proc(buffer: []f32, start_phase, end_phase: f32, waveform: Waveform, waveform2: Waveform, warp: f32) {
    count := len(buffer)
    step := (end_phase - start_phase) / f32(count - 1)

    phase := start_phase
    for i in 0..<count {
        buffer[i] = get_wave_value(phase, waveform, waveform2, warp, true)
        phase += step
    }
}