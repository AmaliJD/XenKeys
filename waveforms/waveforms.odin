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

get_wave_value :: proc(phase: f32, waveform: Waveform, waveform2: Waveform, warp_amt: f32 = 0, get_raw: bool = false) -> f32 {
    value: f32
    switch waveform {
        case .Sine:
            #partial switch waveform2 {
                case .Square:
                    if (warp_amt > 0) {
                        value = math.clamp(sine(phase) / (1 - warp_amt), -1, 1) * (1 if get_raw else math.lerp(f32(1), SQUARE_SCALE, warp_amt))
                    }
                    else {
                        value = square(phase) * (1 if get_raw else SQUARE_SCALE)
                    }
                case:
                    value = sine(phase)
            }
        case .Triangle:
            #partial switch waveform2 {
                case .Saw:
                    value = triangle_to_saw(phase, warp_amt) * (1 if get_raw else TRIANGLE_SCALE)
                case:
                    value = triangle(phase) * (1 if get_raw else TRIANGLE_SCALE)
            }
        case .Square:
            #partial switch waveform2 {
                case .Square:
                    value = square_to_square(phase, warp_amt) * (1 if get_raw else SQUARE_SCALE)
                case:
                    value = square(phase) * (1 if get_raw else SQUARE_SCALE)
            }
            // value = square(phase) * (1 if get_raw else SQUARE_SCALE)
        case .Saw:
            value = saw(phase) * (1 if get_raw else SAW_SCALE)
        case .White:
            value = saw(phase)
        case:
            value = test(phase)
    }

    return value
}

get_wave_values :: proc(buffer: []f32, start_phase, end_phase: f32, waveform: Waveform, waveform2: Waveform, warp_amt: f32) {
    count := len(buffer)
    step := (end_phase - start_phase) / f32(count)

    phase := start_phase
    for i in 0..<count {
        buffer[i] = get_wave_value(phase, waveform, waveform2, warp_amt, true)
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
}

square :: proc(phase: f32) -> f32 {
    return 1 if phase <= .5 else -1
}

square_to_square :: proc(phase: f32, warp_amt: f32) -> f32 {
    return 1 if phase <= math.clamp(warp_amt, .005, .995) else -1
}

saw :: proc(phase: f32) -> f32 {
    return 1 - phase * 2
}

triangle_to_saw :: proc(phase: f32, warp: f32) -> f32 {
    if phase < warp {
        // Upward ramp
        return (phase / warp) * 2.0 - 1.0
    } else {
        // Downward ramp
        return 1.0 - ((phase - warp) / (1.0 - warp)) * 2.0
    }
}

test :: proc(phase: f32) -> f32 {
    return 0
}