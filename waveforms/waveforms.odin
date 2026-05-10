package waveforms

import "core:math"

@private TRIANGLE_SCALE :: f32(.9)
@private SQUARE_SCALE   :: f32(0.35)
@private SAW_SCALE      :: f32(0.4)
@private NIPPLE_SCALE      :: f32(0.5)
@private X_SCALE        :: f32(0.8)

Waveform :: enum {
    Sine,
    Triangle,   // odd harmonics, 1/n², alternating signs
    Square,     // odd harmonics, 1/n
    Saw,        // all harmonics, 1/n
    X,
    Test
}

harmonics : []f32 = {1, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 51, 53, 59, 61} // prime
// harmonics : []f32 = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32} // saw
// harmonics : []f32 = {1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50} // quarter circle
// harmonics : []f32 = {1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144} // fibbonaci bells
volume_limiter : f32 = 3

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
            // value = square_to_square(_phase, warp) * (1 if get_raw else SQUARE_SCALE)
            value = square(_phase) * (1 if get_raw else SQUARE_SCALE)
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

sine :: proc(phase: f32) -> f32 {
    return math.sin_f32(phase * 2.0 * math.PI)
}

sine_to_sine :: proc(phase: f32, warp: f32) -> f32 {

    _warp := warp//math.pow(warp, .5)

    if _warp == 0 { return sine(phase) }
    _phase := phase
    if phase <= .5 {
        _phase = .5 * sine_to_sine_phase_mod(2 * phase, _warp)
    }
    else {
        _phase = .5 + .5 * sine_to_sine_phase_mod(2 * phase - 1, _warp)
    }
    
    return sine(_phase)
}

sine_to_sine_phase_mod :: proc(phase, warp: f32) -> f32 {
    k := 1 + 8 * warp
    _t := 2 * phase - 1
    sigmoid := math.tanh(k * _t)
    s := .5 * (sigmoid + 1)
    return (1 - warp) * phase + warp * s
}

// sine_to_square :: proc(phase: f32, warp: f32) -> f32 {

//     value : f32
//     if (warp < 1) {
//         value = math.clamp(sine(phase) / (1 - warp), -1, 1)
//     }
//     else {
//         value = square(phase)
//     }
//     return value
// }

sine_to_square :: proc(phase: f32, warp: f32) -> f32 {

    _warp := math.pow(warp, .5)

    if _warp == 1 { return square(phase) }
    _phase := phase
    if phase <= .5 {
        _phase = .5 * sine_to_square_phase_mod(2 * phase, _warp)
    }
    else {
        _phase = .5 + .5 * sine_to_square_phase_mod(2 * phase - 1, _warp)
    }
    
    return sine(_phase)
}

sine_to_square_phase_mod :: proc(phase, warp: f32) -> f32 {
    p := 1 / (1 - warp)
    _t := 2 * phase - 1
    return .5 + .5 * math.sign(_t) * math.pow(math.abs(_t), p)
}

sine_to_triangle :: proc(phase: f32, warp: f32) -> f32 {
    return math.lerp(sine(phase), triangle(phase), warp)
}

sine_to_saw :: proc(phase: f32, warp: f32) -> f32 {
    s_phase := phase
    _warp := math.pow(warp, .5)

    if _warp == 1 { return saw(phase) }

    low := f32(math.lerp(f32(0), f32(.25), f32(1) - _warp))
    high := f32(math.lerp(f32(.75), f32(1), _warp))
    if s_phase <= low {
        s_phase = remap(s_phase, 0, low, 0, .25)
        return sine(s_phase)
    }
    else if s_phase <= high {
        s_phase = remap(s_phase, low, high, .25, .75)
        // return sine(s_phase)
        saw_remapped := saw(remap(phase, low, high, 0, 1))
        return math.lerp(sine(s_phase), saw_remapped, _warp)
    }
    else {
        s_phase = remap(s_phase, high, 1, .75, 1)
        return sine(s_phase)
    }
}

// sine_to_saw :: proc(phase: f32, warp: f32) -> f32 {
//     _warp := warp//math.pow(warp, .5)

//     if _warp == 1 { return saw(phase) }
//     _phase := sine_to_saw_phase_mod(phase, _warp)
//     return sine(_phase)
// }

sine_to_saw_phase_mod :: proc(phase, warp: f32) -> f32 {
    slope_1 := phase
    slope_2 := phase * .5 + .25

    y := f32(.5)
    if phase < .5 {
        y = math.lerp(slope_1, slope_2, remap(phase, 0, .5, 0, 1))
    }
    else if phase > .5 {
        y = math.lerp(slope_2, slope_1, remap(phase, .5, 1, 0, 1))
    }
    
    return slope_2
}

triangle :: proc(phase: f32) -> f32 {
    _phase := phase
    if _phase -= .25; _phase < 0 {
        _phase += 1
    }
    return math.abs(_phase * 4 - 2) - 1
}

triangle_to_square :: proc(phase: f32, warp: f32) -> f32 {
    // return math.lerp(triangle(phase), square(phase), warp)
    if warp == 1 {
        return square(phase)
    }
    else {
        tri := triangle(phase)
        scaled_tri := tri / (1 - warp)
        return math.clamp(scaled_tri, -1, 1)
    }
}

triangle_to_saw :: proc(phase: f32, warp: f32) -> f32 {
    _warp := remap(warp, 0, 1, .5, 0)
    if phase < _warp {
        // Upward ramp
        if _warp == 0 {return saw(phase)}
        else {
        return (phase / _warp) * 2.0 - 1.0
        }
    } else {
        // Downward ramp
        return 1.0 - ((phase - _warp) / (1.0 - _warp)) * 2.0
    }
}

square :: proc(phase: f32) -> f32 {
    // return 1 if phase < .5 else -1
    value : f32 = 1 if phase < .5 else -1
    dt := f32(220.0 / 44100.0)
    value -= polyblep(phase, dt)
    t : f32 = phase + f32(.5)
    if t >= 1.0 {
        t -= 1.0
    }
    value += polyblep(t, dt)
    return value
}

polyblep :: proc(t, dt: f32) -> f32 {
    _t := t
    
    if _t < dt {
        _t /= dt
        return _t + _t - _t * _t - 1
    }
    else if _t > 1 - dt {
        _t = (_t - 1) / dt
        return _t * _t + _t + _t + 1
    }

    return 0
}

square_to_square :: proc(phase: f32, warp: f32) -> f32 {
    _warp := remap(warp, 0, 1, .5, 1)
    return 1 if phase < math.clamp(_warp, .005, .995) else -1
}

saw :: proc(phase: f32) -> f32 {
    return 1 - phase * 2
}

saw_to_square :: proc(phase: f32, warp: f32) -> f32 {
    return math.lerp(saw(phase), square(phase), warp)
}

// saw_to_square :: proc(phase: f32, warp: f32) -> f32 {
//     _warp := math.pow(warp, .05)

//     if _warp == 1 { return square(phase) }
//     _phase := phase
//     if phase <= .5 {
//         _phase = .5 * sine_to_square_phase_mod(2 * remap(phase, 0, 1, .25, .75), _warp)
//     }
//     else {
//         _phase = .5 + .5 * sine_to_square_phase_mod(2 * remap(phase, 0, 1, .25, .75) - 1, _warp)
//     }
    
//     return math.lerp(saw(phase), sine(_phase), warp)
// }

explicit_harmonics :: proc(harmonics: []f32, volume_limiter: f32, phase: f32) -> f32 {
    val: f32
    i := f32(1)
    for n in harmonics {
        val += i * (1.0 / f32(n)) * math.sin(2.0 * math.PI * phase * f32(n))
    }

    val /= volume_limiter

    return val
}

test :: proc(phase: f32) -> f32 {
    return 0
}

inverse_lerp :: proc(min, max, value: f32) -> f32 {
    return (value - min) / (max - min)
}

remap :: proc(value, in_min, in_max, out_min, out_max: f32) -> f32 {
    _t := inverse_lerp(in_min, in_max, value)
    return math.lerp(out_min, out_max, _t)
}