package waveforms

import "core:math"

@private TRIANGLE_SCALE :: .9
@private SQUARE_SCALE   :: 0.4
@private SAW_SCALE      :: 0.5

Waveform :: enum {
    Sine,
    Triangle,   // odd harmonics
    Square,
    Saw,
    White
}

get_wave_value :: proc(phase: f32, waveform: Waveform, get_raw: bool = false) -> f32 {
    value: f32
    switch waveform {
        case .Sine:
            value = sine(phase)
        case .Triangle:
            value = triangle(phase) * (1 if get_raw else TRIANGLE_SCALE)
        case .Square:
            value = square(phase) * (1 if get_raw else SQUARE_SCALE)
        case .Saw:
            value = saw(phase) * (1 if get_raw else SAW_SCALE)
        case .White:
            value = saw(phase)
        case:
            value = test(phase)
    }

    return value
}

get_wave_values :: proc(buffer: []f32, start_phase, end_phase: f32, waveform: Waveform) {
    count := len(buffer)
    step := (end_phase - start_phase) / f32(count)

    phase := start_phase
    for i in 0..<count {
        buffer[i] = get_wave_value(phase, waveform, true)
        phase += step
    }
}

sine :: proc(phase: f32) -> f32 {
    return math.sin_f32(phase * 2.0 * math.PI)
}

triangle :: proc(phase: f32) -> f32 {
    adj_phase := phase
    if adj_phase -= .25; adj_phase < 0 {
        adj_phase += 1
    }
    return math.abs(adj_phase * 4 - 2) - 1
    // pw : f32 = 0
    // if phase < pw {
    //     // Upward ramp
    //     return (phase / pw) * 2.0 - 1.0
    // } else {
    //     // Downward ramp
    //     return 1.0 - ((phase - pw) / (1.0 - pw)) * 2.0
    // }
}

square :: proc(phase: f32) -> f32 {
    return 1 if phase <= .5 else -1
}

saw :: proc(phase: f32) -> f32 {
    return 1 - phase * 2
}

test :: proc(phase: f32) -> f32 {
    return 0
}