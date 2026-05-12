package raw

import "core:math"
import "../../mathx"


// ----------------------------------------------------------------------------------- saw
saw :: proc(phase: f32) -> f32
{
    return 1 - phase * 2
}


// ----------------------------------------------------------------------------------- morph to pulse
saw_to_pulse :: proc(phase, warp: f32) -> f32
{
    _warp := math.pow(warp, .5)

    if _warp == 0
    {
        return saw(phase)
    }

    low := mathx.lerp(.5, PULSE_LOW_LIMIT, _warp)
    high := mathx.lerp(.5, PULSE_HIGH_LIMIT, _warp)

    if phase <= low
    {
        _phase := mathx.remap(phase, 0, low, 0, .5)
        return saw(_phase)
    }
    else if phase < high
    {
        return 0
    }
    else
    {
        _phase := mathx.remap(phase, high, 1, .5, 1)
        return saw(_phase)
    }
}

// saw_to_pulse :: proc(phase, warp: f32) -> f32
// {
//     _warp := math.pow(warp, .2)

//     if _warp == 0
//     {
//         return saw(phase)
//     }

//     high := mathx.lerp(1, PULSE_LOW_LIMIT, _warp)

//     if phase < high
//     {
//         _phase := mathx.remap(phase, 0, high, 0, 1)
//         return saw(_phase)
//     }
//     else
//     {
//         return -1
//     }
// }

// saw_to_pulse :: proc(phase, warp: f32) -> f32
// {
//     _warp := warp//math.pow(warp, .2)

//     if _warp == 0
//     {
//         return saw(phase)
//     }

//     low := mathx.lerp(0, .5 - PULSE_LOW_LIMIT, _warp)
//     high := mathx.lerp(.5 + PULSE_LOW_LIMIT, 1, 1 - _warp)

//     if phase <= low
//     {
//         return 0
//     }
//     else if phase < high
//     {
//         _phase := mathx.remap(phase, low, high, 0, 1)
//         return saw(_phase)
//     }
//     else
//     {
//         return 0
//     }
// }


// ----------------------------------------------------------------------------------- morph to sine
saw_to_sine :: proc(phase, warp: f32) -> f32
{
    return sine_to_saw(phase, 1 - warp)
}


// ----------------------------------------------------------------------------------- morph to triangle
saw_to_triangle :: proc(phase, warp: f32) -> f32
{
    return triangle_to_saw(phase, 1 - warp)
}


// ----------------------------------------------------------------------------------- morph to square
saw_to_square :: proc(phase, warp: f32) -> f32
{
    return math.lerp(saw(phase), square(phase), warp)
}

// saw_to_square :: proc(phase, warp: f32) -> f32
// {
//     _warp := math.pow(warp, .01)

//     if _warp == 1
//     {
//         return square(phase)
//     }

//     _phase := phase
//     if phase <= .5
//     {
//         _phase = .5 * sine_to_square_phase_mod(2 * mathx.remap(phase, 0, 1, .25, .75), _warp)
//     }
//     else
//     {
//         _phase = .5 + .5 * sine_to_square_phase_mod(2 * mathx.remap(phase, 0, 1, .25, .75) - 1, _warp)
//     }
    
//     return math.lerp(saw(phase), sine(_phase), warp)
// }