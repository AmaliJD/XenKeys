package waveforms

import "core:math"
import "../mathx"

// ----------------------------------------------------------------------------------- sine
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
    _warp := math.pow(warp, .7)

    if _warp == 1 { return saw(phase) }

    low := f32(math.lerp(f32(0), f32(.25), f32(1) - _warp))
    high := f32(math.lerp(f32(.75), f32(1), _warp))
    if s_phase <= low {
        s_phase = mathx.remap(s_phase, 0, low, 0, .25)
        return sine(s_phase)
    }
    else if s_phase <= high {
        s_phase = mathx.remap(s_phase, low, high, .25, .75)
        // return sine(s_phase)
        saw_remapped := saw(mathx.remap(phase, low, high, 0, 1))
        return math.lerp(sine(s_phase), saw_remapped, _warp * _warp * _warp)
    }
    else {
        s_phase = mathx.remap(s_phase, high, 1, .75, 1)
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
        y = math.lerp(slope_1, slope_2, mathx.remap(phase, 0, .5, 0, 1))
    }
    else if phase > .5 {
        y = math.lerp(slope_2, slope_1, mathx.remap(phase, .5, 1, 0, 1))
    }
    
    return slope_2
}


// ----------------------------------------------------------------------------------- triangle
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
    _warp := mathx.remap(warp, 0, 1, .5, 0)
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


// ----------------------------------------------------------------------------------- square
square :: proc(phase: f32) -> f32 {
    return 1 if phase < .5 else -1
}

square_to_square :: proc(phase: f32, warp: f32) -> f32 {
    _warp := mathx.remap(warp, 0, 1, .5, 1)
    return 1 if phase < math.clamp(_warp, .005, .995) else -1
}


// ----------------------------------------------------------------------------------- saw
saw :: proc(phase: f32) -> f32 {
    return 1 - phase * 2
}

saw_to_square :: proc(phase: f32, warp: f32) -> f32 {
    return math.lerp(saw(phase), square(phase), warp)
}

// saw_to_square :: proc(phase: f32, warp: f32) -> f32 {
//     _warp := math.pow(warp, .01)

//     if _warp == 1 { return square(phase) }
//     _phase := phase
//     if phase <= .5 {
//         _phase = .5 * sine_to_square_phase_mod(2 * mathx.remap(phase, 0, 1, .25, .75), _warp)
//     }
//     else {
//         _phase = .5 + .5 * sine_to_square_phase_mod(2 * mathx.remap(phase, 0, 1, .25, .75) - 1, _warp)
//     }
    
//     return math.lerp(saw(phase), sine(_phase), warp)
// }


// ----------------------------------------------------------------------------------- other
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