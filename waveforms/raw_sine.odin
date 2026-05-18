package waveforms

import "core:math"
import "../mathx"


// ----------------------------------------------------------------------------------- sine
sine :: proc(phase: f32) -> f32
{
    return math.sin_f32(phase * math.TAU)
}


// ----------------------------------------------------------------------------------- morph to pusle
sine_to_pulse :: proc(phase: f32, warp: f32) -> f32
{
    _warp := warp//math.pow(warp, .5)

    if _warp == 0
    {
        return sine(phase)
    }
    
    _phase := phase
    if phase <= .5
    {
        _phase = .5 * sine_to_pulse_phase_mod(2 * phase, _warp)
    }
    else
    {
        _phase = .5 + .5 * sine_to_pulse_phase_mod(2 * phase - 1, _warp)
    }
    
    return sine(_phase)
}

sine_to_pulse_phase_mod :: proc(phase, warp: f32) -> f32 // use different function
{
    k := 1 + 8 * warp
    t := 2 * phase - 1
    sigmoid := math.tanh(k * t)
    s := .5 * (sigmoid + 1)
    return (1 - warp) * phase + warp * s
}


// ----------------------------------------------------------------------------------- morph to triangle
sine_to_triangle :: proc(phase, warp: f32) -> f32 // lerp
{
    return math.lerp(sine(phase), triangle(phase), warp)
}


// ----------------------------------------------------------------------------------- morph to square
sine_to_square :: proc(phase, warp: f32) -> f32
{
    _warp := math.pow(warp, .5)

    if _warp == 1
    {
        return square(phase)
    }

    _phase := phase
    if phase <= .5
    {
        _phase = .5 * sine_to_square_phase_mod(2 * phase, _warp)
    }
    else
    {
        _phase = .5 + .5 * sine_to_square_phase_mod(2 * phase - 1, _warp)
    }
    
    return sine(_phase)
}

sine_to_square_phase_mod :: proc(phase, warp: f32) -> f32
{
    p := 1 / (1 - warp)
    t := 2 * phase - 1
    return .5 + .5 * math.sign(t) * math.pow(math.abs(t), p)
}

sine_to_square_clamp :: proc(phase, warp: f32) -> f32
{
    if (warp < 1)
    {
        return math.clamp(sine(phase) / (1 - warp), -1, 1)
    }
    else
    {
        return square(phase)
    }
}


// ----------------------------------------------------------------------------------- morph to saw
sine_to_saw :: proc(phase, warp: f32) -> f32
{
    _warp := math.pow(warp, .7)

    if _warp == 1
    {
        return saw(phase)
    }

    low := mathx.lerp(0, .25, 1 - _warp)
    high := mathx.lerp(.75, 1, _warp)

    _phase := phase
    if _phase <= low
    {
        _phase = mathx.remap(_phase, 0, low, 0, .25)
        return sine(_phase)
    }
    else if _phase < high
    {
        _phase = mathx.remap(_phase, low, high, .25, .75)
        // return sine(_phase)
        saw_remapped := saw(mathx.remap(phase, low, high, 0, 1))
        return mathx.lerp(sine(_phase), saw_remapped, _warp * _warp * _warp)
    }
    else
    {
        _phase = mathx.remap(_phase, high, 1, .75, 1)
        return sine(_phase)
    }
}

sine_between_peaks :: proc(phase, warp: f32) -> f32
{
    _phase := sine_to_saw_phase_mod(phase, warp)
    return sine(_phase)
}

sine_to_saw_phase_mod :: proc(phase, warp: f32) -> f32
{
    slope_1 := phase
    slope_2 := phase * .5 + .25

    y : f32 = .5
    if phase < .5
    {
        y = math.lerp(slope_1, slope_2, mathx.remap(phase, 0, .5, 0, 1))
    }
    else if phase > .5
    {
        y = math.lerp(slope_2, slope_1, mathx.remap(phase, .5, 1, 0, 1))
    }
    
    return slope_2
}


// ----------------------------------------------------------------------------------- morph to white
sine_to_white :: proc(phase, warp: f32) -> f32
{
    return mathx.lerp(sine(phase), white(phase), warp)
}