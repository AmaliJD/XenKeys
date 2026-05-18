package waveforms

import "core:math"
import "../mathx"


// ----------------------------------------------------------------------------------- triangle
triangle :: proc(phase: f32) -> f32
{
    _phase := phase
    if _phase -= .25; _phase < 0
    {
        _phase += 1
    }
    return math.abs(_phase * 4 - 2) - 1
}

// ----------------------------------------------------------------------------------- morph to pulse
triangle_to_pulse :: proc(phase, warp: f32) -> f32
{
    _warp := math.pow(warp, .75)

    if _warp == 0
    {
        return triangle(phase)
    }

    width := mathx.lerp(.5, PULSE_LOW_LIMIT * 4, _warp)
    half_width := width / 2

    bounds_1 := [2]f32{.25 - half_width, .25 + half_width}
    bounds_2 := [2]f32{.75 - half_width, .75 + half_width}

    if phase >= bounds_1.x && phase <= bounds_1.y
    {
        _phase := mathx.remap(phase, bounds_1.x, bounds_1.y, 0, .5)
        return triangle(_phase)
    }
    else if phase >= bounds_2.x && phase <= bounds_2.y
    {
        _phase := mathx.remap(phase, bounds_2.x, bounds_2.y, .5, 1)
        return triangle(_phase)
    }
    else
    {
        return 0
    }
}


// ----------------------------------------------------------------------------------- morph to sine
triangle_to_sine :: proc(phase, warp: f32) -> f32 // lerp
{
    return sine_to_triangle(phase, 1 - warp)
}


// ----------------------------------------------------------------------------------- morph to square
triangle_to_square :: proc(phase, warp: f32) -> f32
{
    // return math.lerp(triangle(phase), square(phase), warp)
    if warp == 1
    {
        return square(phase)
    }
    else
    {
        tri := triangle(phase)
        scaled_tri := tri / (1 - warp)
        return math.clamp(scaled_tri, -1, 1)
    }
}

// triangle_to_square :: proc(phase, warp: f32) -> f32
// {
//     return math.lerp(triangle(phase), square(phase), warp)
// }


// ----------------------------------------------------------------------------------- morph to saw
triangle_to_saw :: proc(phase, warp: f32) -> f32
{
    _warp := mathx.remap(warp, 0, 1, .5, 0)
    if phase < _warp // Upward ramp
    {
        if _warp == 0
        {
            return saw(phase)
        }
        else
        {
            return (phase / _warp) * 2.0 - 1.0
        }
    }
    else // Downward ramp
    {
        return 1.0 - ((phase - _warp) / (1.0 - _warp)) * 2.0
    }
}


// ----------------------------------------------------------------------------------- morph to white
triangle_to_white :: proc(phase, warp: f32) -> f32
{
    return mathx.lerp(triangle(phase), white(phase), warp)
}