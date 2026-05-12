package raw

import "core:math"
import "../../mathx"


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